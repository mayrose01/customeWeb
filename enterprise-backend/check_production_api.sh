#!/bin/bash

# 检查生产环境API脚本

SERVER_IP="47.243.41.30"
SSH_PASSWORD="Qing0325."

echo "🔍 检查生产环境API..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 检查生产环境API文档
echo "📋 生产环境API文档地址:"
echo "   https://catusfoto.top/docs"
echo "   https://catusfoto.top/redoc"
echo "   https://catusfoto.top/openapi.json"

# 2. 检查服务器上的API状态
echo ""
echo "🖥️  检查服务器上的API状态..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s http://localhost:8000/docs | head -20"

# 3. 检查Nginx配置
echo ""
echo "🌐 检查Nginx配置..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cat /etc/nginx/sites-available/catusfoto.top"

# 4. 检查前端环境配置
echo ""
echo "📱 检查前端环境配置..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "find /var/www/enterprise -name 'env.config.js' -exec cat {} \;"

# 5. 检查前端构建文件
echo ""
echo "🏗️  检查前端构建文件..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "ls -la /var/www/enterprise/enterprise-frontend/dist/"

# 6. 检查前端环境变量
echo ""
echo "🔧 检查前端环境变量..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "find /var/www/enterprise -name 'env.*' -exec echo '=== {} ===' \; -exec cat {} \;"

echo ""
echo "=================================================="
echo "✅ 生产环境API检查完成"
echo ""
echo "📋 API地址总结:"
echo "   生产环境API: https://catusfoto.top/api/"
echo "   API文档: https://catusfoto.top/docs"
echo "   ReDoc文档: https://catusfoto.top/redoc"
echo "   OpenAPI规范: https://catusfoto.top/openapi.json" 