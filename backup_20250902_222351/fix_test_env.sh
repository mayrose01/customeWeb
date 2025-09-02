#!/bin/bash

echo "🔧 修复测试环境死循环问题..."

# 1. 检查后端服务状态
echo "📡 检查后端服务..."
if curl -s http://localhost:8001/api/company/ > /dev/null; then
    echo "✅ 后端服务运行正常 (端口8001)"
else
    echo "❌ 后端服务未运行，正在启动..."
    cd enterprise-backend && python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload --env-file test.env &
    sleep 5
fi

# 2. 检查前端服务状态
echo "🌐 检查前端服务..."
if curl -s http://localhost:3001 > /dev/null; then
    echo "✅ 前端服务运行正常 (端口3001)"
else
    echo "❌ 前端服务未运行，正在启动..."
    cd enterprise-frontend && npm run dev -- --mode test &
    sleep 5
fi

# 3. 检查数据库连接
echo "🗄️ 检查数据库连接..."
if mysql -h 127.0.0.1 -P 3307 -u test_user -ptest_password -e "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ 数据库连接正常 (端口3307)"
else
    echo "❌ 数据库连接失败"
fi

echo ""
echo "🎯 修复完成！"
echo "📋 测试环境访问信息："
echo "   🌐 前端: http://localhost:3001"
echo "   🔧 后端: http://localhost:8001"
echo "   🗄️ 数据库: localhost:3307"
echo ""
echo "💡 如果仍有死循环问题，请："
echo "   1. 清除浏览器缓存 (Ctrl+Shift+R)"
echo "   2. 打开开发者工具清除localStorage"
echo "   3. 刷新页面" 