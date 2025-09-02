#!/bin/bash

# 前端部署脚本 - 只更新前端文件到生产服务器
# 使用方法: ./deploy_frontend_only.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置信息
SERVER_IP="YOUR_SERVER_IP_HERE"
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
    
    if ! ssh -o ConnectTimeout=10 -o BatchMode=no root@$SERVER_IP "echo 'SSH连接测试成功'" 2>/dev/null; then
        log_error "SSH连接失败，请检查："
        log_error "1. 服务器IP地址是否正确: $SERVER_IP"
        log_error "2. SSH服务是否正常运行"
        log_error "3. 防火墙是否允许SSH连接"
        exit 1
    else
        log_info "SSH连接正常"
    fi
}

# 构建前端
build_frontend() {
    log_step "构建前端项目..."
    
    # 切换到前端目录
    cd enterprise-frontend
    
    # 设置生产环境变量
    export VITE_APP_ENV=production
    export VITE_API_BASE_URL=https://catusfoto.top/api
    export VITE_UPLOAD_PATH=/uploads
    export VITE_PUBLIC_PATH=/
    export VITE_DEBUG=false
    
    log_info "环境变量设置完成:"
    log_info "VITE_APP_ENV: $VITE_APP_ENV"
    log_info "VITE_API_BASE_URL: $VITE_API_BASE_URL"
    
    # 清理之前的构建
    rm -rf dist/
    
    # 执行生产环境构建
    npm run build:prod
    
    # 检查构建结果
    if [ -d "dist" ]; then
        log_info "构建成功！"
        
        # 检查是否还有localhost:8000的引用
        if grep -r "localhost:8000" dist/ > /dev/null 2>&1; then
            log_warn "警告: 构建文件中仍包含 localhost:8000 引用"
            grep -r "localhost:8000" dist/ | head -3
        else
            log_info "✓ 构建文件中没有 localhost:8000 引用"
        fi
        
        # 检查API配置
        if grep -r "catusfoto.top" dist/ > /dev/null 2>&1; then
            log_info "✓ 构建文件中包含正确的生产环境API地址"
        else
            log_warn "警告: 构建文件中没有找到生产环境API地址"
        fi
    else
        log_error "构建失败！"
        exit 1
    fi
}

# 备份当前版本
backup_current_version() {
    log_step "备份当前版本..."
    
    ssh root@$SERVER_IP << EOF
# 创建备份目录
mkdir -p /var/www/backups/\$(date +%Y%m%d_%H%M%S)

# 备份当前版本
if [ -d "/var/www/enterprise-frontend" ]; then
    cp -r /var/www/enterprise-frontend /var/www/backups/\$(date +%Y%m%d_%H%M%S)/enterprise-frontend
    echo "当前版本已备份到 /var/www/backups/\$(date +%Y%m%d_%H%M%S)/enterprise-frontend"
else
    echo "没有找到当前版本，跳过备份"
fi
EOF
}

# 上传新版本
upload_new_version() {
    log_step "上传新版本到服务器..."
    
    # 创建远程目录
    ssh root@$SERVER_IP "mkdir -p /var/www/enterprise-frontend"
    
    # 上传构建文件
    rsync -avz --delete dist/ root@$SERVER_IP:/var/www/enterprise-frontend/
    
    # 设置正确的权限
    ssh root@$SERVER_IP "chown -R nginx:nginx /var/www/enterprise-frontend"
    
    log_info "前端文件上传完成"
}

# 重启Nginx
restart_nginx() {
    log_step "重启Nginx服务..."
    
    ssh root@$SERVER_IP << 'EOF'
# 测试Nginx配置
nginx -t

# 重启Nginx
systemctl restart nginx

echo "Nginx重启完成"
EOF
}

# 验证部署
verify_deployment() {
    log_step "验证部署..."
    
    # 检查文件是否上传成功
    ssh root@$SERVER_IP << 'EOF'
echo "检查文件上传情况:"
ls -la /var/www/enterprise-frontend/
echo
echo "检查index.html内容:"
head -5 /var/www/enterprise-frontend/index.html
EOF
    
    # 检查网站是否可访问
    log_info "检查网站可访问性..."
    if curl -s -o /dev/null -w "%{http_code}" https://catusfoto.top/ | grep -q "200"; then
        log_info "✓ 网站可以正常访问"
    else
        log_warn "警告: 网站可能无法正常访问，请手动检查"
    fi
}

# 显示部署信息
show_deployment_info() {
    log_info "前端部署完成！"
    echo
    echo "=== 部署信息 ==="
    echo "域名: https://catusfoto.top"
    echo "服务器IP: $SERVER_IP"
    echo "前端目录: /var/www/enterprise-frontend"
    echo
    echo "=== 验证步骤 ==="
    echo "1. 访问 https://catusfoto.top"
    echo "2. 打开浏览器开发者工具"
    echo "3. 检查Network标签中的API请求"
    echo "4. 确认API请求指向 https://catusfoto.top/api"
    echo
    echo "=== 服务状态 ==="
    ssh root@$SERVER_IP "systemctl status nginx --no-pager"
}

# 主函数
main() {
    log_info "开始部署前端到生产服务器..."
    log_info "服务器IP: $SERVER_IP"
    log_info "域名: $DOMAIN"
    
    check_ssh_connection
    build_frontend
    backup_current_version
    upload_new_version
    restart_nginx
    verify_deployment
    show_deployment_info
}

# 执行主函数
main "$@" 