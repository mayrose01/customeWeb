#!/bin/bash

# 最终修复密码哈希脚本

SERVER_IP="YOUR_SERVER_IP_HERE"
SSH_PASSWORD="YOUR_SERVER_PASSWORD_HERE"

echo "🔧 最终修复密码哈希..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 检查password_hash字段的长度
echo "📋 检查password_hash字段的长度..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; DESCRIBE users;'"

# 2. 修改password_hash字段长度
echo ""
echo "🔄 修改password_hash字段长度..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; ALTER TABLE users MODIFY COLUMN password_hash VARCHAR(255);'"

# 3. 生成正确的密码哈希
echo ""
echo "🔐 生成正确的密码哈希..."
CORRECT_HASH=$(sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
hashed = pwd_context.hash('admin123')
print(hashed)
\"")

echo "正确的密码哈希: $CORRECT_HASH"

# 4. 更新数据库中的密码哈希
echo ""
echo "🔄 更新数据库中的密码哈希..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e \"USE enterprise_prod; UPDATE users SET password_hash = '$CORRECT_HASH' WHERE role = 'admin';\""

# 5. 验证更新结果
echo ""
echo "✅ 验证更新结果..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SELECT username, password_hash FROM users WHERE role = \"admin\";'"

# 6. 测试密码验证
echo ""
echo "🧪 测试密码验证..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
try:
    result = pwd_context.verify('admin123', '$CORRECT_HASH')
    print('密码验证结果:', result)
except Exception as e:
    print('密码验证错误:', e)
\""

# 7. 重启后端服务
echo ""
echo "🔄 重启后端服务..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl restart enterprise-backend"

# 8. 等待服务启动
echo ""
echo "⏳ 等待服务启动..."
sleep 5

# 9. 测试登录API
echo ""
echo "🧪 测试登录API..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -X POST http://localhost:8000/api/user/login -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin&password=admin123'"

echo ""
echo "=================================================="
echo "✅ 密码哈希最终修复完成"
echo ""
echo "🔑 管理员登录凭据:"
echo "   用户名: admin"
echo "   密码: admin123"
echo "   登录地址: https://catusfoto.top/admin/login" 