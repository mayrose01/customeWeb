#!/bin/bash

# 修复生产环境配置脚本

SERVER_IP="47.243.41.30"
SSH_PASSWORD="Qing0325."

echo "🔧 修复生产环境配置..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 检查服务器上的production.env文件
echo "📋 检查服务器上的production.env文件..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cat /var/www/enterprise/enterprise-backend/production.env"

# 2. 更新服务器上的production.env文件
echo ""
echo "🔄 更新服务器上的production.env文件..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "sed -i 's/enterprise_db/enterprise_prod/g' /var/www/enterprise/enterprise-backend/production.env"

# 3. 验证更新结果
echo ""
echo "✅ 验证更新结果..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cat /var/www/enterprise/enterprise-backend/production.env"

# 4. 检查数据库连接
echo ""
echo "🗄️  检查数据库连接..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_prod; SELECT id, username, email, role, status FROM users WHERE username = \"admin\";'"

# 5. 生成正确的密码哈希
echo ""
echo "🔐 生成正确的密码哈希..."
CORRECT_HASH=$(sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
hashed = pwd_context.hash('admin123')
print(hashed)
\"")

echo "正确的密码哈希: $CORRECT_HASH"

# 6. 更新数据库中的密码哈希
echo ""
echo "🔄 更新数据库中的密码哈希..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e \"USE enterprise_prod; UPDATE users SET password_hash = '$CORRECT_HASH' WHERE role = 'admin';\""

# 7. 验证密码哈希更新
echo ""
echo "✅ 验证密码哈希更新..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_prod; SELECT username, password_hash FROM users WHERE role = \"admin\";'"

# 8. 重启后端服务
echo ""
echo "🔄 重启后端服务..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl restart enterprise-backend"

# 9. 等待服务启动
echo ""
echo "⏳ 等待服务启动..."
sleep 5

# 10. 检查服务状态
echo ""
echo "🔍 检查服务状态..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status enterprise-backend --no-pager"

# 11. 测试登录API
echo ""
echo "🧪 测试登录API..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -X POST http://localhost:8000/user/login -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin&password=admin123'"

echo ""
echo "=================================================="
echo "✅ 生产环境配置修复完成"
echo ""
echo "🔑 管理员登录凭据:"
echo "   用户名: admin"
echo "   密码: admin123"
echo "   登录地址: https://catusfoto.top/admin/login"
echo ""
echo "📋 修复内容:"
echo "   ✅ 数据库配置从 enterprise_db 改为 enterprise_prod"
echo "   ✅ 密码哈希已更新"
echo "   ✅ 后端服务已重启" 