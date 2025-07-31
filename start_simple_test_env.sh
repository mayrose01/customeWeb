#!/bin/bash

# 测试环境启动脚本
# 使用独立的数据库和端口，避免与开发环境冲突

echo "🚀 启动测试环境..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

# 停止并删除现有的测试容器
echo "🛑 清理现有测试容器..."
docker-compose -f docker-compose.test.yml down -v 2>/dev/null || true

# 启动测试环境
echo "🔧 启动测试环境服务..."
docker-compose -f docker-compose.test.yml up -d

# 等待MySQL启动
echo "⏳ 等待MySQL启动..."
sleep 10

# 检查MySQL连接
echo "🔍 检查数据库连接..."
for i in {1..30}; do
    if docker exec enterprise_mysql_test mysql -u test_user -ptest_password -e "SELECT 1;" > /dev/null 2>&1; then
        echo "✅ MySQL连接成功"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ MySQL连接失败"
        exit 1
    fi
    sleep 2
done

# 初始化数据库
echo "🗄️ 初始化数据库..."
docker exec -i enterprise_mysql_test mysql -u test_user -ptest_password enterprise_test < mysql/init.sql

# 设置环境变量
export ENV=test
export DATABASE_URL="mysql+pymysql://test_user:test_password@localhost:3307/enterprise_test"

# 启动后端服务
echo "🔧 启动后端服务..."
cd enterprise-backend

# 激活虚拟环境（如果存在）
if [ -d ".venv" ]; then
    source .venv/bin/activate
fi

# 安装依赖
echo "📦 安装Python依赖..."
pip install -r requirements.txt

# 启动后端
echo "🚀 启动后端服务 (端口: 8001)..."
ENV=test python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001 &
BACKEND_PID=$!

# 等待后端启动
sleep 5

# 启动前端服务
echo "🚀 启动前端服务..."
cd ../enterprise-frontend

# 安装依赖
echo "📦 安装前端依赖..."
npm install

# 设置环境变量
export VITE_API_BASE_URL=http://localhost:8001

# 启动前端
echo "🚀 启动前端服务 (端口: 3001)..."
npm run dev -- --port 3001 &
FRONTEND_PID=$!

# 等待服务启动
sleep 10

# 显示服务信息
echo ""
echo "🎉 测试环境启动完成！"
echo ""
echo "📋 服务信息："
echo "   - 前端: http://localhost:3001"
echo "   - 后端: http://localhost:8001"
echo "   - 数据库: localhost:3307"
echo "   - 数据库名: enterprise_test"
echo "   - 数据库用户: test_user"
echo "   - 数据库密码: test_password"
echo ""
echo "🔧 管理命令："
echo "   - 停止服务: ./stop_simple_test_env.sh"
echo "   - 查看日志: docker logs enterprise_backend_test"
echo "   - 数据库连接: mysql -h localhost -P 3307 -u test_user -ptest_password enterprise_test"
echo ""
echo "⚠️  注意："
echo "   - 使用独立的数据库 (enterprise_test)"
echo "   - 使用独立的端口 (3001, 8001, 3307)"
echo "   - 数据与开发环境完全隔离"
echo ""

# 等待用户中断
echo "按 Ctrl+C 停止所有服务..."
wait 