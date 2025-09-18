#!/bin/bash

# 分步骤更新生产环境脚本
# 1. 更新后端
# 2. 本地构建前端
# 3. 上传前端到服务器

set -e

# 加载服务器配置
if [ -f "server_config.env" ]; then
    source server_config.env
else
    echo "错误: 找不到 server_config.env 配置文件"
    exit 1
fi

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

# 测试SSH连接
test_ssh_connection() {
    log_step "测试SSH连接..."
    
    if ssh -i "$SSH_PRIVATE_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP "echo 'SSH连接正常'" 2>/dev/null; then
        log_info "✅ SSH连接正常"
        return 0
    else
        log_error "❌ SSH连接失败"
        return 1
    fi
}

# 步骤1：更新后端
step1_update_backend() {
    log_step "步骤1：更新后端服务..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-backend

# 激活虚拟环境
source venv/bin/activate

# 检查Python版本
python3 --version

# 更新依赖
pip install --upgrade pip
pip install fastapi==0.104.1 uvicorn==0.24.0 sqlalchemy==2.0.23 python-multipart==0.0.6 python-jose[cryptography]==3.3.0 passlib[bcrypt]==1.7.4

# 创建systemd服务文件
cat > /etc/systemd/system/enterprise-backend.service << 'SERVICE_CONFIG'
[Unit]
Description=Enterprise Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/enterprise/enterprise-backend
Environment=PATH=/var/www/enterprise/enterprise-backend/venv/bin
ExecStart=/var/www/enterprise/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE_CONFIG

# 重新加载systemd配置
systemctl daemon-reload

# 启用并启动服务
systemctl enable enterprise-backend
systemctl start enterprise-backend

echo "后端服务更新完成"
EOF
}

# 步骤2：本地构建前端
step2_build_frontend_local() {
    log_step "步骤2：本地构建前端..."
    
    cd enterprise-frontend
    
    # 检查Node.js版本
    echo "Node.js版本:"
    node --version
    echo "npm版本:"
    npm --version
    
    # 清理之前的构建
    echo "清理之前的构建文件..."
    rm -rf node_modules package-lock.json dist
    
    # 安装依赖
    echo "安装前端依赖..."
    npm install
    
    # 检查vite
    echo "检查vite版本:"
    npx vite --version
    
    # 构建前端
    echo "开始构建前端..."
    npm run build
    
    # 检查构建结果
    if [ -d "dist" ]; then
        echo "✅ 前端构建成功！"
        echo "构建文件列表:"
        ls -la dist/
        
        # 创建部署包
        cd ..
        tar -czf frontend-build-$(date +%Y%m%d_%H%M%S).tar.gz -C enterprise-frontend/dist .
        echo "✅ 前端构建包创建完成"
        echo "构建包位置: $(pwd)/frontend-build-$(date +%Y%m%d_%H%M%S).tar.gz"
    else
        echo "❌ 前端构建失败"
        exit 1
    fi
    
    cd ..
}

# 步骤3：上传前端到服务器
step3_upload_frontend() {
    log_step "步骤3：上传前端到服务器..."
    
    # 找到最新的构建包
    FRONTEND_PACKAGE=$(ls -t frontend-build-*.tar.gz | head -1)
    
    if [ -z "$FRONTEND_PACKAGE" ]; then
        log_error "找不到前端构建包"
        exit 1
    fi
    
    echo "上传前端构建包: $FRONTEND_PACKAGE"
    
    # 上传到服务器
    scp -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$FRONTEND_PACKAGE" $SERVER_USERNAME@$SERVER_IP:/tmp/
    
    # 在服务器上解压和部署
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << EOF
cd /tmp
tar -xzf $FRONTEND_PACKAGE -C /var/www/enterprise-frontend/
rm -f $FRONTEND_PACKAGE

echo "前端文件部署完成"
echo "部署目录内容:"
ls -la /var/www/enterprise-frontend/
EOF
}

# 步骤4：修复Nginx配置
step4_fix_nginx() {
    log_step "步骤4：修复Nginx配置..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
# 备份原配置
cp /etc/nginx/conf.d/catusfoto.conf /etc/nginx/conf.d/catusfoto.conf.backup

# 创建正确的Nginx配置
cat > /etc/nginx/conf.d/catusfoto.conf << 'NGINX_CONFIG'
server {
    listen 80;
    server_name catusfoto.top www.catusfoto.top;
    
    root /var/www/enterprise-frontend;
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
        try_files $uri $uri/ /index.html;
    }
    
    # API代理到后端
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # 图片上传文件服务
    location /uploads/ {
        alias /var/www/enterprise/enterprise-backend/uploads/;
        expires 1y;
        add_header Cache-Control "public, immutable";
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
NGINX_CONFIG

# 测试配置
nginx -t

echo "Nginx配置修复完成"
EOF
}

# 步骤5：重启服务
step5_restart_services() {
    log_step "步骤5：重启服务..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
# 重启后端服务
systemctl restart enterprise-backend

# 重启Nginx
systemctl restart nginx

echo "服务重启完成"
EOF
}

# 步骤6：检查服务状态
step6_check_services() {
    log_step "步骤6：检查服务状态..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
echo "=== 后端服务状态 ==="
systemctl status enterprise-backend --no-pager

echo "=== Nginx服务状态 ==="
systemctl status nginx --no-pager

echo "=== 后端进程状态 ==="
ps aux | grep uvicorn | grep -v grep

echo "=== 端口监听状态 ==="
netstat -tlnp | grep -E ':(80|8000)'

echo "=== 前端文件状态 ==="
ls -la /var/www/enterprise-frontend/
EOF
}

# 显示更新信息
show_update_info() {
    log_info "分步骤更新完成！"
    echo
    echo "=== 更新内容 ==="
    echo "1. ✅ 更新了后端服务和依赖"
    echo "2. ✅ 本地构建了前端"
    echo "3. ✅ 上传了前端到服务器"
    echo "4. ✅ 修复了Nginx配置"
    echo "5. ✅ 重启了所有服务"
    echo
    echo "=== 重要提醒 ==="
    echo "1. 请检查网站是否正常运行: https://catusfoto.top"
    echo "2. 请检查管理后台是否可以正常登录: https://catusfoto.top/admin"
    echo "3. 请检查API是否正常工作: https://catusfoto.top/api/docs"
    echo "4. 前端已通过本地构建上传，避免了服务器资源不足问题"
}

# 主函数
main() {
    log_info "开始分步骤更新生产环境..."
    log_info "服务器IP: $SERVER_IP"
    log_info "服务器用户: $SERVER_USERNAME"
    
    # 测试连接
    if ! test_ssh_connection; then
        log_error "无法连接到服务器，请稍后重试"
        exit 1
    fi
    
    # 执行更新步骤
    step1_update_backend
    step2_build_frontend_local
    step3_upload_frontend
    step4_fix_nginx
    step5_restart_services
    step6_check_services
    show_update_info
}

# 执行主函数
main "$@"
