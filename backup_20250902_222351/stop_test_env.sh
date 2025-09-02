#!/bin/bash

# 测试环境停止脚本
echo "🛑 停止企业管理系统测试环境..."

# 停止并删除测试容器
echo "🧹 停止测试容器..."
docker-compose -f docker-compose.test.yml down -v

# 删除测试数据卷（可选）
read -p "是否删除测试数据卷？这将清除所有测试数据 (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️ 删除测试数据卷..."
    docker volume rm enterprise_mysql_test_data 2>/dev/null || true
    echo "✅ 测试数据卷已删除"
fi

echo "✅ 测试环境已停止" 