#!/bin/bash

# 测试环境启动脚本
echo "🚀 启动企业管理系统测试环境..."

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
docker-compose -f docker-compose.test.yml down -v

# 构建并启动测试环境
echo "🔨 构建测试环境镜像..."
docker-compose -f docker-compose.test.yml build

echo "🚀 启动测试环境服务..."
docker-compose -f docker-compose.test.yml up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 30

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose -f docker-compose.test.yml ps

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
echo "   数据库名: enterprise_test_db"
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
echo "   - 使用独立的数据库 (enterprise_test_db)"
echo "   - 使用不同的端口 (3001, 8001, 8080, 3307)"
echo "   - 独立的文件上传目录 (uploads_test)"
echo "   - 独立的日志文件 (app_test.log)"
echo "   - 调试级别的日志记录"
echo "" 