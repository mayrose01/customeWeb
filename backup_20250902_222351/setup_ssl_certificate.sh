#!/bin/bash

# SSL证书配置脚本
# 使用Let's Encrypt免费证书

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 服务器配置
SERVER_IP="YOUR_SERVER_IP_HERE"
SERVER_USERNAME="root"
SSH_PRIVATE_KEY="./enterprise_prod.pem"
DOMAIN="catusfoto.top"

# 检查私钥文件
check_private_key() {
    log_step "检查私钥文件..."
    
    if [ ! -f "$SSH_PRIVATE_KEY" ]; then
        log_error "私钥文件不存在: $SSH_PRIVATE_KEY"
        return 1
    fi
    
    chmod 600 "$SSH_PRIVATE_KEY"
    log_info "私钥文件权限设置完成"
    return 0
}

# 测试SSH连接
test_ssh_connection() {
    log_step "测试SSH连接..."
    
    if ssh -i "$SSH_PRIVATE_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -o ServerAliveCountMax=3 $SERVER_USERNAME@$SERVER_IP "echo 'SSH连接测试成功'" 2>/dev/null; then
        log_info "SSH连接正常"
        return 0
    else
        log_error "SSH连接失败"
        return 1
    fi
}

# 安装certbot
install_certbot() {
    log_step "安装certbot..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
# 安装EPEL仓库
yum install -y epel-release

# 安装certbot
yum install -y certbot python3-certbot-nginx

# 检查安装
certbot --version
EOF
    
    log_info "certbot安装完成"
}

# 获取SSL证书
get_ssl_certificate() {
    log_step "获取SSL证书..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << EOF
# 停止nginx
systemctl stop nginx

# 获取证书
certbot certonly --standalone -d $DOMAIN -d www.$DOMAIN --email admin@$DOMAIN --agree-tos --non-interactive

# 检查证书
ls -la /etc/letsencrypt/live/$DOMAIN/
EOF
    
    log_info "SSL证书获取完成"
}

# 配置nginx HTTPS
configure_nginx_https() {
    log_step "配置nginx HTTPS..."
    
    # 创建HTTPS配置
    cat > nginx_https.conf << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # SSL配置
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    root /var/www/enterprise/enterprise-frontend;
    index index.html;
    
    # 启用gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # 处理Vue Router的history模式
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # API代理到后端
    location /api/ {
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
    
    # 错误页面
    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
}
EOF
    
    # 上传配置
    scp -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no nginx_https.conf $SERVER_USERNAME@$SERVER_IP:/etc/nginx/conf.d/
    
    # 应用配置
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
# 测试配置
nginx -t

# 启动nginx
systemctl start nginx

# 检查状态
systemctl status nginx --no-pager -l | head -10

# 检查端口
netstat -tlnp | grep :443
EOF
    
    # 清理本地文件
    rm -f nginx_https.conf
    
    log_info "nginx HTTPS配置完成"
}

# 设置自动续期
setup_auto_renewal() {
    log_step "设置自动续期..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
# 创建续期脚本
cat > /root/renew_ssl.sh << 'RENEW_SCRIPT'
#!/bin/bash
certbot renew --quiet
systemctl reload nginx
RENEW_SCRIPT

chmod +x /root/renew_ssl.sh

# 添加到crontab（每月1号凌晨2点续期）
(crontab -l 2>/dev/null; echo "0 2 1 * * /root/renew_ssl.sh") | crontab -

echo "自动续期设置完成"
EOF
    
    log_info "自动续期设置完成"
}

# 验证HTTPS
verify_https() {
    log_step "验证HTTPS配置..."
    
    # 等待一下让nginx完全启动
    sleep 5
    
    # 测试HTTPS
    if curl -I https://$DOMAIN 2>/dev/null | head -1 | grep -q "200"; then
        log_info "✅ HTTPS配置成功！"
        echo "网站地址: https://$DOMAIN"
    else
        log_warn "⚠️ HTTPS可能还在配置中，请稍等片刻再试"
    fi
}

# 主函数
main() {
    log_info "开始配置SSL证书..."
    
    # 检查私钥
    if ! check_private_key; then
        exit 1
    fi
    
    # 测试连接
    if ! test_ssh_connection; then
        exit 1
    fi
    
    # 安装certbot
    install_certbot
    
    # 获取证书
    get_ssl_certificate
    
    # 配置nginx
    configure_nginx_https
    
    # 设置自动续期
    setup_auto_renewal
    
    # 验证HTTPS
    verify_https
    
    log_info "SSL证书配置完成！"
}

# 执行主函数
main "$@"
