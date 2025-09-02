#!/bin/bash

echo "🚀 启动测试环境..."

# 检查端口是否被占用
if lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  端口8001已被占用，正在停止现有服务..."
    pkill -f "uvicorn.*8001"
    sleep 2
fi

if lsof -Pi :3001 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  端口3001已被占用，正在停止现有服务..."
    pkill -f "vite.*3001"
    sleep 2
fi

# 启动测试环境后端
echo "📡 启动测试环境后端 (端口8001)..."
cd enterprise-backend
ENV=test python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload --env-file test.env &
BACKEND_PID=$!

# 等待后端启动
sleep 3

# 检查后端是否启动成功
if curl -s http://localhost:8001/api/company/ > /dev/null; then
    echo "✅ 测试环境后端启动成功"
else
    echo "❌ 测试环境后端启动失败"
    exit 1
fi

# 启动测试环境前端
echo "🌐 启动测试环境前端 (端口3001)..."
cd ../enterprise-frontend
npm run dev:test-only &
FRONTEND_PID=$!

# 等待前端启动
sleep 5

# 检查前端是否启动成功
if curl -s http://localhost:3001 > /dev/null; then
    echo "✅ 测试环境前端启动成功"
else
    echo "❌ 测试环境前端启动失败"
    exit 1
fi

echo ""
echo "🎯 测试环境启动完成！"
echo "📋 访问信息："
echo "   🔧 后端API: http://localhost:8001"
echo "   🌐 前端应用: http://localhost:3001"
echo "   🗄️ 数据库: enterprise_test (端口3307)"
echo ""
echo "💡 管理命令："
echo "   停止后端: pkill -f 'uvicorn.*8001'"
echo "   停止前端: pkill -f 'vite.*3001'"
echo "   查看后端日志: tail -f enterprise-backend/logs/app_test.log"
echo "   查看前端日志: 在终端中查看npm输出" 