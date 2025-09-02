#!/bin/bash

# 修正数据库配置脚本

SERVER_IP="YOUR_SERVER_IP_HERE"

echo "🔧 修正数据库配置..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 检查两个数据库的内容
echo "📊 检查 enterprise_prod 数据库..."
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SHOW TABLES;'"

echo ""
echo "📊 检查 enterprise_db 数据库..."
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_db; SHOW TABLES;'"

echo ""
echo "👥 检查 enterprise_db 中的用户..."
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_db; SELECT id, username, email, role, status FROM users;'"

echo ""
echo "👥 检查 enterprise_prod 中的用户..."
ssh root@$SERVER_IP "mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SELECT id, username, email, role, status FROM users;'"

# 修正配置文件
echo ""
echo "📝 修正生产环境配置文件..."
ssh root@$SERVER_IP "sed -i 's/enterprise_prod/enterprise_db/g' /var/www/enterprise/enterprise-backend/production.env"

# 验证配置文件
echo ""
echo "🔍 验证配置文件..."
ssh root@$SERVER_IP "cat /var/www/enterprise/enterprise-backend/production.env"

# 重启后端服务
echo ""
echo "🔄 重启后端服务..."
ssh root@$SERVER_IP "systemctl restart enterprise-backend"

# 检查服务状态
echo ""
echo "🔍 检查服务状态..."
ssh root@$SERVER_IP "systemctl status enterprise-backend --no-pager"

# 测试API连接
echo ""
echo "🧪 测试API连接..."
sleep 5
ssh root@$SERVER_IP "curl -X GET http://localhost:8000/company/ -H 'Content-Type: application/json'"

echo ""
echo "=================================================="
echo "✅ 数据库配置修正完成"
echo ""
echo "🔑 管理员登录凭据:"
echo "   用户名: admin"
echo "   密码: admin123"
echo "   登录地址: https://catusfoto.top/admin/login" 