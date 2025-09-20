#!/bin/bash

# 生产环境更新脚本
# 从GitHub main分支拉取最新代码并重新部署

set -e

# 配置信息
SERVER_IP="47.243.41.30"
SERVER_PASSWORD="QAZwsx2025@"
PROJECT_NAME="enterprise"
LOCAL_GIT_VERSION="2.39.5"
SERVER_GIT_VERSION="2.27.0"

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

# 检查本地环境
check_local_env() {
    log_step "检查本地环境..."
    
    # 检查sshpass
    if ! command -v sshpass &> /dev/null; then
        log_error "sshpass未安装，正在安装..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install sshpass
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y sshpass || sudo yum install -y sshpass
        fi
    fi
    
    log_info "本地环境检查完成"
}

# 测试SSH连接
test_ssh_connection() {
    log_step "测试SSH连接..."
    
    if sshpass -p "$SERVER_PASSWORD" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SERVER_IP "echo 'SSH连接测试成功'" 2>/dev/null; then
        log_info "SSH连接正常"
        return 0
    else
        log_error "SSH连接失败，请检查服务器IP和密码"
        return 1
    fi
}

# 在服务器上更新代码
update_code() {
    log_step "在服务器上更新代码..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise

# 安装git（如果未安装）
if ! command -v git &> /dev/null; then
    echo "安装git..."
    # 清理yum缓存
    yum clean all
    # 更新yum源
    yum update -y
    # 安装git
    yum install -y git
    echo "Git安装完成"
fi

# 显示git版本
git --version

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

echo "代码更新完成"
EOF
}

# 更新后端
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

# 更新前端
update_frontend() {
    log_step "更新前端..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-frontend

# 清理node_modules和package-lock.json
rm -rf node_modules package-lock.json

# 安装依赖
npm install

# 检查vite是否安装
if ! npx vite --version &> /dev/null; then
    echo "安装vite..."
    npm install -g vite
fi

# 构建前端
npm run build

# 复制构建文件到Nginx目录
rm -rf /var/www/enterprise-frontend/*
cp -r dist/* /var/www/enterprise-frontend/

echo "前端更新完成"
EOF
}

# 重启服务
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

# 检查服务状态
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

# 显示更新信息
show_update_info() {
    log_info "生产环境更新完成！"
    echo
    echo "=== 更新信息 ==="
    echo "域名: https://catusfoto.top"
    echo "管理后台: https://catusfoto.top/admin"
    echo "服务器IP: $SERVER_IP"
    echo "本地Git版本: $LOCAL_GIT_VERSION"
    echo "服务器Git版本: $SERVER_GIT_VERSION"
    echo
    echo "=== 更新内容 ==="
    echo "1. 从GitHub main分支拉取最新代码"
    echo "2. 更新后端依赖和服务"
    echo "3. 重新构建前端"
    echo "4. 重启所有服务"
    echo
    echo "=== 重要提醒 ==="
    echo "1. 请检查网站是否正常运行"
    echo "2. 请检查管理后台是否可以正常登录"
    echo "3. 如有问题，可以回滚到备份: /var/www/enterprise/backup"
    echo "4. 服务器已安装Git，版本信息见上方日志"
}

# 主函数
main() {
    log_info "开始更新生产环境..."
    log_info "服务器IP: $SERVER_IP"
    
    check_local_env
    test_ssh_connection
    update_code
    update_backend
    update_frontend
    restart_services
    check_services
    show_update_info
}

# 执行主函数
main "$@" 