#!/bin/bash

# 本地构建前端并上传到服务器
# 解决服务器上Node.js版本兼容性问题

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

# 本地构建前端
build_frontend_locally() {
    log_step "在本地构建前端..."
    
    cd enterprise-frontend
    
    # 检查本地Node.js版本
    log_info "检查本地Node.js版本..."
    node --version
    npm --version
    
    # 清理旧的构建文件
    log_info "清理旧的构建文件..."
    rm -rf node_modules package-lock.json dist
    
    # 安装依赖
    log_info "安装依赖..."
    npm install
    
    # 构建前端
    log_info "构建前端..."
    npm run build
    
    # 检查构建结果
    log_info "检查构建结果..."
    ls -la dist/
    
    cd ..
    
    log_info "本地构建完成"
}

# 上传构建文件到服务器
upload_build_to_server() {
    log_step "上传构建文件到服务器..."
    
    # 上传构建文件
    log_info "上传前端构建文件..."
    sshpass -p "$SERVER_PASSWORD" rsync -avz --delete enterprise-frontend/dist/ root@$SERVER_IP:/usr/share/nginx/html/
    
    # 设置权限
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 设置权限
chown -R nginx:nginx /usr/share/nginx/html/
chmod -R 755 /usr/share/nginx/html/

echo "构建文件上传完成"
EOF
}

# 验证上传结果
verify_upload() {
    log_step "验证上传结果..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
echo "=== Nginx静态文件检查 ==="
ls -la /usr/share/nginx/html/

echo "=== 网站访问测试 ==="
curl -I https://catusfoto.top | head -10

echo "=== 前端资源检查 ==="
curl -s https://catusfoto.top | grep -o 'src="[^"]*"' | head -5
EOF
}

# 主函数
main() {
    echo "🔧 开始本地构建并上传前端..."
    echo ""
    
    build_frontend_locally
    upload_build_to_server
    verify_upload
    
    echo "✅ 本地构建并上传完成！"
}

# 执行主函数
main "$@" 