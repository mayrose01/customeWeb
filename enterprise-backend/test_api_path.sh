#!/bin/bash

# 测试API路径脚本

SERVER_IP="47.243.41.30"
SSH_PASSWORD="Qing0325."

echo "🧪 测试API路径..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 测试正确的登录API路径
echo "📋 测试正确的登录API路径..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -X POST http://localhost:8000/api/user/login -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin&password=admin123'"

echo ""
echo "=================================================="

# 2. 测试错误的路径（你提到的）
echo "📋 测试错误的路径..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -X POST http://localhost:8000/api//login -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin&password=admin123'"

echo ""
echo "=================================================="

# 3. 测试不带api前缀的路径
echo "📋 测试不带api前缀的路径..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -X POST http://localhost:8000/user/login -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin&password=admin123'"

echo ""
echo "=================================================="

# 4. 检查所有可用的路由
echo "📋 检查所有可用的路由..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -X GET http://localhost:8000/docs"

echo ""
echo "=================================================="
echo "✅ API路径测试完成" 