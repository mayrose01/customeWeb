#!/bin/bash

# 安全前端部署脚本
# 使用本地密钥，不传输敏感信息到远程服务器

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
        log_error "请将从阿里云下载的.pem私钥文件放到项目目录中"
        return 1
    fi
    
    # 设置私钥文件权限
    chmod 600 "$SSH_PRIVATE_KEY"
    log_info "私钥文件权限设置完成"
    return 0
}

# 测试SSH连接
test_ssh_connection() {
    log_step "测试SSH连接..."
    
    if ssh -i "$SSH_PRIVATE_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -o ServerAliveCountMax=3 $SERVER_USERNAME@$SERVER_IP "echo 'SSH连接测试成功'; date" 2>/dev/null; then
        log_info "SSH连接正常"
        return 0
    else
        log_error "SSH连接失败，请检查私钥文件和服务器配置"
        return 1
    fi
}

# 本地构建前端
build_frontend_local() {
    log_step "本地构建前端..."
    
    cd enterprise-frontend
    
    # 清理旧的构建文件
    rm -rf dist
    
    # 设置Node.js内存限制
    export NODE_OPTIONS="--max-old-space-size=512"
    
    # 安装依赖
    log_info "安装npm依赖..."
    npm install --no-optional --no-audit --no-fund
    
    # 构建前端
    log_info "开始构建..."
    npm run build:prod
    
    if [ -d "dist" ]; then
        log_info "前端构建成功"
        cd ..
        return 0
    else
        log_error "前端构建失败"
        cd ..
        return 1
    fi
}

# 远程部署前端
deploy_frontend_remote() {
    log_step "远程部署前端..."
    
    # 创建临时压缩包
    log_info "创建部署包..."
    tar -czf frontend_deploy.tar.gz -C enterprise-frontend dist/
    
    # 上传到服务器
    log_info "上传构建文件到服务器..."
    scp -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no frontend_deploy.tar.gz $SERVER_USERNAME@$SERVER_IP:/tmp/
    
    # 在服务器上部署
    log_info "在服务器上部署..."
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
cd /var/www/enterprise

# 备份当前版本
if [ -d "enterprise-frontend" ]; then
    tar -czf enterprise-frontend-backup-$(date +%Y%m%d-%H%M%S).tar.gz enterprise-frontend/
fi

# 解压新版本
cd /tmp
tar -xzf frontend_deploy.tar.gz
rm -f frontend_deploy.tar.gz

# 部署到目标目录
rm -rf /var/www/enterprise/enterprise-frontend/*
cp -r dist/* /var/www/enterprise/enterprise-frontend/

# 设置权限
chown -R nginx:nginx /var/www/enterprise/enterprise-frontend/
chmod -R 755 /var/www/enterprise/enterprise-frontend/

# 重启nginx
systemctl restart nginx

echo "前端部署完成"
EOF
    
    # 清理本地临时文件
    rm -f frontend_deploy.tar.gz
    log_info "远程部署完成"
}

# 验证部署
verify_deployment() {
    log_step "验证部署..."
    
    # 检查服务器上的文件
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
echo "检查部署文件..."
ls -la /var/www/enterprise/enterprise-frontend/
echo "检查nginx状态..."
systemctl status nginx --no-pager -l
EOF
    
    log_info "部署验证完成"
}

# 主函数
main() {
    log_info "开始安全前端部署..."
    
    # 检查私钥
    if ! check_private_key; then
        exit 1
    fi
    
    # 测试连接
    if ! test_ssh_connection; then
        exit 1
    fi
    
    # 本地构建
    if ! build_frontend_local; then
        exit 1
    fi
    
    # 远程部署
    deploy_frontend_remote
    
    # 验证部署
    verify_deployment
    
    log_info "前端部署完成！"
}

# 执行主函数
main "$@"
