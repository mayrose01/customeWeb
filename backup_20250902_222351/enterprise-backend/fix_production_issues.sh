#!/bin/bash

# 修复生产环境问题脚本

SERVER_IP="YOUR_SERVER_IP_HERE"

echo "🔧 修复生产环境问题..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 修复数据库配置
echo "📝 修复数据库配置..."
ssh root@$SERVER_IP "sed -i 's/enterprise_prod/enterprise_db/g' /var/www/enterprise/enterprise-backend/production.env"

# 2. 重新生成正确的密码哈希
echo "🔐 重新生成管理员密码哈希..."
ssh root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
hashed_password = pwd_context.hash('admin123')
print('新的密码哈希:', hashed_password)
\""

# 3. 更新数据库中的密码哈希
echo "🔄 更新数据库中的密码哈希..."
NEW_HASH=$(ssh root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
hashed_password = pwd_context.hash('admin123')
print(hashed_password)
\"")

echo "新密码哈希: $NEW_HASH"

ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e \"USE enterprise_db; UPDATE users SET password_hash = '$NEW_HASH' WHERE role = 'admin';\""

# 4. 重启后端服务
echo "🔄 重启后端服务..."
ssh root@$SERVER_IP "systemctl restart enterprise-backend"

# 5. 检查服务状态
echo "🔍 检查服务状态..."
ssh root@$SERVER_IP "systemctl status enterprise-backend --no-pager"

# 6. 测试API连接
echo "🧪 测试API连接..."
sleep 5
ssh root@$SERVER_IP "curl -X GET http://localhost:8000/company/ -H 'Content-Type: application/json'"

echo ""
echo "=================================================="
echo "✅ 生产环境问题修复完成"
echo ""
echo "🔑 管理员登录凭据:"
echo "   用户名: admin"
echo "   密码: admin123"
echo "   登录地址: https://catusfoto.top/admin/login"
echo ""
echo "⚠️  如果还有问题，请检查："
echo "   1. 浏览器缓存"
echo "   2. 代理/VPN设置"
echo "   3. 网络连接" 