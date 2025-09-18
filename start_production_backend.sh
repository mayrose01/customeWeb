#!/bin/bash

# 启动生产环境后端服务

set -e

# 从环境变量读取配置，如果没有设置则使用默认值
SERVER_IP="${SERVER_IP:-catusfoto.top}"
SSH_KEY="${SSH_KEY:-/Users/huangqing/enterprise/enterprise_prod.pem}"
BACKEND_PATH="${BACKEND_PATH:-/var/www/enterprise/enterprise-backend}"

# 检查必要的环境变量
if [ -z "$DATABASE_URL" ]; then
    echo "❌ 错误: 请设置 DATABASE_URL 环境变量"
    echo "例如: export DATABASE_URL='mysql+pymysql://username:password@localhost:3306/database'"
    exit 1
fi

if [ -z "$SECRET_KEY" ]; then
    echo "❌ 错误: 请设置 SECRET_KEY 环境变量"
    echo "例如: export SECRET_KEY='your-production-secret-key'"
    exit 1
fi

echo "🚀 启动生产环境后端服务"
echo "================================================"

# 1. 停止现有服务
echo "🛑 停止现有服务..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "pkill -f uvicorn || true"
sleep 2

# 2. 设置环境变量并启动服务
echo "🔄 设置环境变量并启动服务..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && source venv/bin/activate && export ENVIRONMENT=production && export DATABASE_URL='$DATABASE_URL' && export SECRET_KEY='$SECRET_KEY' && nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 > /var/log/enterprise_backend.log 2>&1 &"

# 3. 等待服务启动
echo "⏳ 等待服务启动..."
sleep 5

# 4. 检查服务状态
echo "📋 检查服务状态..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "ps aux | grep uvicorn | grep -v grep"

# 5. 检查服务日志
echo "📋 检查服务日志..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "tail -10 /var/log/enterprise_backend.log"

echo "✅ 服务启动完成！"
echo "================================================"
