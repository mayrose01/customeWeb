#!/bin/bash

echo "🚀 启动企业网站开发环境..."

# 检查是否在正确的目录
if [ ! -f "app/main.py" ]; then
    echo "❌ 请在 enterprise-backend 目录下运行此脚本"
    exit 1
fi

# 设置环境变量
export ENVIRONMENT=development
export DATABASE_URL="mysql+pymysql://root:root@localhost:3306/enterprise_dev"

echo "✅ 环境变量设置完成:"
echo "   ENVIRONMENT: $ENVIRONMENT"
echo "   DATABASE_URL: $DATABASE_URL"

# 检查MySQL服务状态
echo "🔍 检查MySQL服务状态..."
if ! mysql -u root -p -e "SELECT 1" >/dev/null 2>&1; then
    echo "❌ MySQL服务未运行或无法连接"
    echo "请先启动MySQL服务: brew services start mysql"
    exit 1
fi

echo "✅ MySQL服务正常"

# 检查数据库是否存在
echo "🔍 检查数据库..."
if ! mysql -u root -p -e "USE enterprise_dev" >/dev/null 2>&1; then
    echo "⚠️  数据库 enterprise_dev 不存在，正在创建..."
    mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS enterprise_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo "✅ 数据库创建完成"
else
    echo "✅ 数据库 enterprise_dev 已存在"
fi

# 检查商城表是否存在
echo "🔍 检查商城相关表..."
TABLES=$(mysql -u root -p -e "SHOW TABLES FROM enterprise_dev LIKE 'mall_%';" 2>/dev/null | wc -l)

if [ $TABLES -eq 0 ]; then
    echo "⚠️  商城表不存在，正在创建..."
    python3 create_mall_tables.py
    if [ $? -eq 0 ]; then
        echo "✅ 商城表创建完成"
    else
        echo "❌ 商城表创建失败"
        exit 1
    fi
else
    echo "✅ 商城相关表已存在"
fi

echo "🎯 启动后端服务..."
echo "   服务地址: http://localhost:8000"
echo "   API文档: http://localhost:8000/docs"
echo "   按 Ctrl+C 停止服务"

# 启动后端服务
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
