#!/bin/bash

# 最终修复脚本
# 解决jose库、前端构建和MySQL配置问题

set -e

# 配置信息
SERVER_IP="47.243.41.30"
SERVER_PASSWORD="Qing0325."

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

# 修复jose库问题
fix_jose_library() {
    log_step "修复jose库问题..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-backend

# 激活虚拟环境
source venv/bin/activate

# 卸载有问题的jose库
pip uninstall -y jose

# 安装正确的python-jose库
pip install python-jose[cryptography]

echo "jose库修复完成"
EOF
}

# 修复前端构建问题
fix_frontend_build() {
    log_step "修复前端构建问题..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-frontend

# 降级Vite版本以兼容Node.js 18
npm install vite@^4.0.0 --save-dev
npm install @vitejs/plugin-vue@^4.0.0 --save-dev

# 重新构建
npm run build

# 复制到Nginx目录
mkdir -p /var/www/enterprise-frontend
cp -r dist/* /var/www/enterprise-frontend/
chown -R nginx:nginx /var/www/enterprise-frontend

echo "前端构建修复完成"
EOF
}

# 配置MySQL
configure_mysql() {
    log_step "配置MySQL..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 启动MariaDB
systemctl start mariadb

# 设置root密码
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'enterprise_password_2024';"

# 创建数据库和用户
mysql -u root -penterprise_password_2024 -e "CREATE DATABASE IF NOT EXISTS enterprise_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -penterprise_password_2024 -e "CREATE USER IF NOT EXISTS 'enterprise_user'@'localhost' IDENTIFIED BY 'enterprise_password_2024';"
mysql -u root -penterprise_password_2024 -e "GRANT ALL PRIVILEGES ON enterprise_db.* TO 'enterprise_user'@'localhost';"
mysql -u root -penterprise_password_2024 -e "FLUSH PRIVILEGES;"

# 导入数据库结构
if [ -f "/var/www/enterprise/mysql/init.sql" ]; then
    mysql -u root -penterprise_password_2024 enterprise_db < /var/www/enterprise/mysql/init.sql
    echo "数据库结构导入完成"
fi

echo "MySQL配置完成"
EOF
}

# 重启后端服务
restart_backend() {
    log_step "重启后端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 重启后端服务
systemctl restart enterprise-backend

# 等待服务启动
sleep 5

# 检查服务状态
systemctl status enterprise-backend --no-pager

echo "后端服务重启完成"
EOF
}

# 测试网站访问
test_website() {
    log_step "测试网站访问..."
    
    echo "测试HTTP访问..."
    curl -I http://catusfoto.top
    
    echo "测试HTTPS访问..."
    curl -I https://catusfoto.top
    
    echo "测试API访问..."
    curl -I https://catusfoto.top/api/
    
    echo "网站访问测试完成"
}

# 显示最终状态
show_final_status() {
    log_info "最终修复完成！"
    echo
    echo "=== 部署信息 ==="
    echo "域名: https://catusfoto.top"
    echo "管理后台: https://catusfoto.top/admin"
    echo "服务器IP: $SERVER_IP"
    echo
    echo "=== 默认账户 ==="
    echo "用户名: admin"
    echo "密码: admin123"
    echo
    echo "=== 重要提醒 ==="
    echo "1. 请立即修改默认管理员密码"
    echo "2. 请配置邮件服务（编辑 production.env）"
    echo "3. 请修改数据库密码"
    echo "4. 请检查域名解析是否生效"
    echo
    echo "=== 服务状态 ==="
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status enterprise-backend --no-pager"
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status nginx --no-pager"
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status mariadb --no-pager"
}

# 主函数
main() {
    log_info "开始最终修复..."
    
    fix_jose_library
    fix_frontend_build
    configure_mysql
    restart_backend
    test_website
    show_final_status
}

# 执行主函数
main "$@" 