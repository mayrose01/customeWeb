#!/bin/bash

# 更新管理员密码脚本
# 用于更新生产环境管理员用户的密码

SERVER_IP="47.243.41.30"

echo "🔧 更新管理员密码..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 更新所有admin用户的密码
echo "📝 更新所有admin用户的密码..."

ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_db; UPDATE users SET password_hash = \"\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vJQKq6y\" WHERE role = \"admin\";'"

# 验证更新结果
echo ""
echo "🔍 验证更新结果..."
ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_db; SELECT id, username, email, role, status FROM users WHERE role = \"admin\";'"

echo ""
echo "=================================================="
echo "✅ 管理员密码更新完成"
echo ""
echo "🔑 管理员登录凭据:"
echo "   用户名: admin"
echo "   密码: admin123"
echo "   登录地址: https://catusfoto.top/admin/login"
echo ""
echo "⚠️  注意："
echo "   1. 所有admin用户的密码都已更新为 'admin123'"
echo "   2. 请使用任意一个admin用户登录"
echo "   3. 建议登录后删除重复的管理员账户" 