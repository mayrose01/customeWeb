#!/bin/bash

# 修复生产环境问题脚本
# 解决虚拟环境、前端构建和后端服务问题

set -e

# 配置信息
SERVER_IP="47.243.41.30"
PROJECT_NAME="enterprise"
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

# 修复后端虚拟环境
fix_backend_venv() {
    log_step "修复后端虚拟环境..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-backend

# 删除旧的虚拟环境
rm -rf venv

# 创建新的虚拟环境
python3.9 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装依赖
pip install -r requirements.txt

# 确保目录存在
mkdir -p uploads logs
chown -R nginx:nginx uploads logs
chmod -R 755 uploads logs

echo "后端虚拟环境修复完成"
EOF
}

# 修复前端构建问题
fix_frontend_build() {
    log_step "修复前端构建问题..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-frontend

# 删除node_modules和package-lock.json
rm -rf node_modules package-lock.json

# 安装兼容的Vite版本
npm install vite@4.5.0 --save-dev

# 安装依赖
npm install

# 构建前端
npm run build

# 复制到Nginx目录
cp -r dist/* /usr/share/nginx/html/

# 设置权限
chown -R nginx:nginx /usr/share/nginx/html/
chmod -R 755 /usr/share/nginx/html/

echo "前端构建修复完成"
EOF
}

# 修复后端服务配置
fix_backend_service() {
    log_step "修复后端服务配置..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 重新创建后端服务文件
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
ExecStart=/var/www/enterprise/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 2
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# 设置文件权限
chown -R nginx:nginx /var/www/enterprise

# 重新加载systemd
systemctl daemon-reload

# 启动服务
systemctl enable enterprise-backend
systemctl start enterprise-backend

echo "后端服务配置修复完成"
EOF
}

# 验证修复
verify_fixes() {
    log_step "验证修复结果..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
echo "=== 服务状态检查 ==="
systemctl status nginx enterprise-backend --no-pager

echo "=== 虚拟环境检查 ==="
ls -la /var/www/enterprise/enterprise-backend/venv/bin/

echo "=== API测试 ==="
sleep 10
curl -s http://localhost:8000/api/company/ | head -5

echo "=== 网站访问测试 ==="
curl -I https://catusfoto.top | head -5

echo "=== 数据库连接测试 ==="
mysql -u enterprise_user -penterprise_password_2024 -e "USE enterprise_db; SELECT 'Database connection successful' as status;"
EOF
}

# 主函数
main() {
    echo "🔧 开始修复生产环境问题..."
    echo ""
    
    fix_backend_venv
    fix_frontend_build
    fix_backend_service
    verify_fixes
    
    echo "✅ 修复完成！"
}

# 执行主函数
main "$@" 