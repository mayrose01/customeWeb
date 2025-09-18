#!/bin/bash

# 测试重建后API的脚本
# 获取完整的错误信息

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

# 测试重建后的API
test_rebuilt_api() {
    log_step "测试重建后的API..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
echo "=== 1. 检查后端服务状态 ==="
systemctl status enterprise-backend --no-pager -l | head -10

echo -e "\n=== 2. 检查后端日志中的错误 ==="
cd /var/www/enterprise/enterprise-backend
if [ -f "logs/app.log" ]; then
    echo "最近的错误日志:"
    tail -50 logs/app.log | grep -A 10 -B 5 "ERROR\|Exception\|Traceback"
else
    echo "日志文件不存在"
fi

echo -e "\n=== 3. 测试产品列表API（获取完整错误） ==="
echo "使用curl -v获取详细错误信息:"
curl -v "http://localhost:8000/api/product/?page=1&page_size=10" 2>&1 | head -50

echo -e "\n=== 4. 测试产品创建API（获取完整错误） ==="
echo "使用curl -v获取详细错误信息:"
curl -v -X POST "http://localhost:8000/api/product/" \
  -H "Content-Type: application/json" \
  -d '{"title": "测试产品", "short_desc": "这是一个测试产品", "category_id": 2}' \
  2>&1 | head -50

echo -e "\n=== 5. 检查数据库表结构 ==="
echo "验证products表结构:"
mysql -u root -proot -e "USE enterprise_prod; DESCRIBE products;"

echo -e "\n=== 6. 检查代码与数据库的匹配性 ==="
echo "检查Product模型定义:"
grep -A 15 "class Product" app/models.py

echo -e "\n检查Product schemas定义:"
grep -A 15 "class Product" app/schemas.py

echo -e "\n=== 7. 尝试直接数据库查询 ==="
echo "直接查询products表:"
mysql -u root -proot -e "USE enterprise_prod; SELECT * FROM products;"

echo -e "\n=== 8. 检查是否有其他错误 ==="
echo "检查系统日志:"
journalctl -u enterprise-backend --no-pager -l | tail -20
EOF
}

# 主函数
main() {
    log_info "开始测试重建后的API..."
    
    check_ssh_key
    test_ssh_connection
    
    if [ $? -eq 0 ]; then
        test_rebuilt_api
        
        log_info "测试完成！请根据错误信息进一步诊断问题"
    else
        log_error "无法连接到生产服务器"
        exit 1
    fi
}

# 执行主函数
main "$@"
