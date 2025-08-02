#!/bin/bash

# 本地构建前端并上传到服务器
# 避免服务器资源不足问题

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
SERVER_IP="47.243.41.30"
SERVER_PASSWORD="Qing0325."

# 本地构建前端
build_locally() {
    log_step "在本地构建前端..."
    
    cd enterprise-frontend
    
    # 清理旧的构建文件
    log_info "清理旧的构建文件..."
    rm -rf node_modules package-lock.json dist
    
    # 安装依赖
    log_info "安装npm依赖..."
    npm install
    
    # 构建前端
    log_info "开始构建..."
    npm run build
    
    log_info "本地构建完成"
}

# 上传构建文件到服务器
upload_to_server() {
    log_step "上传构建文件到服务器..."
    
    # 创建临时压缩包
    log_info "创建构建文件压缩包..."
    cd enterprise-frontend/dist
    tar -czf ../../frontend-build.tar.gz .
    cd ../..
    
    # 上传到服务器
    log_info "上传到服务器..."
    sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no frontend-build.tar.gz root@$SERVER_IP:/tmp/
    
    # 在服务器上解压并部署
    log_info "在服务器上部署..."
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /tmp
tar -xzf frontend-build.tar.gz -C /var/www/enterprise-frontend/
rm -f frontend-build.tar.gz
echo "前端部署完成"
EOF
    
    # 清理本地临时文件
    rm -f frontend-build.tar.gz
    
    log_info "前端部署完成"
}

# 主函数
main() {
    log_info "开始本地构建并上传..."
    build_locally
    upload_to_server
    log_info "前端构建和部署完成！"
}

# 执行主函数
main "$@" 