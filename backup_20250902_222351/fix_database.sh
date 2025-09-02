#!/bin/bash

# 数据库配置修复脚本

set -e

# 配置信息
SERVER_IP="YOUR_SERVER_IP_HERE"
SERVER_PASSWORD="YOUR_SERVER_PASSWORD_HERE"

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 修复数据库配置
fix_database_config() {
    log_step "修复数据库配置..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 停止后端服务
systemctl stop enterprise-backend

# 重置MySQL root密码
systemctl stop mariadb
mysqld_safe --skip-grant-tables &
sleep 5

mysql -u root << 'MYSQL_EOF'
USE mysql;
UPDATE user SET authentication_string=PASSWORD('YOUR_DATABASE_PASSWORD_HERE') WHERE User='root';
FLUSH PRIVILEGES;
EXIT;
MYSQL_EOF

# 停止安全模式
pkill mysqld
sleep 3

# 启动MariaDB
systemctl start mariadb

# 创建数据库和用户
mysql -u root -pYOUR_DATABASE_PASSWORD_HERE << 'MYSQL_EOF'
CREATE DATABASE IF NOT EXISTS enterprise_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'enterprise_user'@'localhost' IDENTIFIED BY 'YOUR_DATABASE_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON enterprise_db.* TO 'enterprise_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_EOF

# 导入数据库结构
if [ -f "/var/www/enterprise/mysql/init.sql" ]; then
    mysql -u root -pYOUR_DATABASE_PASSWORD_HERE enterprise_db < /var/www/enterprise/mysql/init.sql
    echo "数据库结构导入完成"
fi

echo "数据库配置修复完成"
EOF
}

# 更新后端环境配置
update_backend_config() {
    log_step "更新后端环境配置..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-backend

# 更新生产环境配置
cat > production.env << 'ENV_EOF'
DATABASE_URL=mysql://enterprise_user:YOUR_DATABASE_PASSWORD_HERE@localhost:3306/enterprise_db
SECRET_KEY=catusfoto_enterprise_secret_key_2024
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
CORS_ORIGINS=["https://catusfoto.top", "http://catusfoto.top", "https://www.catusfoto.top", "http://www.catusfoto.top"]
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
UPLOAD_DIR=uploads
MAX_FILE_SIZE=2097152
LOG_LEVEL=INFO
LOG_FILE=logs/app.log
ENV_EOF

echo "后端环境配置更新完成"
EOF
}

# 重启后端服务
restart_backend() {
    log_step "重启后端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 重启后端服务
systemctl restart enterprise-backend

# 等待服务启动
sleep 10

# 检查服务状态
systemctl status enterprise-backend --no-pager

echo "后端服务重启完成"
EOF
}

# 测试API
test_api() {
    log_step "测试API..."
    
    echo "测试API连接..."
    curl -I https://catusfoto.top/api/
    
    echo "测试健康检查..."
    curl https://catusfoto.top/api/health
    
    echo "API测试完成"
}

# 显示最终状态
show_final_status() {
    log_info "数据库修复完成！"
    echo
    echo "=== 部署信息 ==="
    echo "域名: https://catusfoto.top"
    echo "管理后台: https://catusfoto.top/admin"
    echo "服务器IP: $SERVER_IP"
    echo
    echo "=== 数据库信息 ==="
    echo "数据库: enterprise_db"
    echo "用户名: enterprise_user"
    echo "密码: YOUR_DATABASE_PASSWORD_HERE"
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
}

# 主函数
main() {
    log_info "开始修复数据库配置..."
    
    fix_database_config
    update_backend_config
    restart_backend
    test_api
    show_final_status
}

# 执行主函数
main "$@" 