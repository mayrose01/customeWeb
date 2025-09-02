#!/bin/bash

# 在服务器上构建前端脚本
# 使用本地密钥，在远程服务器上构建前端

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

# 在服务器上构建前端
build_frontend_on_server() {
    log_step "在服务器上构建前端..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-frontend

# 检查Node.js版本
echo "=== Node.js版本 ==="
node --version
npm --version

# 清理旧的构建文件
rm -rf dist node_modules package-lock.json

# 设置npm镜像（如果需要）
# npm config set registry https://registry.npmmirror.com

# 安装依赖
echo "=== 安装依赖 ==="
npm install --no-optional --no-audit --no-fund

# 检查vite是否可用
if ! npx vite --version &> /dev/null; then
    echo "安装vite..."
    npm install vite@latest
fi

# 构建前端
echo "=== 开始构建 ==="
npm run build:prod

# 检查构建结果
if [ -d "dist" ]; then
    echo "=== 构建成功 ==="
    ls -la dist/
    
    # 复制构建文件到nginx目录
    echo "=== 部署到nginx目录 ==="
    rm -rf /var/www/enterprise-frontend/*
    cp -r dist/* /var/www/enterprise-frontend/
    
    # 设置权限
    chown -R nginx:nginx /var/www/enterprise-frontend/
    chmod -R 755 /var/www/enterprise-frontend/
    
    echo "前端构建和部署完成"
else
    echo "构建失败，dist目录不存在"
    exit 1
fi
EOF
    
    log_info "服务器端构建完成"
}

# 验证部署
verify_deployment() {
    log_step "验证部署..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
echo "=== 检查nginx目录 ==="
ls -la /var/www/enterprise-frontend/

echo "=== 检查nginx状态 ==="
systemctl status nginx --no-pager -l | head -10

echo "=== 测试nginx配置 ==="
nginx -t
EOF
    
    log_info "部署验证完成"
}

# 主函数
main() {
    log_info "开始在服务器上构建前端..."
    
    # 检查私钥
    if ! check_private_key; then
        exit 1
    fi
    
    # 测试连接
    if ! test_ssh_connection; then
        exit 1
    fi
    
    # 在服务器上构建
    build_frontend_on_server
    
    # 验证部署
    verify_deployment
    
    log_info "前端构建和部署完成！"
}

# 执行主函数
main "$@"
