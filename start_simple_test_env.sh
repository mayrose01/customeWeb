#!/bin/bash

# 简化测试环境启动脚本
echo "🚀 启动简化测试环境..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

# 创建必要的目录
echo "📁 创建必要的目录..."
mkdir -p enterprise-backend/uploads_test
mkdir -p enterprise-backend/logs

# 停止并删除现有的测试容器
echo "🧹 清理现有测试容器..."
docker-compose -f docker-compose.test-simple.yml down -v

# 启动MySQL数据库
echo "🗄️ 启动MySQL数据库..."
docker-compose -f docker-compose.test-simple.yml up -d mysql_test

# 等待MySQL启动
echo "⏳ 等待MySQL启动..."
sleep 30

# 检查MySQL状态
echo "🔍 检查MySQL状态..."
if docker exec enterprise_mysql_test mysql -u test_user -ptest_password -e "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ MySQL数据库启动成功"
else
    echo "❌ MySQL数据库启动失败"
    exit 1
fi

# 启动后端服务
echo "🔧 启动后端服务..."
cd enterprise-backend

# 检查虚拟环境
if [ ! -d ".venv" ]; then
    echo "📦 创建Python虚拟环境..."
    python3 -m venv .venv
fi

# 激活虚拟环境
source .venv/bin/activate

# 安装依赖
echo "📦 安装Python依赖..."
pip install -r requirements.txt

# 设置环境变量
export DATABASE_URL="mysql+pymysql://test_user:test_password@localhost:3307/enterprise_test_db"
export SECRET_KEY="test_enterprise_secret_key_2024"
export ALGORITHM="HS256"
export ACCESS_TOKEN_EXPIRE_MINUTES="1440"
export CORS_ORIGINS='["http://localhost:3001", "http://localhost:3002", "http://localhost:3003"]'
export UPLOAD_DIR="uploads_test"
export MAX_FILE_SIZE="2097152"
export LOG_LEVEL="DEBUG"
export LOG_FILE="logs/app_test.log"

# 启动后端服务（后台运行）
echo "🚀 启动后端API服务 (端口: 8001)..."
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload > ../logs/backend_test.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > ../logs/backend_test.pid

cd ..

# 启动前端服务
echo "🌐 启动前端服务..."
cd enterprise-frontend

# 安装依赖
echo "📦 安装Node.js依赖..."
npm install

# 设置环境变量
export VITE_API_BASE_URL="http://localhost:8001"

# 启动前端服务（后台运行）
echo "🚀 启动前端服务 (端口: 3001)..."
npm run dev -- --port 3001 > ../logs/frontend_test.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > ../logs/frontend_test.pid

cd ..

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 15

# 检查服务状态
echo "🔍 检查服务状态..."

# 检查后端服务
if curl -s http://localhost:8001/health > /dev/null 2>&1; then
    echo "✅ 后端服务启动成功"
else
    echo "❌ 后端服务启动失败，查看日志: logs/backend_test.log"
fi

# 检查前端服务
if curl -s http://localhost:3001 > /dev/null 2>&1; then
    echo "✅ 前端服务启动成功"
else
    echo "❌ 前端服务启动失败，查看日志: logs/frontend_test.log"
fi

# 显示访问信息
echo ""
echo "✅ 简化测试环境启动完成！"
echo ""
echo "📋 访问信息："
echo "   🌐 前端应用: http://localhost:3001"
echo "   🔧 后端API: http://localhost:8001"
echo "   📚 API文档: http://localhost:8001/docs"
echo "   🗄️  MySQL数据库: localhost:3307"
echo ""
echo "📊 数据库信息："
echo "   数据库名: enterprise_test_db"
echo "   用户名: test_user"
echo "   密码: test_password"
echo "   端口: 3307"
echo ""
echo "🔧 管理命令："
echo "   查看后端日志: tail -f logs/backend_test.log"
echo "   查看前端日志: tail -f logs/frontend_test.log"
echo "   停止服务: ./stop_simple_test_env.sh"
echo "   查看MySQL日志: docker logs enterprise_mysql_test"
echo ""
echo "📝 测试环境特点："
echo "   - MySQL使用Docker容器"
echo "   - 后端和前端使用本地服务"
echo "   - 使用独立的数据库和端口"
echo "   - 便于调试和开发"
echo "" 