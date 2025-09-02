#!/bin/bash

# 企业网站完整部署脚本 (CentOS版本)
# 包含所有CentOS适配和数据库配置

set -e

# 配置信息
SERVER_IP="YOUR_SERVER_IP_HERE"
DOMAIN="catusfoto.top"
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

# 检查本地环境
check_local_env() {
    log_step "检查本地环境..."
    
    # 检查sshpass
    if ! command -v sshpass &> /dev/null; then
        log_error "sshpass未安装，正在安装..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install sshpass
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y sshpass || sudo yum install -y sshpass
        fi
    fi
    
    log_info "本地环境检查完成"
}

# 测试SSH连接
test_ssh_connection() {
    log_step "测试SSH连接..."
    
    if sshpass -p "$SERVER_PASSWORD" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SERVER_IP "echo 'SSH连接测试成功'" 2>/dev/null; then
        log_info "SSH连接正常"
        return 0
    else
        log_error "SSH连接失败，请检查服务器IP和密码"
        return 1
    fi
}

# 在服务器上安装系统依赖
install_server_deps() {
    log_step "在服务器上安装系统依赖 (CentOS)..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 更新系统
yum update -y

# 安装EPEL仓库
yum install -y epel-release

# 安装Python 3.9
yum install -y python39 python39-pip python39-devel

# 创建Python3软链接
ln -sf /usr/bin/python3.9 /usr/bin/python3

# 安装Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# 安装MySQL (MariaDB)
yum install -y mariadb-server mariadb

# 安装Nginx
yum install -y nginx

# 安装其他工具
yum install -y curl wget git unzip gcc

# 安装Certbot (CentOS)
yum install -y certbot python3-certbot-nginx

# 启动并启用MySQL
systemctl start mariadb
systemctl enable mariadb

# 启动并启用Nginx
systemctl start nginx
systemctl enable nginx

# 配置MySQL安全设置 (非交互式)
mysql -e "UPDATE mysql.user SET Password=PASSWORD('YOUR_DATABASE_PASSWORD_HERE') WHERE User='root';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "FLUSH PRIVILEGES;"

# 创建数据库和用户
mysql -u root -pYOUR_DATABASE_PASSWORD_HERE << 'MYSQL_EOF'
CREATE DATABASE IF NOT EXISTS enterprise_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'enterprise_user'@'localhost' IDENTIFIED BY 'YOUR_DATABASE_PASSWORD_HERE';
CREATE USER IF NOT EXISTS 'enterprise_user'@'%' IDENTIFIED BY 'YOUR_DATABASE_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON enterprise_db.* TO 'enterprise_user'@'localhost';
GRANT ALL PRIVILEGES ON enterprise_db.* TO 'enterprise_user'@'%';
FLUSH PRIVILEGES;
MYSQL_EOF

echo "系统依赖安装完成"
EOF
}

# 创建项目目录并上传代码
setup_project() {
    log_step "创建项目目录并上传代码..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 创建项目目录
mkdir -p /var/www/$PROJECT_NAME
cd /var/www/$PROJECT_NAME

# 设置目录权限
chown -R nginx:nginx /var/www/$PROJECT_NAME
chmod -R 755 /var/www/$PROJECT_NAME
EOF

    # 上传后端代码
    log_info "上传后端代码..."
    sshpass -p "$SERVER_PASSWORD" rsync -avz --delete enterprise-backend/ root@$SERVER_IP:/var/www/$PROJECT_NAME/enterprise-backend/
    
    # 上传前端代码
    log_info "上传前端代码..."
    sshpass -p "$SERVER_PASSWORD" rsync -avz --delete enterprise-frontend/ root@$SERVER_IP:/var/www/$PROJECT_NAME/enterprise-frontend/
}

# 部署后端
deploy_backend() {
    log_step "部署后端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-backend

# 创建虚拟环境
python3.9 -m venv venv
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装依赖
pip install -r requirements.txt
pip install python-dotenv

# 修复jose库问题
pip uninstall -y jose
pip install python-jose[cryptography]

# 创建必要目录
mkdir -p uploads logs
chown -R nginx:nginx uploads logs
chmod -R 755 uploads logs

# 创建生产环境配置
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

echo "后端部署完成"
EOF
}

