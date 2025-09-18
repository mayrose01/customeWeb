#!/bin/bash

# 测试产品保存功能的脚本
# 验证产品API修复是否成功

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

# 测试产品相关功能
test_product_functionality() {
    log_step "测试产品相关功能..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
echo "=== 测试产品列表API ==="
echo "测试获取产品列表..."
curl -s -w "HTTP状态码: %{http_code}\n" "http://localhost:8000/api/product/?page=1&page_size=10" | head -20

echo -e "\n=== 测试分类列表API ==="
echo "测试获取分类列表..."
curl -s -w "HTTP状态码: %{http_code}\n" "http://localhost:8000/api/category/" | head -10

echo -e "\n=== 测试产品创建API ==="
echo "测试创建新产品..."
curl -s -X POST "http://localhost:8000/api/product/" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试产品",
    "description": "这是一个测试产品",
    "price": 99.99,
    "category_id": 2,
    "sort_order": 1
  }' \
  -w "HTTP状态码: %{http_code}\n" | head -10

echo -e "\n=== 测试获取单个产品 ==="
echo "测试获取产品详情..."
curl -s -w "HTTP状态码: %{http_code}\n" "http://localhost:8000/api/product/1" | head -10

echo -e "\n=== 检查后端日志 ==="
echo "查看最近的错误日志..."
cd /var/www/enterprise/enterprise-backend
if [ -f "logs/app.log" ]; then
    echo "最近的错误日志:"
    tail -20 logs/app.log | grep -i error | head -5
    echo -e "\n最近的警告日志:"
    tail -20 logs/app.log | grep -i warning | head -5
else
    echo "日志文件不存在"
fi

echo -e "\n=== 检查服务状态 ==="
echo "后端服务状态:"
systemctl status enterprise-backend --no-pager -l | head -10

echo -e "\n=== 数据库状态 ==="
echo "检查产品表数据..."
mysql -u root -proot -e "USE enterprise_prod; SELECT COUNT(*) as product_count FROM products;"
echo -e "\n检查分类表数据..."
mysql -u root -proot -e "USE enterprise_prod; SELECT id, name, parent_id FROM categories;"
EOF
}

# 主函数
main() {
    log_info "开始测试产品保存功能..."
    
    check_ssh_key
    test_ssh_connection
    
    if [ $? -eq 0 ]; then
        test_product_functionality
        
        log_info "测试完成！请检查以下结果："
        log_info "1. 产品列表API是否返回200状态码"
        log_info "2. 产品创建API是否成功"
        log_info "3. 是否有新的错误日志"
        log_info "4. 数据库中的产品数量是否增加"
    else
        log_error "无法连接到生产服务器"
        exit 1
    fi
}

# 执行主函数
main "$@"
