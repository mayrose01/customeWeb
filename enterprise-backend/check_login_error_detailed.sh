#!/bin/bash

# 详细检查登录错误脚本

SERVER_IP="47.243.41.30"
SSH_PASSWORD="Qing0325."

echo "🔍 详细检查登录错误..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 检查最新的后端服务日志
echo "📋 检查最新的后端服务日志..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "journalctl -u enterprise-backend --no-pager -n 20"

# 2. 检查用户表中的密码哈希
echo ""
echo "🗄️  检查用户表中的密码哈希..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_prod; SELECT username, password_hash FROM users WHERE role = \"admin\";'"

# 3. 测试密码验证
echo ""
echo "🧪 测试密码验证..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
try:
    # 获取数据库中的密码哈希
    import pymysql
    conn = pymysql.connect(
        host='localhost',
        user='enterprise_user',
        password='enterprise_password_2024',
        database='enterprise_prod'
    )
    cursor = conn.cursor()
    cursor.execute('SELECT password_hash FROM users WHERE role = \"admin\" LIMIT 1')
    result = cursor.fetchone()
    if result:
        stored_hash = result[0]
        print('数据库中的密码哈希:', stored_hash)
        # 测试密码验证
        result = pwd_context.verify('admin123', stored_hash)
        print('密码验证结果:', result)
    else:
        print('没有找到管理员用户')
    cursor.close()
    conn.close()
except Exception as e:
    print('错误:', e)
\""

# 4. 测试登录API并获取详细错误
echo ""
echo "🧪 测试登录API并获取详细错误..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -v -X POST http://localhost:8000/api/user/login -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin&password=admin123'"

echo ""
echo "=================================================="
echo "✅ 详细错误检查完成" 