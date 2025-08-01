#!/bin/bash

# SSH数据库检查脚本（带认证）
# 用于通过SSH连接到服务器并检查数据库

SERVER_IP="47.243.41.30"

echo "🔍 通过SSH检查远程服务器数据库..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 检查SSH连接
echo "📡 检查SSH连接..."
if ssh -o ConnectTimeout=10 root@$SERVER_IP "echo 'SSH连接成功'" 2>/dev/null; then
    echo "✅ SSH连接成功"
else
    echo "❌ SSH连接失败"
    exit 1
fi

# 检查MySQL服务状态
echo ""
echo "🐬 检查MySQL服务状态..."
ssh root@$SERVER_IP "systemctl status mysql --no-pager"

# 尝试使用enterprise_user连接数据库
echo ""
echo "📊 尝试使用enterprise_user连接数据库..."
ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'SHOW DATABASES;'"

# 检查enterprise_db数据库
echo ""
echo "🏢 检查enterprise_db数据库..."
ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_db; SHOW TABLES;'"

# 检查users表
echo ""
echo "👥 检查users表..."
ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_db; DESCRIBE users;'"

# 检查管理员用户
echo ""
echo "👑 检查管理员用户..."
ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_db; SELECT id, username, email, role, status FROM users WHERE role = \"admin\";'"

# 检查所有用户
echo ""
echo "👥 检查所有用户..."
ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_db; SELECT id, username, email, role, status FROM users LIMIT 10;'"

# 如果没有管理员用户，创建管理员用户
echo ""
echo "🔧 检查是否需要创建管理员用户..."
ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_db; SELECT COUNT(*) as admin_count FROM users WHERE role = \"admin\";'"

ADMIN_COUNT=$(ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_db; SELECT COUNT(*) FROM users WHERE role = \"admin\";' -s -N")

if [ "$ADMIN_COUNT" -eq "0" ]; then
    echo "⚠️  没有找到管理员用户，正在创建..."
    ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_db; INSERT INTO users (username, password_hash, email, role, status, created_at, updated_at) VALUES (\"admin\", \"\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vJQKq6y\", \"admin@catusfoto.top\", \"admin\", 1, NOW(), NOW());'"
    echo "✅ 管理员用户创建完成"
else
    echo "✅ 已存在管理员用户"
fi

# 验证管理员用户
echo ""
echo "🔍 验证管理员用户..."
ssh root@$SERVER_IP "mysql -u enterprise_user -penterprise_password_2024 -e 'USE enterprise_db; SELECT id, username, email, role, status FROM users WHERE role = \"admin\";'"

echo ""
echo "=================================================="
echo "✅ 数据库检查完成"
echo ""
echo "🔑 管理员登录凭据:"
echo "   用户名: admin"
echo "   密码: admin123"
echo "   登录地址: https://catusfoto.top/admin/login" 