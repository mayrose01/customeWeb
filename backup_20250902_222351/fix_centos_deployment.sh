#!/bin/bash

# CentOS部署修复脚本
# 解决网络连接、包管理器和服务安装问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置信息
SERVER_IP="YOUR_SERVER_IP_HERE"
SERVER_PASSWORD="YOUR_SERVER_PASSWORD_HERE"

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

# 修复网络和包管理器
fix_network_and_repos() {
    log_step "修复网络连接和包管理器..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 修复DNS解析
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 114.114.114.114" >> /etc/resolv.conf

# 修复CentOS 8仓库问题
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# 清理并重建缓存
yum clean all
yum makecache

# 更新系统
yum update -y

echo "网络和包管理器修复完成"
EOF
}

# 安装Python 3.9
install_python() {
    log_step "安装Python 3.9..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 安装Python 3.9
yum install -y python39 python39-pip python39-devel

# 创建软链接
ln -sf /usr/bin/python3.9 /usr/bin/python3
ln -sf /usr/bin/pip3.9 /usr/bin/pip3

# 验证安装
python3 --version
pip3 --version

echo "Python 3.9安装完成"
EOF
}

# 安装Node.js
install_nodejs() {
    log_step "安装Node.js..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 安装Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# 验证安装
node --version
npm --version

echo "Node.js安装完成"
EOF
}

# 安装MySQL (MariaDB)
install_mysql() {
    log_step "安装MySQL (MariaDB)..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 安装MariaDB
yum install -y mariadb-server mariadb

# 启动并启用服务
systemctl start mariadb
systemctl enable mariadb

# 配置MySQL安全设置
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('YOUR_DATABASE_PASSWORD_HERE');"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "FLUSH PRIVILEGES;"

# 创建数据库和用户
mysql -e "CREATE DATABASE IF NOT EXISTS enterprise_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS 'enterprise_user'@'localhost' IDENTIFIED BY 'YOUR_DATABASE_PASSWORD_HERE';"
mysql -e "GRANT ALL PRIVILEGES ON enterprise_db.* TO 'enterprise_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "MySQL安装和配置完成"
EOF
}

# 安装Nginx
install_nginx() {
    log_step "安装Nginx..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 安装Nginx
yum install -y nginx

# 启动并启用服务
systemctl start nginx
systemctl enable nginx

# 创建nginx用户（如果不存在）
useradd -r -s /bin/false nginx 2>/dev/null || true

echo "Nginx安装完成"
EOF
}

# 安装Certbot
install_certbot() {
    log_step "安装Certbot..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 安装EPEL仓库
yum install -y epel-release

# 安装Certbot
yum install -y certbot python3-certbot-nginx

echo "Certbot安装完成"
EOF
}

# 重新部署后端
redeploy_backend() {
    log_step "重新部署后端..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-backend

# 删除旧的虚拟环境
rm -rf venv

# 创建新的虚拟环境
python3.9 -m venv venv
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装依赖
pip install -r requirements.txt

# 创建必要目录
mkdir -p uploads logs

# 设置权限
chown -R nginx:nginx /var/www/enterprise

echo "后端重新部署完成"
EOF
}

# 重新部署前端
redeploy_frontend() {
    log_step "重新部署前端..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-frontend

# 安装依赖
npm install

# 构建项目
npm run build

# 复制到Nginx目录
mkdir -p /var/www/enterprise-frontend
cp -r dist/* /var/www/enterprise-frontend/
chown -R nginx:nginx /var/www/enterprise-frontend

echo "前端重新部署完成"
EOF
}

# 配置Nginx
configure_nginx() {
    log_step "配置Nginx..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 创建Nginx配置
cat > /etc/nginx/conf.d/catusfoto.top.conf << 'NGINX_EOF'
server {
    listen 80;
    server_name catusfoto.top www.catusfoto.top;
    
    # 前端静态文件
    location / {
        root /var/www/enterprise-frontend;
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
NGINX_EOF

# 删除默认配置
rm -f /etc/nginx/conf.d/default.conf

# 测试配置
nginx -t

# 重启Nginx
systemctl restart nginx

echo "Nginx配置完成"
EOF
}

# 重启后端服务
restart_backend_service() {
    log_step "重启后端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 重启后端服务
systemctl restart enterprise-backend
systemctl status enterprise-backend

echo "后端服务重启完成"
EOF
}

# 申请SSL证书
setup_ssl() {
    log_step "申请SSL证书..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 申请SSL证书
certbot --nginx -d catusfoto.top -d www.catusfoto.top --non-interactive --agree-tos --email admin@catusfoto.top

# 设置自动续期
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

echo "SSL证书配置完成"
EOF
}

# 显示修复结果
show_fix_results() {
    log_info "修复完成！"
    echo
    echo "=== 修复结果 ==="
    echo "域名: https://catusfoto.top"
    echo "管理后台: https://catusfoto.top/admin"
    echo "服务器IP: $SERVER_IP"
    echo
    echo "=== 服务状态 ==="
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status enterprise-backend --no-pager"
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status nginx --no-pager"
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status mariadb --no-pager"
}

# 主函数
main() {
    log_info "开始修复CentOS部署问题..."
    
    fix_network_and_repos
    install_python
    install_nodejs
    install_mysql
    install_nginx
    install_certbot
    redeploy_backend
    redeploy_frontend
    configure_nginx
    restart_backend_service
    setup_ssl
    show_fix_results
}

# 执行主函数
main "$@" 