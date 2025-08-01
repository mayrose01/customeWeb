#!/bin/bash

# 生产环境部署脚本
echo "开始生产环境部署..."

# 设置生产环境变量
export VITE_APP_ENV=production
export VITE_API_BASE_URL=https://catusfoto.top/api
export VITE_UPLOAD_PATH=/uploads
export VITE_PUBLIC_PATH=/
export VITE_DEBUG=false

echo "环境变量设置完成:"
echo "VITE_APP_ENV: $VITE_APP_ENV"
echo "VITE_API_BASE_URL: $VITE_API_BASE_URL"

# 清理之前的构建
echo "清理之前的构建..."
rm -rf dist/

# 执行生产环境构建
echo "开始构建..."
npm run build:prod

# 检查构建结果
if [ -d "dist" ]; then
    echo "构建成功！"
    echo "检查构建后的API配置..."
    
    # 检查是否还有localhost:8000的引用
    if grep -r "localhost:8000" dist/ > /dev/null 2>&1; then
        echo "警告: 构建文件中仍包含 localhost:8000 引用"
        grep -r "localhost:8000" dist/ | head -5
    else
        echo "✓ 构建文件中没有 localhost:8000 引用"
    fi
    
    # 检查API配置
    if grep -r "catusfoto.top" dist/ > /dev/null 2>&1; then
        echo "✓ 构建文件中包含正确的生产环境API地址"
    else
        echo "警告: 构建文件中没有找到生产环境API地址"
    fi
    
    echo "构建完成，可以部署到生产环境"
else
    echo "构建失败！"
    exit 1
fi 