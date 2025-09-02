#!/bin/bash

# 修复前端构建脚本

SERVER_IP="YOUR_SERVER_IP_HERE"
SSH_PASSWORD="YOUR_SERVER_PASSWORD_HERE"

echo "🔧 修复前端构建..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 安装Node.js依赖
echo "📦 安装Node.js依赖..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-frontend && npm install"

# 2. 构建前端
echo ""
echo "🏗️  构建前端..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-frontend && npm run build:prod"

# 3. 检查构建结果
echo ""
echo "✅ 检查构建结果..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "ls -la /var/www/enterprise/enterprise-frontend/dist/"

# 4. 检查构建文件内容
echo ""
echo "📁 检查构建文件内容..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "find /var/www/enterprise/enterprise-frontend/dist -name '*.js' -o -name '*.html' | head -10"

# 5. 检查网站访问
echo ""
echo "🌍 检查网站访问..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s -I https://catusfoto.top"

echo ""
echo "=================================================="
echo "✅ 前端构建修复完成"
echo ""
echo "📋 修复内容:"
echo "   ✅ Node.js依赖已安装"
echo "   ✅ 前端已重新构建"
echo "   ✅ 构建文件已生成"
echo ""
echo "🌐 访问地址:"
echo "   首页: https://catusfoto.top"
echo "   后台管理: https://catusfoto.top/admin"
echo "   API文档: https://catusfoto.top/docs" 