#!/bin/bash

echo "🧪 测试生产环境API调用..."

echo ""
echo "📡 测试后端API (端口8002):"
echo "================================"

# 测试公司信息API
echo "1. 测试公司信息API:"
curl -s http://localhost:8002/api/company/ | jq '.name, .email, .phone' 2>/dev/null || curl -s http://localhost:8002/api/company/

echo ""
echo "2. 测试分类API:"
curl -s http://localhost:8002/api/category/ | jq '.[0].name' 2>/dev/null || curl -s http://localhost:8002/api/category/ | head -3

echo ""
echo "3. 测试产品API:"
curl -s http://localhost:8002/api/product/ | jq '.[0].title' 2>/dev/null || curl -s http://localhost:8002/api/product/ | head -3

echo ""
echo "🌐 测试前端页面 (端口3003):"
echo "================================"

# 测试前端页面
echo "1. 测试前端首页:"
curl -s http://localhost:3003 | grep -o '<title>[^<]*</title>' || echo "无法获取页面标题"

echo ""
echo "2. 检查前端是否包含API调用:"
echo "请手动访问 http://localhost:3003 并检查浏览器开发者工具中的Network标签"

echo ""
echo "🔍 环境配置检查:"
echo "================================"

echo "1. 检查后端环境变量:"
echo "DATABASE_URL: $DATABASE_URL"
echo "CORS_ORIGINS: $CORS_ORIGINS"

echo ""
echo "2. 检查前端环境变量:"
echo "VITE_APP_ENV: $VITE_APP_ENV"
echo "VITE_API_BASE_URL: $VITE_API_BASE_URL"

echo ""
echo "📋 测试步骤:"
echo "================================"
echo "1. 访问 http://localhost:3003"
echo "2. 打开浏览器开发者工具 (F12)"
echo "3. 切换到Network标签"
echo "4. 刷新页面"
echo "5. 查看API请求是否指向 http://localhost:8002/api"
echo "6. 如果看到 localhost:8000，说明还有问题"
echo "7. 如果看到 localhost:8002，说明修复成功"

echo ""
echo "✅ 测试完成！" 