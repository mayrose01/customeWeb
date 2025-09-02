#!/bin/bash

# 检查生产环境服务状态脚本

SERVER_IP="YOUR_SERVER_IP_HERE"

echo "🔍 检查生产环境服务状态..."
echo "=================================================="
echo "服务器IP: $SERVER_IP"
echo "=================================================="

# 检查后端服务状态
echo "🐍 检查后端服务状态..."
ssh root@$SERVER_IP "systemctl status enterprise-backend --no-pager"

# 检查后端服务日志
echo ""
echo "📋 检查后端服务日志..."
ssh root@$SERVER_IP "journalctl -u enterprise-backend --no-pager -n 20"

# 检查后端进程
echo ""
echo "🔍 检查后端进程..."
ssh root@$SERVER_IP "ps aux | grep uvicorn"

# 检查端口占用
echo ""
echo "🔌 检查端口占用..."
ssh root@$SERVER_IP "netstat -tlnp | grep :8000"

# 检查Nginx状态
echo ""
echo "🌐 检查Nginx状态..."
ssh root@$SERVER_IP "systemctl status nginx --no-pager"

# 检查Nginx配置
echo ""
echo "⚙️  检查Nginx配置..."
ssh root@$SERVER_IP "nginx -t"

# 检查后端配置文件
echo ""
echo "📄 检查后端配置文件..."
ssh root@$SERVER_IP "cat /var/www/enterprise/enterprise-backend/production.env"

# 测试API连接
echo ""
echo "🧪 测试API连接..."
ssh root@$SERVER_IP "curl -X GET http://localhost:8000/company/ -H 'Content-Type: application/json'"

# 检查数据库连接
echo ""
echo "🗄️  检查数据库连接..."
ssh root@$SERVER_IP "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && python -c \"from app.database import engine; from sqlalchemy import text; conn = engine.connect(); result = conn.execute(text('SELECT 1')); print('数据库连接成功')\""

echo ""
echo "=================================================="
echo "✅ 服务状态检查完成" 