#!/bin/bash

# 手动修复Product模型的脚本
# 直接替换整个Product类定义

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

# 手动修复Product模型
manual_fix_product_model() {
    log_step "手动修复Product模型..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
cd /var/www/enterprise/enterprise-backend

echo "=== 1. 备份当前models.py文件 ==="
cp app/models.py app/models.py.backup.$(date +%Y%m%d_%H%M%S)

echo "=== 2. 创建新的Product模型定义 ==="
cat > /tmp/new_product_model.py << 'INNER_EOF'
from sqlalchemy import Column, Integer, String, Text, Boolean, TIMESTAMP, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base

class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)  # 产品标题
    model = Column(String(255), nullable=True)   # 产品型号
    short_desc = Column(Text, nullable=True)     # 简要描述
    detail = Column(Text, nullable=True)         # 详细描述
    images = Column(JSON, nullable=True)         # 图片数组
    category_id = Column(Integer, ForeignKey('categories.id'), nullable=True)
    sort_order = Column(Integer, default=0)      # 排序字段
    is_active = Column(Boolean, default=True)    # 是否启用
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())
    
    category = relationship("Category")
INNER_EOF

echo "=== 3. 查看当前models.py文件结构 ==="
echo "文件前20行:"
head -20 app/models.py

echo -e "\nProduct类位置:"
grep -n "class Product" app/models.py

echo -e "\n=== 4. 使用Python脚本替换Product类 ==="
python3 -c "
import re

# 读取文件
with open('app/models.py', 'r', encoding='utf-8') as f:
    content = f.read()

# 读取新的Product模型
with open('/tmp/new_product_model.py', 'r', encoding='utf-8') as f:
    new_product = f.read()

# 找到Product类的开始和结束
pattern = r'class Product\(Base\):.*?(?=class \w+\(|$)'
match = re.search(pattern, content, re.DOTALL)

if match:
    print('找到Product类，开始替换...')
    # 替换Product类
    new_content = re.sub(pattern, new_product, content, flags=re.DOTALL)
    
    # 写回文件
    with open('app/models.py', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print('Product类替换完成')
else:
    print('未找到Product类')
    exit(1)
"

echo -e "\n=== 5. 验证修复结果 ==="
echo "检查Product模型定义:"
grep -A 15 "class Product" app/models.py

echo -e "\n=== 6. 检查语法 ==="
python3 -m py_compile app/models.py
if [ $? -eq 0 ]; then
    echo "语法检查通过"
else
    echo "语法检查失败，需要手动修复"
    exit 1
fi

echo -e "\n=== 7. 重启后端服务 ==="
systemctl restart enterprise-backend

echo "等待服务启动..."
sleep 5

echo -e "\n=== 8. 测试产品API ==="
echo "测试产品列表API:"
curl -s -w "HTTP状态码: %{http_code}\n" "http://localhost:8000/api/product/?page=1&page_size=10" | head -10

echo -e "\n测试产品创建API:"
curl -s -X POST "http://localhost:8000/api/product/" \
  -H "Content-Type: application/json" \
  -d '{"title": "测试产品", "short_desc": "这是一个测试产品", "category_id": 2}' \
  -w "HTTP状态码: %{http_code}\n" | head -10

echo -e "\n=== 9. 验证新创建的产品 ==="
echo "检查数据库中的产品:"
mysql -u root -proot -e "USE enterprise_prod; SELECT * FROM products;"

echo -e "\n=== 10. 清理临时文件 ==="
rm -f /tmp/new_product_model.py

echo "=== 手动修复完成 ==="
EOF
}

# 主函数
main() {
    log_info "开始手动修复Product模型..."
    
    check_ssh_key
    test_ssh_connection
    
    if [ $? -eq 0 ]; then
        manual_fix_product_model
        
        log_info "Product模型手动修复完成！"
        log_info "现在请测试："
        log_info "1. 产品列表API是否返回200状态码"
        log_info "2. 产品创建API是否成功"
        log_info "3. 新增的产品是否正确保存"
    else
        log_error "无法连接到生产服务器"
        exit 1
    fi
}

# 执行主函数
main "$@"
