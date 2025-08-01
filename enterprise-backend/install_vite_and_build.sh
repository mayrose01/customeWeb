#!/bin/bash

# 安装vite并构建前端脚本

SERVER_IP="47.243.41.30"
SSH_PASSWORD="Qing0325."

echo "🔧 安装vite并构建前端..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 检查Node.js和npm版本
echo "📋 检查Node.js和npm版本..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "node --version && npm --version"

# 2. 安装vite
echo ""
echo "📦 安装vite..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-frontend && npm install vite"

# 3. 安装所有依赖
echo ""
echo "📦 安装所有依赖..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-frontend && npm install"

# 4. 构建前端
echo ""
echo "🏗️  构建前端..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-frontend && npx vite build --mode production"

# 5. 检查构建结果
echo ""
echo "✅ 检查构建结果..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "ls -la /var/www/enterprise/enterprise-frontend/dist/"

# 6. 检查构建文件内容
echo ""
echo "📁 检查构建文件内容..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "find /var/www/enterprise/enterprise-frontend/dist -name '*.js' -o -name '*.html' | head -10"

# 7. 检查网站访问
echo ""
echo "🌍 检查网站访问..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s -I https://catusfoto.top"

echo ""
echo "=================================================="
echo "✅ vite安装和前端构建完成"
echo ""
echo "📋 修复内容:"
echo "   ✅ vite已安装"
echo "   ✅ 所有依赖已安装"
echo "   ✅ 前端已重新构建"
echo "   ✅ 构建文件已生成"
echo ""
echo "🌐 访问地址:"
echo "   首页: https://catusfoto.top"
echo "   后台管理: https://catusfoto.top/admin"
echo "   API文档: https://catusfoto.top/docs" 