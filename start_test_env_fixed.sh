#!/bin/bash

# 修复版测试环境启动脚本
echo "🚀 启动企业管理系统测试环境（修复版）..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

# 创建必要的目录
echo "📁 创建必要的目录..."
mkdir -p enterprise-backend/uploads_test
mkdir -p enterprise-backend/logs
mkdir -p nginx/ssl

# 停止并删除现有的测试容器
echo "🧹 清理现有测试容器..."
docker-compose -f docker-compose.test.yml down -v 2>/dev/null || true

# 清理Docker缓存
echo "🧹 清理Docker缓存..."
docker system prune -f

# 构建并启动测试环境
echo "🔨 构建测试环境镜像..."
docker-compose -f docker-compose.test.yml build --no-cache

echo "🚀 启动测试环境服务..."
docker-compose -f docker-compose.test.yml up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 30

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose -f docker-compose.test.yml ps

# 检查服务健康状态
echo "🔍 检查服务健康状态..."
echo "=== 后端服务日志 ==="
docker-compose -f docker-compose.test.yml logs backend --tail 20
echo "=== 前端服务日志 ==="
docker-compose -f docker-compose.test.yml logs frontend --tail 20
echo "=== MySQL服务日志 ==="
docker-compose -f docker-compose.test.yml logs mysql_test --tail 10

# 测试服务连接
echo "🔍 测试服务连接..."
echo "测试后端API连接..."
if curl -s http://localhost:8001/health > /dev/null; then
    echo "✅ 后端API服务正常"
else
    echo "❌ 后端API服务异常"
fi

echo "测试前端服务连接..."
if curl -s http://localhost:3001 > /dev/null; then
    echo "✅ 前端服务正常"
else
    echo "❌ 前端服务异常"
fi

echo "测试Nginx代理连接..."
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ Nginx代理服务正常"
else
    echo "❌ Nginx代理服务异常"
fi

# 显示访问信息
echo ""
echo "✅ 测试环境启动完成！"
echo ""
echo "📋 访问信息："
echo "   🌐 前端应用: http://localhost:3001"
echo "   🔧 后端API: http://localhost:8001"
echo "   🌐 Nginx代理: http://localhost:8080"
echo "   🗄️  MySQL数据库: localhost:3307"
echo ""
echo "📊 数据库信息："
echo "   数据库名: enterprise_test"
echo "   用户名: test_user"
echo "   密码: test_password"
echo "   端口: 3307"
echo ""
echo "🔧 管理命令："
echo "   查看日志: docker-compose -f docker-compose.test.yml logs -f"
echo "   停止服务: docker-compose -f docker-compose.test.yml down"
echo "   重启服务: docker-compose -f docker-compose.test.yml restart"
echo ""
echo "📝 测试环境与开发环境的区别："
echo "   - 使用独立的数据库 (enterprise_test)"
echo "   - 使用不同的端口 (3001, 8001, 8080, 3307)"
echo "   - 独立的文件上传目录 (uploads_test)"
echo "   - 独立的日志文件 (app_test.log)"
echo "   - 调试级别的日志记录"
echo ""
