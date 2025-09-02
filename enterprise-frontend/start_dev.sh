#!/bin/bash

echo "🚀 启动企业网站前端开发环境..."

# 检查是否在正确的目录
if [ ! -f "package.json" ]; then
    echo "❌ 请在 enterprise-frontend 目录下运行此脚本"
    exit 1
fi

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js"
    exit 1
fi

# 检查npm是否可用
if ! command -v npm &> /dev/null; then
    echo "❌ npm 未安装，请先安装 npm"
    exit 1
fi

echo "✅ Node.js 版本: $(node --version)"
echo "✅ npm 版本: $(npm --version)"

# 检查依赖是否安装
if [ ! -d "node_modules" ]; then
    echo "⚠️  依赖未安装，正在安装..."
    npm install
    if [ $? -eq 0 ]; then
        echo "✅ 依赖安装完成"
    else
        echo "❌ 依赖安装失败"
        exit 1
    fi
else
    echo "✅ 依赖已安装"
fi

echo "🎯 启动前端开发服务器..."
echo "   服务地址: http://localhost:3000"
echo "   管理后台: http://localhost:3000/admin/mall"
echo "   按 Ctrl+C 停止服务"

# 启动前端服务
npm run dev
