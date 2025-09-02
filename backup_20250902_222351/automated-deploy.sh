#!/bin/bash

# 自动化部署脚本
# 包含：代码更新、本地构建、上传部署、服务重启

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

# 配置信息
SERVER_IP="YOUR_SERVER_IP_HERE"
SERVER_PASSWORD="YOUR_SERVER_PASSWORD_HERE"
LOCAL_GIT_VERSION="2.39.5"
SERVER_GIT_VERSION="2.27.0"

# 1. 更新本地代码
update_local_code() {
    log_step "更新本地代码..."
    
    # 拉取最新代码
    git fetch origin
    git reset --hard origin/main
    
    log_info "本地代码更新完成"
}

# 2. 本地构建前端
build_frontend_locally() {
    log_step "本地构建前端..."
    
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
    cd ..
}

# 3. 上传并部署到服务器
deploy_to_server() {
    log_step "部署到服务器..."
    
    # 创建构建文件压缩包
    log_info "创建构建文件压缩包..."
    cd enterprise-frontend/dist
    tar -czf ../../frontend-build.tar.gz .
    cd ../..
    
    # 上传到服务器
    log_info "上传到服务器..."
    sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no frontend-build.tar.gz root@$SERVER_IP:/tmp/
    
    # 在服务器上部署
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

# 4. 更新服务器代码
update_server_code() {
    log_step "更新服务器代码..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise

# 备份当前代码
if [ -d "backup" ]; then
    rm -rf backup
fi
mkdir -p backup
cp -r enterprise-backend backup/
cp -r enterprise-frontend backup/

# 拉取最新代码
git fetch origin
git reset --hard origin/main

echo "服务器代码更新完成"
EOF
}

# 5. 更新后端
update_backend() {
    log_step "更新后端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-backend

# 激活虚拟环境
source venv/bin/activate

# 更新依赖
pip install -r requirements.txt

# 重启后端服务
systemctl restart enterprise-backend

echo "后端更新完成"
EOF
}

# 6. 重启服务
restart_services() {
    log_step "重启服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 重启后端服务
systemctl restart enterprise-backend

# 重启Nginx
systemctl restart nginx

echo "服务重启完成"
EOF
}

# 7. 检查服务状态
check_services() {
    log_step "检查服务状态..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
echo "=== 后端服务状态 ==="
systemctl status enterprise-backend --no-pager

echo "=== Nginx服务状态 ==="
systemctl status nginx --no-pager

echo "=== MySQL服务状态 ==="
systemctl status mysql --no-pager
EOF
}

# 8. 显示部署信息
show_deploy_info() {
    log_info "自动化部署完成！"
    echo
    echo "=== 部署信息 ==="
    echo "域名: https://catusfoto.top"
    echo "管理后台: https://catusfoto.top/admin"
    echo "服务器IP: $SERVER_IP"
    echo "本地Git版本: $LOCAL_GIT_VERSION"
    echo "服务器Git版本: $SERVER_GIT_VERSION"
    echo
    echo "=== 部署内容 ==="
    echo "1. 从GitHub main分支拉取最新代码"
    echo "2. 本地构建前端（避免服务器资源不足）"
    echo "3. 上传构建文件到服务器"
    echo "4. 更新后端依赖和服务"
    echo "5. 重启所有服务"
    echo
    echo "=== 重要提醒 ==="
    echo "1. 请检查网站是否正常运行"
    echo "2. 请检查管理后台是否可以正常登录"
    echo "3. 如有问题，可以回滚到备份: /var/www/enterprise/backup"
    echo "4. 下次更新只需运行: ./automated-deploy.sh"
}

# 主函数
main() {
    log_info "开始自动化部署..."
    log_info "服务器IP: $SERVER_IP"
    
    update_local_code
    build_frontend_locally
    deploy_to_server
    update_server_code
    update_backend
    restart_services
    check_services
    show_deploy_info
}

# 执行主函数
main "$@" 