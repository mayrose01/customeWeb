#!/bin/bash

# 检查登录错误脚本

SERVER_IP="YOUR_SERVER_IP_HERE"

echo "🔍 检查登录错误..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 检查后端服务日志
echo "📋 检查后端服务日志..."
ssh root@$SERVER_IP "journalctl -u enterprise-backend --no-pager -n 50"

# 2. 检查数据库连接
echo ""
echo "🗄️  检查数据库连接..."
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SELECT id, username, email, role, status FROM users WHERE username = \"admin\";'"

# 3. 测试登录API
echo ""
echo "🧪 测试登录API..."
ssh root@$SERVER_IP "curl -X POST http://localhost:8000/user/login -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin&password=admin123'"

# 4. 检查bcrypt版本
echo ""
echo "🔐 检查bcrypt版本..."
ssh root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && pip show bcrypt"

# 5. 测试密码验证
echo ""
echo "🔍 测试密码验证..."
ssh root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
try:
    result = pwd_context.verify('admin123', '\$2b\$12\$FBG9zqtgk68tmPt5uJjzDe34TK42ebelhWJfrwaI8F15JN1R.u1zK')
    print('密码验证结果:', result)
except Exception as e:
    print('密码验证错误:', e)
\""

# 6. 检查用户密码哈希
echo ""
echo "🔍 检查用户密码哈希..."
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SELECT username, password_hash FROM users WHERE username = \"admin\";'"

echo ""
echo "=================================================="
echo "✅ 错误检查完成" 