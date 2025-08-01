#!/bin/bash

# 修复密码哈希脚本

SERVER_IP="47.243.41.30"

echo "🔧 修复密码哈希问题..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 生成正确的密码哈希
echo "🔐 生成正确的密码哈希..."
ssh root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
import bcrypt
password = 'admin123'
salt = bcrypt.gensalt()
hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
print('正确的密码哈希:', hashed.decode('utf-8'))
\""

# 2. 获取正确的密码哈希
CORRECT_HASH=$(ssh root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
import bcrypt
password = 'admin123'
salt = bcrypt.gensalt()
hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
print(hashed.decode('utf-8'))
\"")

echo "正确的密码哈希: $CORRECT_HASH"

# 3. 更新数据库中的密码哈希
echo ""
echo "🔄 更新数据库中的密码哈希..."
ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e \"USE enterprise_prod; UPDATE users SET password_hash = '$CORRECT_HASH' WHERE role = 'admin';\""

# 4. 验证更新结果
echo ""
echo "✅ 验证更新结果..."
ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_prod; SELECT username, password_hash FROM users WHERE role = \"admin\";'"

# 5. 测试密码验证
echo ""
echo "🧪 测试密码验证..."
ssh root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
import bcrypt
password = 'admin123'
stored_hash = '$CORRECT_HASH'
result = bcrypt.checkpw(password.encode('utf-8'), stored_hash.encode('utf-8'))
print('密码验证结果:', result)
\""

# 6. 重启后端服务
echo ""
echo "🔄 重启后端服务..."
ssh root@$SERVER_IP "systemctl restart enterprise-backend"

# 7. 等待服务启动
echo ""
echo "⏳ 等待服务启动..."
sleep 5

# 8. 测试登录API
echo ""
echo "🧪 测试登录API..."
ssh root@$SERVER_IP "curl -X POST http://localhost:8000/user/login -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin&password=admin123'"

echo ""
echo "=================================================="
echo "✅ 密码哈希修复完成"
echo ""
echo "🔑 管理员登录凭据:"
echo "   用户名: admin"
echo "   密码: admin123"
echo "   登录地址: https://catusfoto.top/admin/login" 