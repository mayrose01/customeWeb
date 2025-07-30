#!/bin/bash

# 测试环境演示脚本
echo "🎬 测试环境演示脚本"
echo "=================="

# 检查测试环境是否运行
echo "🔍 检查测试环境状态..."
if ! docker ps | grep -q "enterprise.*test"; then
    echo "❌ 测试环境未运行，请先启动测试环境："
    echo "   ./start_test_env.sh"
    exit 1
fi

echo "✅ 测试环境正在运行"

# 显示服务信息
echo ""
echo "📊 服务信息："
echo "   前端应用: http://localhost:3001"
echo "   后端API: http://localhost:8001"
echo "   Nginx代理: http://localhost:8080"
echo "   数据库: localhost:3307"

# 测试API连接
echo ""
echo "🧪 测试API连接..."

# 测试后端健康检查
echo "测试后端健康检查..."
if curl -s http://localhost:8001/health > /dev/null 2>&1; then
    echo "✅ 后端API 健康检查通过"
else
    echo "❌ 后端API 健康检查失败"
fi

# 测试前端连接
echo "测试前端连接..."
if curl -s http://localhost:3001 > /dev/null 2>&1; then
    echo "✅ 前端服务 连接正常"
else
    echo "❌ 前端服务 连接失败"
fi

# 测试Nginx代理
echo "测试Nginx代理..."
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ Nginx代理 连接正常"
else
    echo "❌ Nginx代理 连接失败"
fi

# 测试数据库连接
echo "测试数据库连接..."
if docker exec enterprise_mysql_test mysql -u test_user -ptest_password -e "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ 数据库连接 正常"
else
    echo "❌ 数据库连接 失败"
fi

# 显示容器状态
echo ""
echo "📦 容器状态："
docker-compose -f docker-compose.test.yml ps

# 显示资源使用情况
echo ""
echo "💾 资源使用情况："
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# 显示日志摘要
echo ""
echo "📝 最近日志摘要："
echo "后端日志 (最近5行):"
docker-compose -f docker-compose.test.yml logs --tail=5 backend_test

echo ""
echo "前端日志 (最近5行):"
docker-compose -f docker-compose.test.yml logs --tail=5 frontend_test

echo ""
echo "🎉 测试环境演示完成！"
echo ""
echo "💡 提示："
echo "   - 访问 http://localhost:3001 查看前端应用"
echo "   - 访问 http://localhost:8001/docs 查看API文档"
echo "   - 访问 http://localhost:8080 通过Nginx代理访问"
echo "   - 使用 ./test_env_check.sh 进行详细检查"
echo "   - 使用 ./stop_test_env.sh 停止测试环境" 