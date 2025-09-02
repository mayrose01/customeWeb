#!/bin/bash

# 使用Docker构建前端脚本
# 避免服务器内存不足问题

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
SERVER_PASSWORD="YOUR_SERVER_PASSWORD_HERE"

# 在服务器上使用Docker构建前端
build_with_docker() {
    log_step "使用Docker构建前端..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "安装Docker..."
    yum install -y docker
    systemctl start docker
    systemctl enable docker
fi

# 创建临时Dockerfile用于构建
cat > Dockerfile.frontend << 'DOCKERFILE'
FROM node:18-alpine

WORKDIR /app

# 复制package文件
COPY enterprise-frontend/package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制源代码
COPY enterprise-frontend/ .

# 构建应用
RUN npm run build

# 创建输出目录
RUN mkdir -p /output

# 复制构建产物
RUN cp -r dist/* /output/
DOCKERFILE

# 构建Docker镜像
echo "构建Docker镜像..."
docker build -f Dockerfile.frontend -t enterprise-frontend-build .

# 从容器中复制构建产物
echo "复制构建产物..."
docker create --name temp-frontend enterprise-frontend-build
docker cp temp-frontend:/output/. /var/www/enterprise-frontend/
docker rm temp-frontend

# 清理
rm -f Dockerfile.frontend
docker rmi enterprise-frontend-build

echo "前端构建完成"
EOF
}

# 主函数
main() {
    log_info "开始Docker化前端构建..."
    build_with_docker
    log_info "前端构建完成！"
}

# 执行主函数
main "$@" 