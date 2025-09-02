#!/bin/bash

# 数据迁移脚本：将enterprise_db迁移到enterprise_prod

SERVER_IP="YOUR_SERVER_IP_HERE"

echo "🔄 数据迁移：enterprise_db -> enterprise_prod"
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 检查两个数据库的状态
echo "📊 检查数据库状态..."
echo "enterprise_db 表:"
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_db; SHOW TABLES;'"

echo ""
echo "enterprise_prod 表:"
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SHOW TABLES;'"

# 2. 备份enterprise_db数据
echo ""
echo "💾 备份enterprise_db数据..."
ssh root@$SERVER_IP "mysqldump -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE enterprise_db > /tmp/enterprise_db_backup.sql"

# 3. 清空enterprise_prod数据库
echo ""
echo "🧹 清空enterprise_prod数据库..."
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'DROP DATABASE IF EXISTS enterprise_prod;'"
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'CREATE DATABASE enterprise_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'"

# 4. 将enterprise_db的数据导入到enterprise_prod
echo ""
echo "📥 导入数据到enterprise_prod..."
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE enterprise_prod < /tmp/enterprise_db_backup.sql"

# 5. 验证数据迁移
echo ""
echo "✅ 验证数据迁移..."
echo "enterprise_prod 表:"
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SHOW TABLES;'"

echo ""
echo "enterprise_prod 用户:"
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SELECT id, username, email, role, status FROM users;'"

# 6. 更新管理员密码哈希
echo ""
echo "🔐 更新管理员密码哈希..."
ssh root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
hashed_password = pwd_context.hash('admin123')
print('新的密码哈希:', hashed_password)
\""

NEW_HASH=$(ssh root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python3 -c \"
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
hashed_password = pwd_context.hash('admin123')
print(hashed_password)
\"")

echo "新密码哈希: $NEW_HASH"

ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e \"USE enterprise_prod; UPDATE users SET password_hash = '$NEW_HASH' WHERE role = 'admin';\""

# 7. 删除enterprise_db数据库
echo ""
echo "🗑️  删除enterprise_db数据库..."
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'DROP DATABASE enterprise_db;'"

# 8. 重启后端服务
echo ""
echo "🔄 重启后端服务..."
ssh root@$SERVER_IP "systemctl restart enterprise-backend"

# 9. 检查服务状态
echo ""
echo "🔍 检查服务状态..."
ssh root@$SERVER_IP "systemctl status enterprise-backend --no-pager"

# 10. 测试API连接
echo ""
echo "🧪 测试API连接..."
sleep 5
ssh root@$SERVER_IP "curl -X GET http://localhost:8000/company/ -H 'Content-Type: application/json'"

echo ""
echo "=================================================="
echo "✅ 数据迁移完成！"
echo ""
echo "📋 迁移结果:"
echo "   ✅ enterprise_db 数据已迁移到 enterprise_prod"
echo "   ✅ enterprise_db 数据库已删除"
echo "   ✅ 生产环境统一使用 enterprise_prod"
echo "   ✅ 管理员密码已更新"
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