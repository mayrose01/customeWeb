#!/bin/bash

# 前端构建脚本
# 优化内存使用，避免被系统杀死

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

build_frontend() {
    log_step "开始构建前端..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-frontend

# 清理旧的构建文件
rm -rf node_modules package-lock.json dist

# 设置Node.js内存限制
export NODE_OPTIONS="--max-old-space-size=512"

# 安装依赖（分步进行）
log_info "安装npm依赖..."
npm install --no-optional --no-audit --no-fund

# 检查vite是否可用
if ! npx vite --version &> /dev/null; then
    log_info "安装vite..."
    npm install vite@latest
fi

# 构建前端
log_info "开始构建..."
npm run build

# 复制构建文件到nginx目录
log_info "复制构建文件..."
rm -rf /var/www/enterprise-frontend/*
cp -r dist/* /var/www/enterprise-frontend/

log_info "前端构建完成"
EOF
}

# 主函数
main() {
    log_info "开始前端构建..."
    build_frontend
    log_info "前端构建完成！"
}

# 执行主函数
main "$@" 