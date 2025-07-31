#!/bin/bash

# 测试远程API连接脚本
echo "🔍 测试远程API连接..."

# 测试域名解析
echo "📡 测试域名解析..."
if nslookup test.catusfoto.top > /dev/null 2>&1; then
    echo "✅ 域名解析正常"
else
    echo "❌ 域名解析失败，请检查hosts文件或DNS设置"
    echo "建议在 /etc/hosts 中添加："
    echo "127.0.0.1 test.catusfoto.top"
fi

# 测试端口连接
echo "🔌 测试端口连接..."
if nc -z test.catusfoto.top 8001 2>/dev/null; then
    echo "✅ 端口 8001 可访问"
else
    echo "❌ 端口 8001 无法访问"
    echo "请确保测试环境服务正在运行"
fi

# 测试API端点
echo "🌐 测试API端点..."
API_URL="http://test.catusfoto.top:8001/api"
if curl -s "$API_URL" > /dev/null 2>&1; then
    echo "✅ API端点可访问"
else
    echo "❌ API端点无法访问"
    echo "请检查："
    echo "1. 测试环境服务是否启动"
    echo "2. 端口 8001 是否正确映射"
    echo "3. CORS配置是否正确"
fi

# 测试登录端点
echo "🔐 测试登录端点..."
LOGIN_URL="http://test.catusfoto.top:8001/api/user/login"
if curl -s -X POST "$LOGIN_URL" -H "Content-Type: application/json" -d '{"username":"test","password":"test"}' > /dev/null 2>&1; then
    echo "✅ 登录端点可访问"
else
    echo "❌ 登录端点无法访问"
fi

echo ""
echo "📋 测试环境配置信息："
echo "   - 前端地址: http://test.catusfoto.top:3001"
echo "   - 后端API: http://test.catusfoto.top:8001/api"
echo "   - 数据库: enterprise_test"
echo "   - 环境: test"

echo ""
echo "🔧 启动测试环境的命令："
echo "   # 使用Docker Compose"
echo "   docker-compose -f docker-compose.test.yml up -d"
echo ""
echo "   # 或手动启动后端"
echo "   cd enterprise-backend"
echo "   ENV=test python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001" 