#!/bin/bash

# SSH数据库检查脚本
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
    echo "请检查："
    echo "1. 服务器IP地址是否正确"
    echo "2. SSH服务是否正常运行"
    echo "3. 防火墙是否允许SSH连接"
    exit 1
fi

# 检查MySQL服务状态
echo ""
echo "🐬 检查MySQL服务状态..."
ssh root@$SERVER_IP "systemctl status mysql --no-pager"

# 检查数据库
echo ""
echo "📊 检查数据库..."
ssh root@$SERVER_IP "mysql -e 'SHOW DATABASES;'"

# 检查enterprise_db数据库
echo ""
echo "🏢 检查enterprise_db数据库..."
ssh root@$SERVER_IP "mysql -e 'USE enterprise_db; SHOW TABLES;'"

# 检查users表
echo ""
echo "👥 检查users表..."
ssh root@$SERVER_IP "mysql -e 'USE enterprise_db; DESCRIBE users;'"

# 检查管理员用户
echo ""
echo "👑 检查管理员用户..."
ssh root@$SERVER_IP "mysql -e 'USE enterprise_db; SELECT id, username, email, role, status FROM users WHERE role = \"admin\";'"

# 检查所有用户
echo ""
echo "👥 检查所有用户..."
ssh root@$SERVER_IP "mysql -e 'USE enterprise_db; SELECT id, username, email, role, status FROM users LIMIT 10;'"

echo ""
echo "=================================================="
echo "✅ 数据库检查完成" 