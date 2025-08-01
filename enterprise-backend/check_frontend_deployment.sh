#!/bin/bash

# 检查前端部署状态脚本

SERVER_IP="47.243.41.30"
SSH_PASSWORD="Qing0325."

echo "🔍 检查前端部署状态..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 检查前端目录结构
echo "📁 检查前端目录结构..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "ls -la /var/www/enterprise/enterprise-frontend/"

# 2. 检查是否有构建文件
echo ""
echo "🏗️  检查构建文件..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "find /var/www/enterprise/enterprise-frontend -name 'dist' -o -name 'build' -o -name '*.html'"

# 3. 检查Nginx配置
echo ""
echo "🌐 检查Nginx配置..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "find /etc/nginx -name '*catusfoto*' -exec echo '=== {} ===' \; -exec cat {} \;"

# 4. 检查Nginx状态
echo ""
echo "🔍 检查Nginx状态..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status nginx --no-pager"

# 5. 检查网站访问
echo ""
echo "🌍 检查网站访问..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s -I https://catusfoto.top"

# 6. 检查前端是否需要重新构建
echo ""
echo "🔧 检查前端构建状态..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-frontend && ls -la package.json && cat package.json | grep -A 5 -B 5 'scripts'"

echo ""
echo "=================================================="
echo "✅ 前端部署状态检查完成"
echo ""
echo "📋 可能的问题:"
echo "   1. 前端未构建 (没有dist目录)"
echo "   2. 前端未部署到Nginx"
echo "   3. 环境配置缓存问题"
echo ""
echo "🔧 解决方案:"
echo "   1. 重新构建前端: npm run build:prod"
echo "   2. 部署到服务器"
echo "   3. 清除浏览器缓存" 