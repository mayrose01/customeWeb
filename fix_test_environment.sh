#!/bin/bash

echo "🔧 修复测试环境数据不一致问题..."

# 1. 停止所有相关服务
echo "🛑 停止现有服务..."
pkill -f "uvicorn.*8001" 2>/dev/null
docker-compose -f docker-compose.test.yml down 2>/dev/null

# 2. 备份现有测试数据库
echo "💾 备份现有测试数据库..."
if mysql -u root -p -e "USE enterprise_test;" > /dev/null 2>&1; then
    echo "📦 创建测试数据库备份..."
    mysqldump -u root -p enterprise_test > enterprise_test_backup_$(date +%Y%m%d_%H%M%S).sql
    echo "✅ 备份完成"
else
    echo "⚠️ 测试数据库不存在，跳过备份"
fi

# 3. 重新创建测试数据库
echo "🗄️ 重新创建测试数据库..."
mysql -u root -p -e "DROP DATABASE IF EXISTS enterprise_test;"
mysql -u root -p -e "CREATE DATABASE enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 4. 初始化测试数据库
echo "📝 初始化测试数据库..."
mysql -u root -p enterprise_test < mysql/init.sql
echo "✅ 测试数据库初始化完成"

# 5. 检查数据库状态
echo "🔍 检查测试数据库状态..."
echo "📊 测试数据库表结构："
mysql -u root -p -e "USE enterprise_test; SHOW TABLES;" 2>/dev/null

echo ""
echo "📈 测试数据库数据量："
mysql -u root -p -e "USE enterprise_test; SELECT 'users' as table_name, COUNT(*) as count FROM users UNION ALL SELECT 'products' as table_name, COUNT(*) as count FROM products UNION ALL SELECT 'categories' as table_name, COUNT(*) as count FROM categories UNION ALL SELECT 'company_info' as table_name, COUNT(*) as count FROM company_info;" 2>/dev/null

# 6. 创建正确的测试环境启动脚本
echo "📝 创建测试环境启动脚本..."
cat > start_test_fixed.sh << 'EOF'
#!/bin/bash

echo "🚀 启动修复后的测试环境..."

# 设置环境变量
export ENV=test
export DATABASE_URL="mysql+pymysql://root:root@localhost:3306/enterprise_test"

# 进入后端目录
cd enterprise-backend

# 激活虚拟环境（如果存在）
if [ -d ".venv" ]; then
    source .venv/bin/activate
fi

# 启动服务
echo "🔧 启动后端服务 (端口: 8001)..."
echo "📋 环境信息："
echo "   - 环境: test"
echo "   - 数据库: enterprise_test"
echo "   - 端口: 8001"

python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
EOF

chmod +x start_test_fixed.sh

# 7. 显示修复结果
echo ""
echo "✅ 修复完成！"
echo ""
echo "📋 修复内容："
echo "   1. ✅ 重新创建了测试数据库 enterprise_test"
echo "   2. ✅ 使用正确的初始化脚本初始化数据库"
echo "   3. ✅ 创建了修复后的启动脚本 start_test_fixed.sh"
echo ""
echo "🚀 启动测试环境："
echo "   ./start_test_fixed.sh"
echo ""
echo "🌐 访问地址："
echo "   - API文档: http://localhost:8001/docs"
echo "   - 前端应用: http://localhost:3001"
echo ""
echo "🔍 验证步骤："
echo "   1. 启动测试环境"
echo "   2. 访问 http://localhost:8001/docs"
echo "   3. 检查数据是否正确显示"
echo ""
echo "⚠️ 注意："
echo "   - 测试环境现在使用独立的数据库 enterprise_test"
echo "   - 与开发环境 enterprise_dev 完全分离"
echo "   - 数据不会相互影响" 