# 部署前端
deploy_frontend() {
    log_step "部署前端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-frontend

# 安装依赖
npm install

# 修复Vite版本问题
npm install vite@4.5.0 --save-dev

# 构建前端
npm run build

# 复制到Nginx目录
cp -r dist/* /usr/share/nginx/html/

# 设置权限
chown -R nginx:nginx /usr/share/nginx/html/
chmod -R 755 /usr/share/nginx/html/

echo "前端部署完成"
EOF
}

# 配置Nginx
configure_nginx() {
    log_step "配置Nginx..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 创建Nginx配置文件
cat > /etc/nginx/conf.d/$DOMAIN.conf << 'NGINX_EOF'
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # SSL配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # 前端静态文件
    location / {
        root /usr/share/nginx/html;
        try_files \$uri \$uri/ /index.html;
        
        # 缓存配置
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # 后端API代理
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # 上传文件代理
    location /uploads/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
NGINX_EOF

# 删除默认配置
rm -f /etc/nginx/conf.d/default.conf

# 测试Nginx配置
nginx -t

# 重新加载Nginx
systemctl reload nginx

echo "Nginx配置完成"
EOF
}

# 创建系统服务
create_systemd_service() {
    log_step "创建系统服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 创建后端服务文件
cat > /etc/systemd/system/enterprise-backend.service << 'SERVICE_EOF'
[Unit]
Description=Enterprise Backend API
After=network.target mariadb.service

[Service]
Type=simple
User=nginx
Group=nginx
WorkingDirectory=/var/www/$PROJECT_NAME/enterprise-backend
Environment=PATH=/var/www/$PROJECT_NAME/enterprise-backend/venv/bin
ExecStart=/var/www/$PROJECT_NAME/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# 设置文件权限
chown -R nginx:nginx /var/www/$PROJECT_NAME

# 重新加载systemd
systemctl daemon-reload

# 启动服务
systemctl enable enterprise-backend
systemctl start enterprise-backend

echo "系统服务创建完成"
EOF
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 启动firewalld
systemctl start firewalld
systemctl enable firewalld

# 配置防火墙规则
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-port=8000/tcp

# 重新加载防火墙
firewall-cmd --reload

echo "防火墙配置完成"
EOF
}

# 申请SSL证书
setup_ssl() {
    log_step "申请SSL证书..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 申请SSL证书
certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

# 设置自动续期
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -

echo "SSL证书配置完成"
EOF
}

# 创建管理员账户
create_admin_user() {
    log_step "创建管理员账户..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 等待后端服务启动
sleep 10

# 创建管理员用户
mysql -u root -pYOUR_DATABASE_PASSWORD_HERE -e "USE enterprise_db; INSERT INTO users (username, password_hash, email, role, status, created_at, updated_at) VALUES ('admin', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vJQKq6y', 'admin@catusfoto.top', 'admin', 1, NOW(), NOW()) ON DUPLICATE KEY UPDATE updated_at = NOW();"

echo "管理员账户创建完成"
echo "用户名: admin"
echo "密码: admin123"
EOF
}

# 验证部署
verify_deployment() {
    log_step "验证部署..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
echo "=== 服务状态检查 ==="
systemctl status nginx mariadb enterprise-backend --no-pager

echo "=== 端口检查 ==="
netstat -tlnp | grep -E ':(80|443|3306|8000)'

echo "=== 数据库连接测试 ==="
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e "USE enterprise_db; SELECT 'Database connection successful' as status;"

echo "=== API测试 ==="
curl -s http://localhost:8000/api/company/ | head -5

echo "=== 网站访问测试 ==="
curl -I https://catusfoto.top | head -5
EOF
}

# 显示部署信息
show_deployment_info() {
    log_step "部署完成！"
    echo ""
    echo "🎉 企业网站部署成功！"
    echo ""
    echo "📋 部署信息："
    echo "   - 服务器IP: $SERVER_IP"
    echo "   - 域名: $DOMAIN"
    echo "   - 网站地址: https://$DOMAIN"
    echo "   - 后端API: https://$DOMAIN/api/"
    echo ""
    echo "🔐 数据库连接信息："
    echo "   - 主机: $SERVER_IP"
    echo "   - 端口: 3306"
    echo "   - 数据库: enterprise_db"
    echo "   - 用户名: enterprise_user"
    echo "   - 密码: YOUR_DATABASE_PASSWORD_HERE"
    echo ""
    echo "👤 管理员账户："
    echo "   - 用户名: admin"
    echo "   - 密码: admin123"
    echo ""
    echo "📊 服务状态检查："
    echo "   sshpass -p '$SERVER_PASSWORD' ssh root@$SERVER_IP 'systemctl status nginx mariadb enterprise-backend'"
    echo ""
    echo "🔧 常用命令："
    echo "   - 重启后端: sshpass -p '$SERVER_PASSWORD' ssh root@$SERVER_IP 'systemctl restart enterprise-backend'"
    echo "   - 查看日志: sshpass -p '$SERVER_PASSWORD' ssh root@$SERVER_IP 'journalctl -u enterprise-backend -f'"
    echo "   - 连接数据库: mysql -h $SERVER_IP -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE enterprise_db"
    echo ""
}

# 主函数
main() {
    echo "🚀 开始部署企业网站到CentOS服务器..."
    echo ""
    
    check_local_env
    test_ssh_connection
    install_server_deps
    setup_project
    deploy_backend
    deploy_frontend
    configure_nginx
    create_systemd_service
    configure_firewall
    setup_ssl
    create_admin_user
    verify_deployment
    show_deployment_info
    
    echo "✅ 部署完成！"
}

# 执行主函数
main "$@" 