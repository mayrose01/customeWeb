#!/bin/bash

# 生产环境问题诊断脚本
# 诊断产品保存失败、分类删除失败、产品列表为空等问题

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
PROJECT_NAME="enterprise"

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
        log_info "请确保私钥文件存在于当前目录"
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
        log_error "SSH连接失败，请检查服务器IP和私钥文件"
        return 1
    fi
}

# 检查生产环境状态
check_production_status() {
    log_step "检查生产环境状态..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
echo "=== 系统状态 ==="
systemctl status nginx --no-pager -l | head -20
echo
systemctl status mysql --no-pager -l | head -20
echo
systemctl status enterprise-backend --no-pager -l | head -20

echo "=== 进程状态 ==="
ps aux | grep -E "(nginx|mysql|python|enterprise)" | grep -v grep | head -10

echo "=== 端口监听 ==="
netstat -tlnp | grep -E "(80|443|8000|3306)" | head -10

echo "=== 磁盘空间 ==="
df -h | head -10

echo "=== 内存使用 ==="
free -h
EOF
}

# 检查数据库状态
check_database_status() {
    log_step "检查数据库状态..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
echo "=== MySQL状态 ==="
mysql -u root -proot -e "SHOW DATABASES;" 2>/dev/null || echo "MySQL连接失败"
echo
mysql -u root -proot -e "USE enterprise_prod; SHOW TABLES;" 2>/dev/null || echo "无法访问enterprise_prod数据库"
echo
mysql -u root -proot -e "USE enterprise_prod; SELECT COUNT(*) as category_count FROM categories;" 2>/dev/null || echo "无法查询categories表"
echo
mysql -u root -proot -e "USE enterprise_prod; SELECT COUNT(*) as product_count FROM products;" 2>/dev/null || echo "无法查询products表"
echo
mysql -u root -proot -e "USE enterprise_prod; SELECT c.id, c.name, c.parent_id, COUNT(p.id) as product_count FROM categories c LEFT JOIN products p ON c.id = p.category_id GROUP BY c.id;" 2>/dev/null || echo "无法查询分类产品关联"
EOF
}

# 检查后端日志
check_backend_logs() {
    log_step "检查后端日志..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
echo "=== 后端日志 ==="
cd /var/www/enterprise/enterprise-backend 2>/dev/null || echo "后端目录不存在"
if [ -f "logs/app.log" ]; then
    echo "最近的错误日志:"
    tail -20 logs/app.log | grep -i error | head -10
    echo
    echo "最近的警告日志:"
    tail -20 logs/app.log | grep -i warning | head -10
else
    echo "日志文件不存在"
fi

echo "=== 系统日志 ==="
journalctl -u enterprise-backend --no-pager -l 2>/dev/null | tail -20 | head -10
EOF
}

# 检查前端状态
check_frontend_status() {
    log_step "检查前端状态..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
echo "=== 前端文件状态 ==="
ls -la /usr/share/nginx/html/ | head -10
echo
echo "=== Nginx配置 ==="
if [ -f "/etc/nginx/sites-available/default" ]; then
    cat /etc/nginx/sites-available/default | head -20
else
    echo "默认Nginx配置文件不存在"
fi
echo
echo "=== Nginx错误日志 ==="
if [ -f "/var/log/nginx/error.log" ]; then
    tail -10 /var/log/nginx/error.log
else
    echo "Nginx错误日志文件不存在"
fi
EOF
}

# 测试API接口
test_api_endpoints() {
    log_step "测试API接口..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
echo "=== 测试产品列表API ==="
curl -s -w "HTTP状态码: %{http_code}\n" "http://localhost:8000/api/product/?page=1&page_size=10" 2>/dev/null | head -10 || echo "API请求失败"

echo "=== 测试分类列表API ==="
curl -s -w "HTTP状态码: %{http_code}\n" "http://localhost:8000/api/category/" 2>/dev/null | head -10 || echo "API请求失败"

echo "=== 测试健康检查 ==="
curl -s -w "HTTP状态码: %{http_code}\n" "http://localhost:8000/health" 2>/dev/null | head -10 || echo "API请求失败"
EOF
}

# 检查文件权限
check_file_permissions() {
    log_step "检查文件权限..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
echo "=== 项目目录权限 ==="
ls -la /var/www/enterprise/ 2>/dev/null | head -10 || echo "项目目录不存在"
echo
echo "=== 后端目录权限 ==="
ls -la /var/www/enterprise/enterprise-backend/ 2>/dev/null | head -10 || echo "后端目录不存在"
echo
echo "=== 上传目录权限 ==="
ls -la /var/www/enterprise/enterprise-backend/uploads/ 2>/dev/null | head -10 || echo "上传目录不存在"
echo
echo "=== 日志目录权限 ==="
ls -la /var/www/enterprise/enterprise-backend/logs/ 2>/dev/null | head -10 || echo "日志目录不存在"
EOF
}

# 检查Python环境
check_python_environment() {
    log_step "检查Python环境..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
echo "=== Python版本 ==="
python3 --version 2>/dev/null || echo "Python3未安装"
echo
echo "=== 虚拟环境状态 ==="
cd /var/www/enterprise/enterprise-backend 2>/dev/null || echo "后端目录不存在"
if [ -d "venv" ]; then
    echo "虚拟环境存在"
    source venv/bin/activate 2>/dev/null
    python --version 2>/dev/null || echo "虚拟环境中的Python不可用"
    pip list 2>/dev/null | head -10 || echo "pip命令不可用"
else
    echo "虚拟环境不存在"
fi
EOF
}

# 主函数
main() {
    log_info "开始诊断生产环境问题..."
    
    check_ssh_key
    test_ssh_connection
    
    if [ $? -eq 0 ]; then
        check_production_status
        check_database_status
        check_backend_logs
        check_frontend_status
        test_api_endpoints
        check_file_permissions
        check_python_environment
        
        log_info "诊断完成！请查看上述输出以识别问题"
    else
        log_error "无法连接到生产服务器，请检查网络和SSH配置"
        exit 1
    fi
}

# 执行主函数
main "$@"
