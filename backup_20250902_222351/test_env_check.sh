#!/bin/bash

# 测试环境检查脚本
echo "🔍 检查测试环境状态..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行"
    exit 1
fi

# 检查容器状态
echo "📊 容器状态："
docker-compose -f docker-compose.test.yml ps

# 检查端口占用
echo ""
echo "🔌 端口检查："
echo "检查端口 3001 (前端):"
if lsof -i :3001 > /dev/null 2>&1; then
    echo "✅ 端口 3001 正在使用"
else
    echo "❌ 端口 3001 未使用"
fi

echo "检查端口 8001 (后端):"
if lsof -i :8001 > /dev/null 2>&1; then
    echo "✅ 端口 8001 正在使用"
else
    echo "❌ 端口 8001 未使用"
fi

echo "检查端口 3307 (数据库):"
if lsof -i :3307 > /dev/null 2>&1; then
    echo "✅ 端口 3307 正在使用"
else
    echo "❌ 端口 3307 未使用"
fi

echo "检查端口 8080 (Nginx):"
if lsof -i :8080 > /dev/null 2>&1; then
    echo "✅ 端口 8080 正在使用"
else
    echo "❌ 端口 8080 未使用"
fi

# 检查服务健康状态
echo ""
echo "🏥 服务健康检查："

# 检查后端API
echo "检查后端API (http://localhost:8001):"
if curl -s http://localhost:8001/health > /dev/null 2>&1; then
    echo "✅ 后端API 正常"
else
    echo "❌ 后端API 无响应"
fi

# 检查前端
echo "检查前端 (http://localhost:3001):"
if curl -s http://localhost:3001 > /dev/null 2>&1; then
    echo "✅ 前端服务 正常"
else
    echo "❌ 前端服务 无响应"
fi

# 检查Nginx
echo "检查Nginx (http://localhost:8080):"
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ Nginx代理 正常"
else
    echo "❌ Nginx代理 无响应"
fi

# 检查数据库连接
echo ""
echo "🗄️ 数据库连接检查："
if docker exec enterprise_mysql_test mysql -u test_user -ptest_password -e "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ MySQL数据库 连接正常"
else
    echo "❌ MySQL数据库 连接失败"
fi

# 显示日志摘要
echo ""
echo "📝 最近日志摘要："
echo "后端日志 (最近10行):"
docker-compose -f docker-compose.test.yml logs --tail=10 backend_test

echo ""
echo "前端日志 (最近10行):"
docker-compose -f docker-compose.test.yml logs --tail=10 frontend_test

echo ""
echo "✅ 测试环境检查完成！" 