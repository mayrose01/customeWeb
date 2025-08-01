#!/bin/bash

# 检查生产环境API状态脚本

SERVER_IP="47.243.41.30"
SSH_PASSWORD="Qing0325."

echo "🔍 检查生产环境API状态..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 检查后端服务状态
echo "🖥️  检查后端服务状态..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status enterprise-backend --no-pager"

# 2. 检查后端服务端口
echo ""
echo "🔌 检查后端服务端口..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "netstat -tlnp | grep :8000"

# 3. 测试本地API
echo ""
echo "🧪 测试本地API..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s http://localhost:8000/docs | head -20"

# 4. 测试API文档
echo ""
echo "📋 测试API文档..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s http://localhost:8000/openapi.json | head -10"

# 5. 测试登录API
echo ""
echo "🔐 测试登录API..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s -X POST http://localhost:8000/api/user/login -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin&password=admin123'"

# 6. 检查Nginx代理配置
echo ""
echo "🌐 检查Nginx代理配置..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "grep -A 10 'location /api/' /etc/nginx/conf.d/catusfoto.top.conf"

# 7. 测试外部API访问
echo ""
echo "🌍 测试外部API访问..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s -I https://catusfoto.top/api/"

# 8. 测试外部API文档
echo ""
echo "📚 测试外部API文档..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s -I https://catusfoto.top/docs"

echo ""
echo "=================================================="
echo "✅ API状态检查完成" 