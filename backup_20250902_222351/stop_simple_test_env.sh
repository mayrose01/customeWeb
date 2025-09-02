#!/bin/bash

# 简化测试环境停止脚本
echo "🛑 停止简化测试环境..."

# 停止MySQL容器
echo "🗄️ 停止MySQL容器..."
docker-compose -f docker-compose.test-simple.yml down

# 停止后端服务
echo "🔧 停止后端服务..."
if [ -f "logs/backend_test.pid" ]; then
    BACKEND_PID=$(cat logs/backend_test.pid)
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        echo "停止后端进程 (PID: $BACKEND_PID)..."
        kill $BACKEND_PID
    fi
    rm -f logs/backend_test.pid
fi

# 停止前端服务
echo "🌐 停止前端服务..."
if [ -f "logs/frontend_test.pid" ]; then
    FRONTEND_PID=$(cat logs/frontend_test.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        echo "停止前端进程 (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID
    fi
    rm -f logs/frontend_test.pid
fi

# 清理端口占用
echo "🧹 清理端口占用..."
pkill -f "uvicorn.*8001" 2>/dev/null || true
pkill -f "vite.*3001" 2>/dev/null || true

echo "✅ 简化测试环境已停止" 