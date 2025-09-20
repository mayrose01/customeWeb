#!/bin/bash

# 生产环境Docker部署脚本
# 适用于阿里云CentOS服务器

set -e

# 配置信息
SERVER_IP="47.243.41.30"
SERVER_PASSWORD="QAZwsx2025@"
PROJECT_NAME="enterprise"

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

# 在服务器上部署Docker环境
deploy_docker_environment() {
    log_step "在服务器上部署Docker环境..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise

# 安装Docker和Docker Compose（如果未安装）
if ! command -v docker &> /dev/null; then
    echo "安装Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
fi

if ! command -v docker-compose &> /dev/null; then
    echo "安装Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 拉取最新代码
git fetch origin
git reset --hard origin/main

# 创建生产环境配置文件
cat > .env.production << 'ENVEOF'
# 生产环境配置
MYSQL_ROOT_PASSWORD=your_production_mysql_root_password
MYSQL_DATABASE=enterprise_prod
MYSQL_USER=enterprise_user
MYSQL_PASSWORD=your_production_mysql_password
DATABASE_URL=mysql+pymysql://enterprise_user:your_production_mysql_password@mysql:3306/enterprise_prod
SECRET_KEY=your_production_secret_key_2024
CORS_ORIGINS=["https://catusfoto.top", "https://www.catusfoto.top"]
VITE_API_BASE_URL=https://catusfoto.top/api
VITE_APP_TITLE=企业官网
SMTP_SERVER=smtp.gmail.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
WORKERS=8
ENVEOF

# 停止现有服务
docker-compose -f docker-compose.yml -f docker-compose.prod.yml down

# 构建并启动生产环境
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --env-file .env.production build --no-cache
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --env-file .env.production up -d

echo "Docker生产环境部署完成"
EOF
}

# 检查服务状态
check_services() {
    log_step "检查服务状态..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
cd /var/www/enterprise

echo "=== Docker服务状态 ==="
docker-compose -f docker-compose.yml -f docker-compose.prod.yml ps

echo "=== 服务日志 ==="
docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs --tail=50
EOF
}

# 主函数
main() {
    log_info "开始部署生产环境Docker环境..."
    log_info "服务器IP: $SERVER_IP"
    
    check_local_env
    test_ssh_connection
    deploy_docker_environment
    check_services
    
    log_info "生产环境Docker部署完成！"
    echo
    echo "=== 部署信息 ==="
    echo "域名: https://catusfoto.top"
    echo "管理后台: https://catusfoto.top/admin"
    echo "服务器IP: $SERVER_IP"
    echo
    echo "=== 部署内容 ==="
    echo "1. 安装Docker和Docker Compose"
    echo "2. 从GitHub main分支拉取最新代码"
    echo "3. 构建Docker镜像"
    echo "4. 启动生产环境服务"
    echo
    echo "=== 重要提醒 ==="
    echo "1. 请检查网站是否正常运行"
    echo "2. 请检查管理后台是否可以正常登录"
    echo "3. 如有问题，可以查看日志: docker-compose logs"
}

# 执行主函数
main "$@"
