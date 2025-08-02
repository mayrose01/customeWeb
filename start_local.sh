#!/bin/bash

echo "🚀 启动开发环境..."

# 检查端口是否被占用
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  端口8000已被占用，正在停止现有服务..."
    pkill -f "uvicorn.*8000"
    sleep 2
fi

if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  端口3000已被占用，正在停止现有服务..."
    pkill -f "vite.*3000"
    sleep 2
fi

# 启动开发环境后端
echo "📡 启动开发环境后端 (端口8000)..."
cd enterprise-backend
ENVIRONMENT=development python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --env-file dev.env &
BACKEND_PID=$!

# 等待后端启动
sleep 3

# 检查后端是否启动成功
if curl -s http://localhost:8000/api/company/ > /dev/null; then
    echo "✅ 开发环境后端启动成功"
else
    echo "❌ 开发环境后端启动失败"
    exit 1
fi

# 启动开发环境前端
echo "🌐 启动开发环境前端 (端口3000)..."
cd ../enterprise-frontend
npm run vite -- --mode development --port 3000 &
FRONTEND_PID=$!

# 等待前端启动
sleep 5

# 检查前端是否启动成功
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ 开发环境前端启动成功"
else
    echo "❌ 开发环境前端启动失败"
    exit 1
fi

echo ""
echo "🎯 开发环境启动完成！"
echo "📋 访问信息："
echo "   🔧 后端API: http://localhost:8000"
echo "   🌐 前端应用: http://localhost:3000"
echo "   🗄️ 数据库: enterprise_dev (端口3306)"
echo ""
echo "💡 管理命令："
echo "   停止后端: pkill -f 'uvicorn.*8000'"
echo "   停止前端: pkill -f 'vite.*3000'"
echo "   查看日志: tail -f enterprise-backend/logs/app_$(date +%Y%m%d).log" 