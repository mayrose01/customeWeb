#!/bin/bash

# 测试环境验证脚本
echo "🔍 验证测试环境..."

# 检查是否在正确的目录
if [ ! -f "app/main.py" ]; then
    echo "❌ 错误：请在 enterprise-backend 目录下运行此脚本"
    exit 1
fi

# 激活虚拟环境
if [ -d ".venv" ]; then
    source .venv/bin/activate
    echo "✅ 虚拟环境已激活"
else
    echo "❌ 错误：未找到虚拟环境 .venv"
    exit 1
fi

# 检查依赖
echo "📦 检查依赖..."
python -c "import fastapi, uvicorn, dotenv, sqlalchemy, pymysql; print('✅ 所有依赖已安装')" 2>/dev/null || {
    echo "❌ 缺少依赖，正在安装..."
    pip install -r requirements.txt
}

# 检查模块导入
echo "🔍 检查模块导入..."
python -c "import app; print('✅ app 模块导入成功')" 2>/dev/null || {
    echo "❌ app 模块导入失败"
    exit 1
}

# 检查数据库连接
echo "🗄️ 检查数据库连接..."
python -c "
from app.database import engine
from sqlalchemy import text
try:
    with engine.connect() as conn:
        result = conn.execute(text('SELECT 1'))
        print('✅ 数据库连接成功')
except Exception as e:
    print(f'❌ 数据库连接失败: {e}')
    exit(1)
" 2>/dev/null || {
    echo "❌ 数据库连接失败"
    echo "请确保 MySQL 正在运行，并且 enterprise_test 数据库已创建"
}

# 检查服务状态
echo "🌐 检查服务状态..."
if curl -s http://localhost:8001/docs > /dev/null 2>&1; then
    echo "✅ 测试环境服务正在运行 (端口: 8001)"
    echo "📋 访问信息："
    echo "   - API 文档: http://localhost:8001/docs"
    echo "   - 数据库: enterprise_test"
    echo "   - 环境: test"
else
    echo "❌ 测试环境服务未运行"
    echo "请运行以下命令启动服务："
    echo "  ENV=test python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001"
fi

# 检查环境变量
echo "🔧 检查环境变量..."
echo "   ENV: ${ENV:-未设置}"
echo "   DATABASE_URL: ${DATABASE_URL:-未设置}"

echo ""
echo "🎉 环境检查完成！" 