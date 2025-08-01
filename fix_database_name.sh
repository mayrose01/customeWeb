#!/bin/bash

# 修改生产数据库名称为enterprise_prod
# 更符合生产环境命名规范

set -e

# 配置信息
SERVER_IP="47.243.41.30"
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

# 创建新的生产数据库
create_production_database() {
    log_step "创建新的生产数据库..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 创建新的生产数据库
mysql -u root -penterprise_password_2024 << 'MYSQL_EOF'
CREATE DATABASE IF NOT EXISTS enterprise_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON enterprise_prod.* TO 'enterprise_user'@'localhost';
GRANT ALL PRIVILEGES ON enterprise_prod.* TO 'enterprise_user'@'%';
FLUSH PRIVILEGES;
MYSQL_EOF

echo "生产数据库创建完成"
EOF
}

# 迁移数据
migrate_data() {
    log_step "迁移数据到新数据库..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 备份原数据库
mysqldump -u enterprise_user -penterprise_password_2024 enterprise_db > /tmp/enterprise_backup.sql

# 导入到新数据库
mysql -u enterprise_user -penterprise_password_2024 enterprise_prod < /tmp/enterprise_backup.sql

# 验证数据迁移
mysql -u enterprise_user -penterprise_password_2024 -e "USE enterprise_prod; SHOW TABLES;"

echo "数据迁移完成"
EOF
}

# 更新后端配置
update_backend_config() {
    log_step "更新后端配置..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-backend

# 更新生产环境配置
cat > production.env << 'ENV_EOF'
DATABASE_URL=mysql://enterprise_user:enterprise_password_2024@localhost:3306/enterprise_prod
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
ENV_EOF

echo "后端配置更新完成"
EOF
}

# 重启后端服务
restart_backend() {
    log_step "重启后端服务..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# 重启后端服务
systemctl restart enterprise-backend

# 等待服务启动
sleep 10

# 检查服务状态
systemctl status enterprise-backend --no-pager

# 测试API
curl -s http://localhost:8000/api/company/ | head -5
EOF
}

# 验证修复
verify_fix() {
    log_step "验证修复结果..."
    
    echo "=== 本地API测试 ==="
    curl -s https://catusfoto.top/api/company/ | head -5
    
    echo ""
    echo "=== 数据库连接信息 ==="
    echo "主机: $SERVER_IP"
    echo "端口: 3306"
    echo "数据库: enterprise_prod"
    echo "用户名: enterprise_user"
    echo "密码: enterprise_password_2024"
}

# 主函数
main() {
    echo "🔧 开始修改生产数据库名称..."
    echo ""
    
    create_production_database
    migrate_data
    update_backend_config
    restart_backend
    verify_fix
    
    echo ""
    echo "✅ 数据库名称修改完成！"
    echo ""
    echo "📋 修改内容："
    echo "   - 创建新数据库: enterprise_prod"
    echo "   - 迁移所有数据到新数据库"
    echo "   - 更新后端配置使用新数据库"
    echo "   - 重启后端服务"
    echo ""
    echo "🌐 新的数据库连接信息："
    echo "   - 数据库: enterprise_prod"
    echo "   - 用户名: enterprise_user"
    echo "   - 密码: enterprise_password_2024"
    echo ""
}

# 执行主函数
main "$@" 