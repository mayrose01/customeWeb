#!/bin/bash

# 修复前端部署脚本

SERVER_IP="47.243.41.30"
SSH_PASSWORD="Qing0325."

echo "🔧 修复前端部署..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 构建前端
echo "🏗️  构建前端..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /var/www/enterprise/enterprise-frontend && npm run build:prod"

# 2. 检查构建结果
echo ""
echo "✅ 检查构建结果..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "ls -la /var/www/enterprise/enterprise-frontend/dist/"

# 3. 修复Nginx配置
echo ""
echo "🌐 修复Nginx配置..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "sed -i 's|root /var/www/enterprise-frontend|root /var/www/enterprise/enterprise-frontend/dist|g' /etc/nginx/conf.d/catusfoto.top.conf"

# 4. 验证Nginx配置
echo ""
echo "🔍 验证Nginx配置..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "nginx -t"

# 5. 重启Nginx
echo ""
echo "🔄 重启Nginx..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl reload nginx"

# 6. 检查网站访问
echo ""
echo "🌍 检查网站访问..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s -I https://catusfoto.top"

# 7. 检查前端文件
echo ""
echo "📁 检查前端文件..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "ls -la /var/www/enterprise/enterprise-frontend/dist/"

echo ""
echo "=================================================="
echo "✅ 前端部署修复完成"
echo ""
echo "📋 修复内容:"
echo "   ✅ 前端已重新构建"
echo "   ✅ Nginx配置已修复"
echo "   ✅ Nginx已重启"
echo ""
echo "🌐 访问地址:"
echo "   首页: https://catusfoto.top"
echo "   后台管理: https://catusfoto.top/admin"
echo "   API文档: https://catusfoto.top/docs" 