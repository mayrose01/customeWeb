#!/bin/bash

# 依赖版本同步脚本
# 确保所有环境使用相同版本的依赖库

echo "🔧 开始同步依赖版本..."

# 1. 检查当前环境的依赖版本
echo "📋 当前环境依赖版本:"
pip freeze

# 2. 生成精确的依赖锁定文件
echo "📝 生成依赖锁定文件..."
pip freeze > requirements-lock.txt

# 3. 检查是否有版本差异
echo "🔍 检查版本差异..."
if [ -f "requirements-lock.txt" ]; then
    echo "✅ 依赖锁定文件已生成: requirements-lock.txt"
    echo "📊 主要依赖版本:"
    grep -E "(fastapi|uvicorn|sqlalchemy|pydantic|passlib|bcrypt|python-jose)" requirements-lock.txt
else
    echo "❌ 依赖锁定文件生成失败"
    exit 1
fi

# 4. 提供部署建议
echo ""
echo "📋 部署建议:"
echo "1. 在部署前运行: pip install -r requirements-lock.txt"
echo "2. 确保所有环境使用相同的Python版本"
echo "3. 定期更新依赖锁定文件"
echo "4. 使用Docker容器确保环境一致性"

echo ""
echo "✅ 依赖版本同步完成" 