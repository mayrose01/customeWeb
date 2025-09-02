#!/bin/bash

# 测试环境后端启动脚本
echo "🚀 启动测试环境后端服务..."

# 检查是否在正确的目录
if [ ! -f "app/main.py" ]; then
    echo "❌ 错误：请在 enterprise-backend 目录下运行此脚本"
    exit 1
fi

# 激活虚拟环境
if [ -d ".venv" ]; then
    echo "📦 激活虚拟环境..."
    source .venv/bin/activate
else
    echo "❌ 错误：未找到虚拟环境 .venv"
    exit 1
fi

# 检查依赖
echo "🔍 检查依赖..."
if ! python -c "import dotenv" 2>/dev/null; then
    echo "📦 安装 python-dotenv..."
    pip install python-dotenv
fi

# 检查其他依赖
echo "📦 安装/更新依赖..."
pip install -r requirements.txt

# 设置环境变量
export ENV=test
export DATABASE_URL="mysql+pymysql://root:root@localhost:3306/enterprise_test"

echo "🔧 启动后端服务 (端口: 8001)..."
echo "📋 环境信息："
echo "   - 环境: test"
echo "   - 数据库: enterprise_test"
echo "   - 端口: 8001"

# 启动服务
python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001 