#!/bin/bash

# 强制重建产品表的脚本
# 先删除引用关系，然后重建表

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置信息
SERVER_IP="47.243.41.30"
SERVER_USERNAME="root"
SSH_PRIVATE_KEY="./enterprise_prod.pem"

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查SSH私钥文件
check_ssh_key() {
    log_step "检查SSH私钥文件..."
    
    if [ ! -f "$SSH_PRIVATE_KEY" ]; then
        log_error "SSH私钥文件不存在: $SSH_PRIVATE_KEY"
        exit 1
    fi
    
    chmod 600 "$SSH_PRIVATE_KEY"
    log_info "SSH私钥文件检查完成"
}

# 测试SSH连接
test_ssh_connection() {
    log_step "测试SSH连接..."
    
    if ssh -i "$SSH_PRIVATE_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" "echo 'SSH连接测试成功'" 2>/dev/null; then
        log_info "SSH连接正常"
        return 0
    else
        log_error "SSH连接失败"
        return 1
    fi
}

# 强制重建产品表
force_rebuild_product_table() {
    log_step "强制重建产品表..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
cd /var/www/enterprise/enterprise-backend

echo "=== 1. 检查哪些表引用了products表 ==="
mysql -u root -proot -e "
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE 
WHERE REFERENCED_TABLE_NAME = 'products' 
AND TABLE_SCHEMA = 'enterprise_prod';
"

echo -e "\n=== 2. 备份相关表数据 ==="
echo "备份inquiries表（如果存在）..."
mysqldump -u root -proot enterprise_prod inquiries > inquiries_backup_$(date +%Y%m%d_%H%M%S).sql 2>/dev/null || echo "inquiries表不存在"

echo "备份products表..."
mysqldump -u root -proot enterprise_prod products > products_backup_$(date +%Y%m%d_%H%M%S).sql

echo -e "\n=== 3. 删除引用products表的外键约束 ==="
echo "删除inquiries表中的外键约束..."
mysql -u root -proot -e "
USE enterprise_prod;
SET FOREIGN_KEY_CHECKS = 0;

-- 删除inquiries表（如果存在）
DROP TABLE IF EXISTS inquiries;

-- 删除products表
DROP TABLE IF EXISTS products;

SET FOREIGN_KEY_CHECKS = 1;
"

echo -e "\n=== 4. 根据代码重新创建产品表 ==="
echo "创建新的products表..."
mysql -u root -proot -e "
USE enterprise_prod;
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    model VARCHAR(255),
    short_desc TEXT,
    detail TEXT,
    images JSON,
    category_id INT,
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_category_id (category_id),
    INDEX idx_sort_order (sort_order),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
"

echo -e "\n=== 5. 重新创建inquiries表 ==="
echo "创建inquiries表..."
mysql -u root -proot -e "
USE enterprise_prod;
CREATE TABLE inquiries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    product_title VARCHAR(255),
    service_id INT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    message TEXT,
    status ENUM('new', 'processing', 'completed', 'cancelled') DEFAULT 'new',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
    INDEX idx_product_id (product_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
"

echo -e "\n=== 6. 验证表结构 ==="
echo "新创建的产品表结构:"
mysql -u root -proot -e "USE enterprise_prod; DESCRIBE products;"

echo -e "\n新创建的inquiries表结构:"
mysql -u root -proot -e "USE enterprise_prod; DESCRIBE inquiries;"

echo -e "\n=== 7. 检查表是否为空 ==="
echo "产品表记录数:"
mysql -u root -proot -e "USE enterprise_prod; SELECT COUNT(*) as product_count FROM products;"

echo "inquiries表记录数:"
mysql -u root -proot -e "USE enterprise_prod; SELECT COUNT(*) as inquiry_count FROM inquiries;"

echo -e "\n=== 8. 重启后端服务 ==="
systemctl restart enterprise-backend

echo "等待服务启动..."
sleep 5

echo -e "\n=== 9. 测试产品API ==="
echo "测试产品列表API:"
curl -s -w "HTTP状态码: %{http_code}\n" "http://localhost:8000/api/product/?page=1&page_size=10" | head -10

echo -e "\n测试产品创建API:"
curl -s -X POST "http://localhost:8000/api/product/" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "测试产品",
    "short_desc": "这是一个测试产品",
    "category_id": 2,
    "sort_order": 1
  }' \
  -w "HTTP状态码: %{http_code}\n" | head -10

echo -e "\n=== 10. 验证新创建的产品 ==="
echo "检查数据库中的产品:"
mysql -u root -proot -e "USE enterprise_prod; SELECT * FROM products;"

echo -e "\n=== 11. 清理备份文件 ==="
echo "删除临时备份文件..."
rm -f *_backup_*.sql

echo "=== 强制重建完成 ==="
EOF
}

# 主函数
main() {
    log_info "开始强制重建产品表..."
    
    check_ssh_key
    test_ssh_connection
    
    if [ $? -eq 0 ]; then
        log_warn "⚠️  警告：此操作将删除所有现有产品数据和相关表！"
        log_warn "⚠️  请确认这是您想要的操作"
        
        read -p "是否继续？输入 'yes' 确认: " -r
        if [[ $REPLY == "yes" ]]; then
            force_rebuild_product_table
            
            log_info "产品表强制重建完成！"
            log_info "现在请测试："
            log_info "1. 产品列表API是否返回200状态码"
            log_info "2. 产品创建API是否成功"
            log_info "3. 新增的产品是否正确保存"
        else
            log_info "操作已取消"
        fi
    else
        log_error "无法连接到生产服务器"
        exit 1
    fi
}

# 执行主函数
main "$@"
