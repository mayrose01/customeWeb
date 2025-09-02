#!/bin/bash

# 修复后端环境变量设置
# 确保后端使用生产环境配置

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

# 修复环境变量
fix_environment_variable() {
    log_step "修复环境变量设置..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 更新后端服务文件，添加环境变量
cat > /etc/systemd/system/enterprise-backend.service << 'SERVICE_EOF'
[Unit]
Description=Enterprise Backend API
After=network.target mariadb.service

[Service]
Type=simple
User=nginx
Group=nginx
WorkingDirectory=/var/www/enterprise/enterprise-backend
Environment=PATH=/var/www/enterprise/enterprise-backend/venv/bin
Environment=ENV=production
ExecStart=/var/www/enterprise/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 2
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# 重新加载systemd
systemctl daemon-reload

echo "环境变量修复完成"
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
    echo "🔧 开始修复环境变量设置..."
    echo ""
    
    fix_environment_variable
    restart_backend
    verify_fix
    
    echo ""
    echo "✅ 环境变量修复完成！"
    echo ""
    echo "📋 修复内容："
    echo "   - 添加ENV=production环境变量"
    echo "   - 更新systemd服务配置"
    echo "   - 重启后端服务"
    echo ""
}

# 执行主函数
main "$@" 