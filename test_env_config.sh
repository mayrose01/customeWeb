#!/bin/bash

echo "🔍 测试环境配置..."

echo ""
echo "=== 开发环境测试 ==="
echo "启动开发环境后端..."
cd enterprise-backend
ENV=development python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --env-file dev.env &
DEV_BACKEND_PID=$!

sleep 3

echo "测试开发环境后端..."
if curl -s http://localhost:8000/api/company/ > /dev/null; then
    echo "✅ 开发环境后端正常"
else
    echo "❌ 开发环境后端异常"
fi

echo "启动开发环境前端..."
cd ../enterprise-frontend
npm run dev:test-only -- --mode development &
DEV_FRONTEND_PID=$!

sleep 5

echo "测试开发环境前端..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ 开发环境前端正常"
else
    echo "❌ 开发环境前端异常"
fi

echo ""
echo "=== 测试环境测试 ==="
echo "启动测试环境后端..."
cd ../enterprise-backend
ENV=test python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload --env-file test.env &
TEST_BACKEND_PID=$!

sleep 3

echo "测试测试环境后端..."
if curl -s http://localhost:8001/api/company/ > /dev/null; then
    echo "✅ 测试环境后端正常"
else
    echo "❌ 测试环境后端异常"
fi

echo "启动测试环境前端..."
cd ../enterprise-frontend
npm run dev:test-only &
TEST_FRONTEND_PID=$!

sleep 5

echo "测试测试环境前端..."
if curl -s http://localhost:3001 > /dev/null; then
    echo "✅ 测试环境前端正常"
else
    echo "❌ 测试环境前端异常"
fi

echo ""
echo "🎯 环境测试完成！"
echo "📋 访问地址："
echo "   开发环境: http://localhost:3000"
echo "   测试环境: http://localhost:3001"
echo ""
echo "💡 停止所有服务:"
echo "   pkill -f 'uvicorn.*8000'"
echo "   pkill -f 'uvicorn.*8001'"
echo "   pkill -f 'vite.*3000'"
echo "   pkill -f 'vite.*3001'" 