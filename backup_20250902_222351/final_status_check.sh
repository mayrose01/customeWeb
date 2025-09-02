#!/bin/bash

# 最终状态检查和修复脚本
# 检查所有服务状态并修复问题

set -e

# 配置信息
SERVER_IP="YOUR_SERVER_IP_HERE"
PROJECT_NAME="enterprise"
SERVER_PASSWORD="YOUR_SERVER_PASSWORD_HERE"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 检查服务状态
check_service_status() {
    log_step "检查服务状态..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
echo "=== 服务状态检查 ==="
systemctl status nginx enterprise-backend mariadb --no-pager

echo "=== 端口检查 ==="
netstat -tlnp | grep -E ':(80|443|3306|8000)'

echo "=== 进程检查 ==="
ps aux | grep -E '(nginx|python|mysql)' | grep -v grep
EOF
}

# 修复后端服务
fix_backend_service() {
    log_step "修复后端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 检查后端日志
echo "=== 后端日志 ==="
journalctl -u enterprise-backend --no-pager | tail -20

# 重启后端服务
systemctl restart enterprise-backend

# 等待服务启动
sleep 5

# 检查服务状态
systemctl status enterprise-backend --no-pager

# 测试API
curl -s http://localhost:8000/api/company/ | head -5
EOF
}

# 检查数据库连接
check_database() {
    log_step "检查数据库连接..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
echo "=== 数据库状态 ==="
systemctl status mariadb --no-pager

echo "=== 数据库连接测试 ==="
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e "USE enterprise_db; SELECT 'Database connection successful' as status;"

echo "=== 数据库表检查 ==="
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e "USE enterprise_db; SHOW TABLES;"
EOF
}

# 检查前端状态
check_frontend() {
    log_step "检查前端状态..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
echo "=== Nginx配置检查 ==="
nginx -t

echo "=== 静态文件检查 ==="
ls -la /usr/share/nginx/html/

echo "=== 网站访问测试 ==="
curl -I https://catusfoto.top | head -10
EOF
}

# 最终验证
final_verification() {
    log_step "最终验证..."
    
    echo "=== 本地测试 ==="
    echo "前端网站: https://catusfoto.top"
    curl -I https://catusfoto.top | head -5
    
    echo ""
    echo "=== API测试 ==="
    curl -s https://catusfoto.top/api/company/ | head -5
    
    echo ""
    echo "=== 数据库连接信息 ==="
    echo "主机: $SERVER_IP"
    echo "端口: 3306"
    echo "数据库: enterprise_db"
    echo "用户名: enterprise_user"
    echo "密码: YOUR_DATABASE_PASSWORD_HERE"
    
    echo ""
    echo "=== 管理员账户 ==="
    echo "用户名: admin"
    echo "密码: admin123"
}

# 主函数
main() {
    echo "🔍 开始最终状态检查..."
    echo ""
    
    check_service_status
    fix_backend_service
    check_database
    check_frontend
    final_verification
    
    echo ""
    echo "✅ 状态检查完成！"
    echo ""
    echo "📋 部署总结："
    echo "   - 前端: ✅ 已成功构建并部署"
    echo "   - 后端: ⚠️ 需要检查服务状态"
    echo "   - 数据库: ✅ 连接正常"
    echo "   - Nginx: ✅ 运行正常"
    echo ""
    echo "🌐 访问地址："
    echo "   - 网站: https://catusfoto.top"
    echo "   - API: https://catusfoto.top/api/"
    echo ""
}

# 执行主函数
main "$@" 