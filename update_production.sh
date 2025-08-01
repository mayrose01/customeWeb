#!/bin/bash

# 生产环境代码更新脚本
# 用于将最新代码更新到阿里云CentOS服务器

set -e

# 配置信息
SERVER_IP="47.243.41.30"
DOMAIN="catusfoto.top"
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
    
    # 检查rsync
    if ! command -v rsync &> /dev/null; then
        log_error "rsync未安装，请先安装rsync"
        exit 1
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

# 备份当前版本
backup_current_version() {
    log_step "备份当前版本..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 创建备份目录
mkdir -p /var/www/backups/\$(date +%Y%m%d_%H%M%S)

# 备份当前代码
cp -r /var/www/$PROJECT_NAME /var/www/backups/\$(date +%Y%m%d_%H%M%S)/

# 备份数据库
mysqldump -u enterprise_user -penterprise_password_2024 enterprise_db > /var/www/backups/\$(date +%Y%m%d_%H%M%S)/database_backup.sql

echo "备份完成: /var/www/backups/\$(date +%Y%m%d_%H%M%S)/"
EOF
}

# 上传最新代码
upload_latest_code() {
    log_step "上传最新代码..."
    
    # 上传后端代码
    log_info "上传后端代码..."
    sshpass -p "$SERVER_PASSWORD" rsync -avz --delete enterprise-backend/ root@$SERVER_IP:/var/www/$PROJECT_NAME/enterprise-backend/
    
    # 上传前端代码
    log_info "上传前端代码..."
    sshpass -p "$SERVER_PASSWORD" rsync -avz --delete enterprise-frontend/ root@$SERVER_IP:/var/www/$PROJECT_NAME/enterprise-frontend/
    
    log_info "代码上传完成"
}

# 更新后端
update_backend() {
    log_step "更新后端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-backend

# 激活虚拟环境
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装/更新依赖
pip install -r requirements.txt

# 确保目录存在
mkdir -p uploads logs
chown -R nginx:nginx uploads logs
chmod -R 755 uploads logs

echo "后端更新完成"
EOF
}

# 更新前端
update_frontend() {
    log_step "更新前端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-frontend

# 安装依赖
npm install

# 构建前端
npm run build

# 复制到Nginx目录
cp -r dist/* /usr/share/nginx/html/

# 设置权限
chown -R nginx:nginx /usr/share/nginx/html/
chmod -R 755 /usr/share/nginx/html/

echo "前端更新完成"
EOF
}

# 重启服务
restart_services() {
    log_step "重启服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 重启后端服务
systemctl restart enterprise-backend

# 重新加载Nginx配置
systemctl reload nginx

# 等待服务启动
sleep 5

echo "服务重启完成"
EOF
}

# 验证更新
verify_update() {
    log_step "验证更新..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
echo "=== 服务状态检查 ==="
systemctl status nginx enterprise-backend --no-pager

echo "=== API测试 ==="
curl -s http://localhost:8000/api/company/ | head -5

echo "=== 网站访问测试 ==="
curl -I https://catusfoto.top | head -5

echo "=== 数据库连接测试 ==="
mysql -u enterprise_user -penterprise_password_2024 -e "USE enterprise_db; SELECT 'Database connection successful' as status;"
EOF
}

# 显示更新信息
show_update_info() {
    log_step "更新完成！"
    echo ""
    echo "🎉 代码更新成功！"
    echo ""
    echo "📋 更新信息："
    echo "   - 服务器IP: $SERVER_IP"
    echo "   - 域名: $DOMAIN"
    echo "   - 网站地址: https://$DOMAIN"
    echo "   - 后端API: https://$DOMAIN/api/"
    echo ""
    echo "🔧 常用命令："
    echo "   - 查看服务状态: sshpass -p '$SERVER_PASSWORD' ssh root@$SERVER_IP 'systemctl status enterprise-backend'"
    echo "   - 查看后端日志: sshpass -p '$SERVER_PASSWORD' ssh root@$SERVER_IP 'journalctl -u enterprise-backend -f'"
    echo "   - 重启后端: sshpass -p '$SERVER_PASSWORD' ssh root@$SERVER_IP 'systemctl restart enterprise-backend'"
    echo "   - 重启Nginx: sshpass -p '$SERVER_PASSWORD' ssh root@$SERVER_IP 'systemctl reload nginx'"
    echo ""
}

# 主函数
main() {
    echo "🚀 开始更新生产环境代码..."
    echo ""
    
    check_local_env
    test_ssh_connection
    backup_current_version
    upload_latest_code
    update_backend
    update_frontend
    restart_services
    verify_update
    show_update_info
    
    echo "✅ 更新完成！"
}

# 执行主函数
main "$@" 