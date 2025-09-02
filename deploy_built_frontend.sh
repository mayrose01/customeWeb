#!/bin/bash

# 部署已构建的前端脚本
# 使用本地密钥，部署已经构建好的dist目录

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

# 检查前端构建文件
check_build_files() {
    log_step "检查前端构建文件..."
    
    if [ ! -d "enterprise-frontend/dist" ]; then
        log_error "前端构建文件不存在，请先运行 npm run build:prod"
        return 1
    fi
    
    log_info "前端构建文件检查完成"
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

# 部署前端
deploy_frontend() {
    log_step "开始部署前端..."
    
    # 创建部署包
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
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
echo "=== 检查部署文件 ==="
ls -la /var/www/enterprise/enterprise-frontend/
echo "=== 检查nginx状态 ==="
systemctl status nginx --no-pager -l | head -10
echo "=== 检查nginx配置 ==="
nginx -t
EOF
    
    log_info "部署验证完成"
}

# 主函数
main() {
    log_info "开始部署已构建的前端..."
    
    # 检查私钥
    if ! check_private_key; then
        exit 1
    fi
    
    # 检查构建文件
    if ! check_build_files; then
        exit 1
    fi
    
    # 测试连接
    if ! test_ssh_connection; then
        exit 1
    fi
    
    # 部署前端
    deploy_frontend
    
    # 验证部署
    verify_deployment
    
    log_info "前端部署完成！"
}

# 执行主函数
main "$@"
