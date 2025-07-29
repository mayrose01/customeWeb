#!/bin/bash

# 企业官网部署脚本 - 针对 catusfoto.top 和 47.243.41.30
# 使用方法: ./deploy_to_server.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置信息
SERVER_IP="47.243.41.30"
DOMAIN="catusfoto.top"
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

# 检查SSH连接
check_ssh_connection() {
    log_step "检查SSH连接..."
    
    # 尝试连接，如果失败则提示用户手动确认
    if ! ssh -o ConnectTimeout=10 -o BatchMode=no root@$SERVER_IP "echo 'SSH连接测试成功'" 2>/dev/null; then
        log_warn "SSH连接检查失败，但我们可以继续部署"
        log_info "请确保你可以手动SSH连接到服务器"
        log_info "如果遇到问题，请检查："
        log_info "1. 服务器IP地址是否正确"
        log_info "2. SSH服务是否正常运行"
        log_info "3. 防火墙是否允许SSH连接"
        
        read -p "是否继续部署？(y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "部署已取消"
            exit 1
        fi
    else
        log_info "SSH连接正常"
    fi
}

# 在服务器上安装依赖
install_server_deps() {
    log_step "在服务器上安装系统依赖..."
    
    ssh root@$SERVER_IP << 'EOF'
# 更新系统
apt update && apt upgrade -y

# 安装Python 3.11
apt install -y python3.11 python3.11-venv python3.11-dev

# 安装Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# 安装MySQL
apt install -y mysql-server

# 安装Nginx
apt install -y nginx

# 安装其他工具
apt install -y curl wget git unzip certbot python3-certbot-nginx

# 启动并启用MySQL
systemctl start mysql
systemctl enable mysql

# 启动并启用Nginx
systemctl start nginx
systemctl enable nginx

echo "系统依赖安装完成"
EOF
}

# 配置MySQL
setup_mysql() {
    log_step "配置MySQL数据库..."
    
    ssh root@$SERVER_IP << 'EOF'
# 创建数据库和用户
mysql -e "CREATE DATABASE IF NOT EXISTS enterprise_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS 'enterprise_user'@'localhost' IDENTIFIED BY 'enterprise_password_2024';"
mysql -e "GRANT ALL PRIVILEGES ON enterprise_db.* TO 'enterprise_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "MySQL配置完成"
EOF
}

# 上传项目文件
upload_project() {
    log_step "上传项目文件到服务器..."
    
    # 创建远程目录
    ssh root@$SERVER_IP "mkdir -p /var/www/$PROJECT_NAME"
    
    # 上传项目文件
    rsync -avz --exclude 'node_modules' --exclude '.git' --exclude 'venv' ./ root@$SERVER_IP:/var/www/$PROJECT_NAME/
    
    log_info "项目文件上传完成"
}

# 在服务器上部署后端
deploy_backend() {
    log_step "部署后端服务..."
    
    ssh root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-backend

# 创建虚拟环境
python3.11 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 创建必要目录
mkdir -p uploads logs

# 创建生产环境配置
cat > production.env << 'ENV_EOF'
DATABASE_URL=mysql://enterprise_user:enterprise_password_2024@localhost:3306/enterprise_db
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

# 导入数据库结构
if [ -f "../mysql/init.sql" ]; then
    mysql enterprise_db < ../mysql/init.sql
    echo "数据库结构导入完成"
fi

echo "后端部署完成"
EOF
}

# 在服务器上部署前端
deploy_frontend() {
    log_step "部署前端服务..."
    
    ssh root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-frontend

# 安装依赖
npm install

# 构建项目
npm run build

# 复制到Nginx目录
mkdir -p /var/www/enterprise-frontend
cp -r dist/* /var/www/enterprise-frontend/
chown -R www-data:www-data /var/www/enterprise-frontend

echo "前端部署完成"
EOF
}

# 配置Nginx
setup_nginx() {
    log_step "配置Nginx..."
    
    ssh root@$SERVER_IP << EOF
# 创建Nginx配置
cat > /etc/nginx/sites-available/catusfoto.top << 'NGINX_EOF'
server {
    listen 80;
    server_name catusfoto.top www.catusfoto.top;
    
    # 前端静态文件
    location / {
        root /var/www/enterprise-frontend;
        try_files \$uri \$uri/ /index.html;
        
        # 缓存设置
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # API代理
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # 上传文件代理
    location /uploads/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINX_EOF

# 启用站点
ln -sf /etc/nginx/sites-available/catusfoto.top /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 测试配置
nginx -t

# 重启Nginx
systemctl restart nginx

echo "Nginx配置完成"
EOF
}

# 创建系统服务
create_systemd_service() {
    log_step "创建系统服务..."
    
    ssh root@$SERVER_IP << EOF
# 创建后端服务文件
cat > /etc/systemd/system/enterprise-backend.service << 'SERVICE_EOF'
[Unit]
Description=Enterprise Backend API
After=network.target mysql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/$PROJECT_NAME/enterprise-backend
Environment=PATH=/var/www/$PROJECT_NAME/enterprise-backend/venv/bin
ExecStart=/var/www/$PROJECT_NAME/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# 重新加载systemd
systemctl daemon-reload

# 启动服务
systemctl enable enterprise-backend
systemctl start enterprise-backend

echo "系统服务创建完成"
EOF
}

# 配置防火墙
setup_firewall() {
    log_step "配置防火墙..."
    
    ssh root@$SERVER_IP << 'EOF'
# 允许SSH、HTTP、HTTPS
ufw allow ssh
ufw allow 80
ufw allow 443
ufw --force enable

echo "防火墙配置完成"
EOF
}

# 申请SSL证书
setup_ssl() {
    log_step "申请SSL证书..."
    
    ssh root@$SERVER_IP << 'EOF'
# 申请SSL证书
certbot --nginx -d catusfoto.top -d www.catusfoto.top --non-interactive --agree-tos --email admin@catusfoto.top

# 设置自动续期
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

echo "SSL证书配置完成"
EOF
}

# 显示部署信息
show_deployment_info() {
    log_info "部署完成！"
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
    ssh root@$SERVER_IP "systemctl status enterprise-backend --no-pager"
    ssh root@$SERVER_IP "systemctl status nginx --no-pager"
    ssh root@$SERVER_IP "systemctl status mysql --no-pager"
}

# 主函数
main() {
    log_info "开始部署企业官网到服务器..."
    log_info "服务器IP: $SERVER_IP"
    log_info "域名: $DOMAIN"
    
    check_ssh_connection
    install_server_deps
    setup_mysql
    upload_project
    deploy_backend
    deploy_frontend
    setup_nginx
    create_systemd_service
    setup_firewall
    setup_ssl
    show_deployment_info
}

# 执行主函数
main "$@" 