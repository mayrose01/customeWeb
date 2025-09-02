#!/bin/bash

echo "🚀 启动本地生产环境测试..."

# 检查端口是否被占用
if lsof -Pi :8002 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  端口8002已被占用，正在停止现有服务..."
    pkill -f "uvicorn.*8002"
    sleep 2
fi

if lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  端口3002已被占用，正在停止现有服务..."
    pkill -f "vite.*3002"
    sleep 2
fi

# 启动生产环境后端
echo "📡 启动生产环境后端 (端口8002)..."
cd enterprise-backend

# 使用生产环境配置
export DATABASE_URL="mysql://enterprise_user:YOUR_DATABASE_PASSWORD_HERE@localhost:3306/enterprise_pro"
export SECRET_KEY="catusfoto_enterprise_secret_key_2024"
export ALGORITHM="HS256"
export ACCESS_TOKEN_EXPIRE_MINUTES=1440
export CORS_ORIGINS='["http://localhost:3002", "https://catusfoto.top"]'
export SMTP_SERVER="smtp.gmail.com"
export SMTP_PORT=587
export SMTP_USERNAME="your-email@gmail.com"
export SMTP_PASSWORD="your-app-password"
export UPLOAD_DIR="uploads"
export MAX_FILE_SIZE=2097152
export LOG_LEVEL="INFO"
export LOG_FILE="logs/app.log"

python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8002 --reload &
BACKEND_PID=$!

# 等待后端启动
sleep 3

# 检查后端是否启动成功
if curl -s http://localhost:8002/api/company/ > /dev/null; then
    echo "✅ 生产环境后端启动成功"
else
    echo "❌ 生产环境后端启动失败"
    exit 1
fi

# 启动生产环境前端
echo "🌐 启动生产环境前端 (端口3002)..."
cd ../enterprise-frontend

# 设置生产环境变量
export VITE_APP_ENV=production
export VITE_API_BASE_URL=http://localhost:8002/api
export VITE_UPLOAD_PATH=/uploads
export VITE_PUBLIC_PATH=/
export VITE_DEBUG=false

echo "环境变量设置完成:"
echo "VITE_APP_ENV: $VITE_APP_ENV"
echo "VITE_API_BASE_URL: $VITE_API_BASE_URL"

# 启动开发服务器但使用生产环境配置
npm run dev:prod -- --port 3002 &
FRONTEND_PID=$!

# 等待前端启动
sleep 5

# 检查前端是否启动成功
if curl -s http://localhost:3002 > /dev/null; then
    echo "✅ 生产环境前端启动成功"
else
    echo "❌ 生产环境前端启动失败"
    exit 1
fi

echo ""
echo "🎯 本地生产环境启动完成！"
echo "📋 访问信息："
echo "   🔧 后端API: http://localhost:8002"
echo "   🌐 前端应用: http://localhost:3002"
echo "   🗄️ 数据库: enterprise_pro (端口3306)"
echo ""
echo "💡 测试步骤："
echo "   1. 访问 http://localhost:3002"
echo "   2. 打开浏览器开发者工具"
echo "   3. 查看Network标签中的API请求"
echo "   4. 确认API请求指向 http://localhost:8002/api"
echo ""
echo "💡 管理命令："
echo "   停止后端: pkill -f 'uvicorn.*8002'"
echo "   停止前端: pkill -f 'vite.*3002'"
echo "   查看日志: tail -f enterprise-backend/logs/app_$(date +%Y%m%d).log" 