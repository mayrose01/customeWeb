#!/bin/bash

# 企业官网快速部署脚本
# 适用于Ubuntu/CentOS服务器

set -e

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

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "请不要使用root用户运行此脚本"
        exit 1
    fi
}

# 检测操作系统
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        log_error "无法检测操作系统"
        exit 1
    fi
    
    log_info "检测到操作系统: $OS $VER"
}

# 安装系统依赖
install_system_deps() {
    log_step "安装系统依赖..."
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        sudo apt update
        sudo apt install -y python3.11 python3.11-venv python3.11-dev \
            mysql-server nginx curl wget git unzip
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        sudo yum update -y
        sudo yum install -y python3 python3-pip mysql-server nginx curl wget git unzip
    else
        log_error "不支持的操作系统: $OS"
        exit 1
    fi
}

# 安装Node.js
install_nodejs() {
    log_step "安装Node.js..."
    
    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    log_info "Node.js版本: $(node --version)"
    log_info "npm版本: $(npm --version)"
}

# 配置MySQL
setup_mysql() {
    log_step "配置MySQL..."
    
    # 启动MySQL服务
    sudo systemctl start mysql
    sudo systemctl enable mysql
    
    # 创建数据库和用户
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS enterprise_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    sudo mysql -e "CREATE USER IF NOT EXISTS 'enterprise_user'@'localhost' IDENTIFIED BY 'enterprise_password';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON enterprise_db.* TO 'enterprise_user'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"
    
    # 导入数据库结构
    if [[ -f "mysql/init.sql" ]]; then
        sudo mysql enterprise_db < mysql/init.sql
        log_info "数据库结构导入完成"
    fi
}

# 配置Nginx
setup_nginx() {
    log_step "配置Nginx..."
    
    # 创建Nginx配置
    sudo tee /etc/nginx/sites-available/enterprise > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;
    
    # 前端静态文件
    location / {
        root /var/www/enterprise-frontend/dist;
        try_files $uri $uri/ /index.html;
        
        # 缓存设置
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # API代理
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # 上传文件代理
    location /uploads/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
    
    # 启用站点
    sudo ln -sf /etc/nginx/sites-available/enterprise /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # 测试配置
    sudo nginx -t
    
    # 重启Nginx
    sudo systemctl restart nginx
    sudo systemctl enable nginx
}

# 部署后端
deploy_backend() {
    log_step "部署后端..."
    
    cd enterprise-backend
    
    # 创建虚拟环境
    python3.11 -m venv venv
    source venv/bin/activate
    
    # 安装依赖
    pip install -r requirements.txt
    
    # 创建必要目录
    mkdir -p uploads logs
    
    # 创建生产环境配置
    if [[ ! -f "production.env" ]]; then
        cp production.env.example production.env
        log_warn "请编辑 production.env 文件配置数据库连接等信息"
    fi
    
    cd ..
}

# 部署前端
deploy_frontend() {
    log_step "部署前端..."
    
    cd enterprise-frontend
    
    # 安装依赖
    npm install
    
    # 构建项目
    npm run build
    
    # 复制到Nginx目录
    sudo mkdir -p /var/www/enterprise-frontend
    sudo cp -r dist/* /var/www/enterprise-frontend/
    sudo chown -R www-data:www-data /var/www/enterprise-frontend
    
    cd ..
}

# 创建系统服务
create_systemd_service() {
    log_step "创建系统服务..."
    
    # 创建后端服务文件
    sudo tee /etc/systemd/system/enterprise-backend.service > /dev/null << EOF
[Unit]
Description=Enterprise Backend API
After=network.target mysql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=$(pwd)/enterprise-backend
Environment=PATH=$(pwd)/enterprise-backend/venv/bin
ExecStart=$(pwd)/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
    
    # 重新加载systemd
    sudo systemctl daemon-reload
    
    # 启动服务
    sudo systemctl enable enterprise-backend
    sudo systemctl start enterprise-backend
}

# 配置防火墙
setup_firewall() {
    log_step "配置防火墙..."
    
    # 允许SSH、HTTP、HTTPS
    sudo ufw allow ssh
    sudo ufw allow 80
    sudo ufw allow 443
    sudo ufw --force enable
    
    log_info "防火墙已配置"
}

# 显示部署信息
show_deployment_info() {
    log_info "部署完成！"
    echo
    echo "=== 部署信息 ==="
    echo "前端地址: http://$(curl -s ifconfig.me)"
    echo "后端API: http://$(curl -s ifconfig.me):8000"
    echo "管理后台: http://$(curl -s ifconfig.me)/admin"
    echo
    echo "=== 默认账户 ==="
    echo "用户名: admin"
    echo "密码: admin123"
    echo
    echo "=== 服务状态 ==="
    sudo systemctl status enterprise-backend --no-pager
    sudo systemctl status nginx --no-pager
    sudo systemctl status mysql --no-pager
    echo
    echo "=== 重要提醒 ==="
    echo "1. 请修改默认管理员密码"
    echo "2. 请配置SSL证书"
    echo "3. 请修改数据库密码"
    echo "4. 请配置域名解析"
}

# 主函数
main() {
    log_info "开始企业官网部署..."
    
    check_root
    detect_os
    install_system_deps
    install_nodejs
    setup_mysql
    setup_nginx
    deploy_backend
    deploy_frontend
    create_systemd_service
    setup_firewall
    show_deployment_info
}

# 执行主函数
main "$@" 