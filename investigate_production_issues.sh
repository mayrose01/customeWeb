#!/bin/bash

# 深入调查生产环境问题的脚本
# 检查代码版本、数据库数据来源和API错误详情

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

# 深入调查生产环境问题
investigate_issues() {
    log_step "深入调查生产环境问题..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
echo "=== 1. 检查代码版本和Git状态 ==="
cd /var/www/enterprise/enterprise-backend
echo "当前目录: $(pwd)"
echo "Git状态:"
git status --porcelain | head -10
echo "Git提交历史:"
git log --oneline -5
echo "Git分支:"
git branch -a

echo -e "\n=== 2. 检查数据库中的产品数据来源 ==="
echo "查看产品表的完整数据:"
mysql -u root -proot -e "USE enterprise_prod; SELECT * FROM products ORDER BY id;"

echo -e "\n查看产品表的创建时间:"
mysql -u root -proot -e "USE enterprise_prod; SELECT id, name, created_at, updated_at FROM products ORDER BY id;"

echo -e "\n查看是否有数据库初始化脚本:"
find /var/www/enterprise -name "*.sql" -o -name "*init*" -o -name "*data*" | head -10

echo -e "\n=== 3. 检查API错误的完整信息 ==="
echo "查看完整的后端日志:"
cd /var/www/enterprise/enterprise-backend
if [ -f "logs/app.log" ]; then
    echo "最近的完整错误日志:"
    tail -50 logs/app.log | grep -A 5 -B 5 "ERROR\|Exception\|Traceback"
else
    echo "日志文件不存在"
fi

echo -e "\n=== 4. 检查代码文件内容 ==="
echo "检查schemas.py中的产品相关定义:"
grep -n -A 10 -B 5 "class Product" app/schemas.py

echo -e "\n检查models.py中的产品模型:"
grep -n -A 10 -B 5 "class Product" app/models.py

echo -e "\n检查产品API端点:"
grep -n -A 5 -B 5 "def.*product" app/api/endpoints/product.py

echo -e "\n=== 5. 检查环境差异 ==="
echo "Python版本:"
python3 --version
echo "pip版本:"
pip --version
echo "已安装的包:"
pip list | grep -E "(fastapi|pydantic|sqlalchemy)" | head -10

echo -e "\n=== 6. 测试API并获取完整错误 ==="
echo "测试产品列表API（获取完整错误）:"
curl -v "http://localhost:8000/api/product/?page=1&page_size=10" 2>&1 | head -30

echo -e "\n测试产品创建API（获取完整错误）:"
curl -v -X POST "http://localhost:8000/api/product/" \
  -H "Content-Type: application/json" \
  -d '{"title": "测试产品", "category_id": 2}' \
  2>&1 | head -30

echo -e "\n=== 7. 检查数据库表结构 ==="
echo "查看产品表结构:"
mysql -u root -proot -e "USE enterprise_prod; DESCRIBE products;"

echo -e "\n查看分类表结构:"
mysql -u root -proot -e "USE enterprise_prod; DESCRIBE categories;"

echo -e "\n=== 8. 检查是否有测试数据脚本 ==="
echo "查找可能的测试数据文件:"
find /var/www/enterprise -name "*test*" -o -name "*demo*" -o -name "*sample*" | head -10

echo "查找可能的数据库初始化文件:"
find /var/www/enterprise -name "*init*" -o -name "*setup*" -o -name "*seed*" | head -10
EOF
}

# 主函数
main() {
    log_info "开始深入调查生产环境问题..."
    
    check_ssh_key
    test_ssh_connection
    
    if [ $? -eq 0 ]; then
        investigate_issues
        
        log_info "调查完成！请根据上述信息分析："
        log_info "1. 代码版本是否与本地一致"
        log_info "2. 数据库中的产品数据来源"
        log_info "3. API错误的具体原因"
        log_info "4. 环境差异（Python版本、依赖包等）"
        log_info "5. 数据库表结构是否与代码匹配"
    else
        log_error "无法连接到生产服务器"
        exit 1
    fi
}

# 执行主函数
main "$@"
