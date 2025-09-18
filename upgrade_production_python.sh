#!/bin/bash

# 升级生产环境Python版本到3.9.6

set -e

# 配置
SERVER_IP="catusfoto.top"
SSH_KEY="/Users/huangqing/enterprise/enterprise_prod.pem"
BACKEND_PATH="/var/www/enterprise/enterprise-backend"

echo "🐍 升级生产环境Python版本到3.9.6"
echo "================================================"

# 1. 检查当前Python版本
echo "📋 检查当前Python版本..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "python3 --version"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && source venv/bin/activate && python --version"

# 2. 停止后端服务
echo "🛑 停止后端服务..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "pkill -f uvicorn || true"
sleep 2

# 3. 安装Python 3.9
echo "🔄 安装Python 3.9..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "yum update -y"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "yum install -y python39 python39-pip python39-devel"

# 4. 验证Python 3.9安装
echo "✅ 验证Python 3.9安装..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "python3.9 --version"

# 5. 备份现有虚拟环境
echo "💾 备份现有虚拟环境..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && mv venv venv_backup_python36"

# 6. 创建新的虚拟环境
echo "🔄 创建新的虚拟环境..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && python3.9 -m venv venv"

# 7. 激活新虚拟环境并安装依赖
echo "🔄 安装依赖..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && source venv/bin/activate && pip install --upgrade pip"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && source venv/bin/activate && pip install -r requirements.txt"

# 8. 验证新环境
echo "✅ 验证新环境..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && source venv/bin/activate && python --version"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && source venv/bin/activate && python -c 'import fastapi; print(\"FastAPI installed successfully\")'"

# 9. 启动后端服务
echo "🚀 启动后端服务..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && source venv/bin/activate && export ENVIRONMENT=production && export DATABASE_URL='mysql+pymysql://root:root@localhost:3306/enterprise_prod' && nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 > /var/log/enterprise_backend.log 2>&1 &"

# 10. 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 11. 检查服务状态
echo "📋 检查服务状态..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "ps aux | grep uvicorn | grep -v grep"

# 12. 测试API
echo "🧪 测试API..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "curl -s http://127.0.0.1:8000/api/client-product/ | head -c 100"

echo "✅ Python升级完成！"
echo "================================================"
