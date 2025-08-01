#!/bin/bash

# 上传构建文件到服务器脚本

SERVER_IP="47.243.41.30"
SSH_PASSWORD="Qing0325."

echo "📤 上传构建文件到服务器..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 1. 检查本地构建文件
echo "📁 检查本地构建文件..."
ls -la dist/

# 2. 上传构建文件到服务器
echo ""
echo "📤 上传构建文件到服务器..."
sshpass -p "$SSH_PASSWORD" scp -r dist/ root@$SERVER_IP:/var/www/enterprise/enterprise-frontend/

# 3. 检查服务器上的文件
echo ""
echo "✅ 检查服务器上的文件..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "ls -la /var/www/enterprise/enterprise-frontend/dist/"

# 4. 检查网站访问
echo ""
echo "🌍 检查网站访问..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s -I https://catusfoto.top"

# 5. 测试后台管理页面
echo ""
echo "🧪 测试后台管理页面..."
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s -I https://catusfoto.top/admin"

echo ""
echo "=================================================="
echo "✅ 构建文件上传完成"
echo ""
echo "🌐 访问地址:"
echo "   首页: https://catusfoto.top"
echo "   后台管理: https://catusfoto.top/admin"
echo "   API文档: https://catusfoto.top/docs"
echo ""
echo "🔑 管理员登录凭据:"
echo "   用户名: admin"
echo "   密码: admin123" 