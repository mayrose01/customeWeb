#!/bin/bash

# 完整生产环境配置脚本
# 根据项目环境配置结构设置生产环境

set -e

# 加载服务器配置
if [ -f "server_config.env" ]; then
    source server_config.env
else
    echo "错误: 找不到 server_config.env 配置文件"
    exit 1
fi

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

# 测试SSH连接
test_ssh_connection() {
    log_step "测试SSH连接..."
    
    if ssh -i "$SSH_PRIVATE_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP "echo 'SSH连接正常'" 2>/dev/null; then
        log_info "✅ SSH连接正常"
        return 0
    else
        log_error "❌ SSH连接失败"
        return 1
    fi
}

# 步骤1：配置MySQL数据库
step1_setup_mysql() {
    log_step "步骤1：配置MySQL数据库..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
echo "=== 检查MySQL服务状态 ==="
systemctl status mysql --no-pager

echo "=== 设置MySQL root密码 ==="
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';" 2>/dev/null && echo "✅ root密码设置成功" || echo "⚠️ root密码可能已设置"

echo "=== 创建生产环境数据库 ==="
mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS enterprise_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null && echo "✅ 数据库创建成功" || echo "❌ 数据库创建失败"

echo "=== 检查数据库列表 ==="
mysql -u root -proot -e "SHOW DATABASES;" 2>/dev/null | grep enterprise_prod && echo "✅ 数据库存在" || echo "❌ 数据库不存在"

echo "=== 测试数据库连接 ==="
mysql -u root -proot -e "USE enterprise_prod; SELECT 1;" 2>/dev/null && echo "✅ 数据库连接成功" || echo "❌ 数据库连接失败"
EOF
}

# 步骤2：配置生产环境文件
step2_setup_production_env() {
    log_step "步骤2：配置生产环境文件..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-backend

echo "=== 备份原配置 ==="
cp production.env production.env.backup

echo "=== 创建正确的生产环境配置 ==="
cat > production.env << 'PROD_CONFIG'
# 生产环境配置
DATABASE_URL=mysql+pymysql://root:root@localhost:3306/enterprise_prod

SECRET_KEY=catusfoto_enterprise_secret_key_2024
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
CORS_ORIGINS=["https://catusfoto.top", "http://catusfoto.top", "https://www.catusfoto.top", "http://www.catusfoto.top"]

SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
UPLOAD_DIR=uploads
MAX_FILE_SIZE=2097152
LOG_LEVEL=INFO
LOG_FILE=logs/app.log
PROD_CONFIG

echo "=== 检查配置文件 ==="
cat production.env | grep DATABASE_URL

echo "配置创建完成"
EOF
}

# 步骤3：修复代码中的硬编码配置
step3_fix_hardcoded_config() {
    log_step "步骤3：修复代码中的硬编码配置..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-backend

echo "=== 检查并修复database.py ==="
if [ -f "app/database.py" ]; then
    cp app/database.py app/database.py.backup
    sed -i 's/mysql_test/localhost/g' app/database.py
    sed -i 's/test_user/root/g' app/database.py
    sed -i 's/test_password/root/g' app/database.py
    sed -i 's/enterprise_test/enterprise_prod/g' app/database.py
    echo "✅ database.py修复完成"
else
    echo "⚠️ database.py文件不存在"
fi

echo "=== 检查并修复config.py ==="
if [ -f "app/config.py" ]; then
    cp app/config.py app/config.py.backup
    # 确保使用环境变量
    sed -i 's/mysql_test/localhost/g' app/config.py
    sed -i 's/test_user/root/g' app/config.py
    sed -i 's/test_password/root/g' app/config.py
    sed -i 's/enterprise_test/enterprise_prod/g' app/config.py
    echo "✅ config.py修复完成"
else
    echo "⚠️ config.py文件不存在"
fi

echo "硬编码配置修复完成"
EOF
}

# 步骤4：重启后端服务
step4_restart_backend() {
    log_step "步骤4：重启后端服务..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
systemctl restart enterprise-backend
echo "✅ 后端服务重启完成"
EOF
}

# 步骤5：验证服务状态
step5_verify_services() {
    log_step "步骤5：验证服务状态..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
echo "=== 后端服务状态 ==="
systemctl status enterprise-backend --no-pager

echo "=== 端口监听状态 ==="
netstat -tlnp | grep -E ':(80|8000|3306)'

echo "=== 检查API是否可访问 ==="
curl -I http://localhost:8000/docs 2>/dev/null | head -5 && echo "✅ API访问成功" || echo "❌ API访问失败"

echo "=== 检查数据库连接 ==="
cd /var/www/enterprise/enterprise-backend
source venv/bin/activate
python -c "from app.config import settings; print('DATABASE_URL:', settings.DATABASE_URL)" 2>/dev/null && echo "✅ 配置读取成功" || echo "❌ 配置读取失败"
EOF
}

# 显示配置信息
show_config_info() {
    log_info "生产环境配置完成！"
    echo
    echo "=== 环境配置对比 ==="
    echo "🏠 本地开发环境: mysql+pymysql://root:root@localhost:3306/enterprise_dev"
    echo "🐳 Docker测试环境: mysql://test_user:test_password@mysql_test:3306/enterprise_test"
    echo "🚀 阿里云生产环境: mysql+pymysql://root:root@localhost:3306/enterprise_prod"
    echo
    echo "=== 生产环境信息 ==="
    echo "服务器IP: $SERVER_IP"
    echo "域名: $PROD_DOMAIN"
    echo "前端: $PROD_FRONTEND_URL"
    echo "后端API: $PROD_BACKEND_URL"
    echo "管理后台: $PROD_ADMIN_URL"
    echo
    echo "=== 重要提醒 ==="
    echo "1. 请检查网站是否正常运行: $PROD_FRONTEND_URL"
    echo "2. 请检查管理后台是否可以正常登录: $PROD_ADMIN_URL"
    echo "3. 请检查API是否正常工作: $PROD_BACKEND_URL/docs"
    echo "4. 生产环境配置已与本地开发环境保持一致"
}

# 主函数
main() {
    log_info "开始配置生产环境..."
    log_info "服务器IP: $SERVER_IP"
    log_info "服务器用户: $SERVER_USERNAME"
    log_info "生产环境数据库: $PROD_DATABASE_URL"
    
    # 测试连接
    if ! test_ssh_connection; then
        log_error "无法连接到服务器，请检查网络和服务器状态"
        exit 1
    fi
    
    # 执行配置步骤
    step1_setup_mysql
    step2_setup_production_env
    step3_fix_hardcoded_config
    step4_restart_backend
    step5_verify_services
    show_config_info
}

# 执行主函数
main "$@"
