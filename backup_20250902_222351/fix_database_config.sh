#!/bin/bash

# 修复数据库连接配置
# 解决后端数据库连接问题

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

# 修复数据库配置
fix_database_config() {
    log_step "修复数据库连接配置..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-backend

# 检查当前环境配置
echo "=== 当前环境配置 ==="
cat production.env

# 修复数据库连接字符串
echo "=== 修复数据库配置 ==="
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

echo "数据库配置修复完成"
EOF
}

# 重启后端服务
restart_backend() {
    log_step "重启后端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 重启后端服务
systemctl restart enterprise-backend

# 等待服务启动
sleep 10

# 检查服务状态
systemctl status enterprise-backend --no-pager

# 测试API
curl -s http://localhost:8000/api/company/ | head -5
EOF
}

# 验证修复
verify_fix() {
    log_step "验证修复结果..."
    
    echo "=== 本地API测试 ==="
    curl -s https://catusfoto.top/api/company/ | head -5
    
    echo ""
    echo "=== 服务状态检查 ==="
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
systemctl status enterprise-backend --no-pager
EOF
}

# 主函数
main() {
    echo "🔧 开始修复数据库连接配置..."
    echo ""
    
    fix_database_config
    restart_backend
    verify_fix
    
    echo ""
    echo "✅ 数据库配置修复完成！"
    echo ""
    echo "📋 修复内容："
    echo "   - 数据库连接字符串已修复"
    echo "   - 使用正确的用户名: enterprise_user"
    echo "   - 后端服务已重启"
    echo ""
}

# 执行主函数
main "$@" 