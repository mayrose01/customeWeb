#!/bin/bash

echo "🔍 检查测试环境配置和数据状态..."

# 检查当前环境变量
echo "📋 当前环境变量："
echo "ENV: $ENV"
echo "DATABASE_URL: $DATABASE_URL"

# 检查数据库连接
echo ""
echo "🗄️ 检查数据库连接..."

# 检查MySQL服务是否运行
if mysql -u root -p -e "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ MySQL服务正在运行"
else
    echo "❌ MySQL服务未运行"
    exit 1
fi

# 检查测试数据库是否存在
if mysql -u root -p -e "USE enterprise_test;" > /dev/null 2>&1; then
    echo "✅ 测试数据库 enterprise_test 存在"
    
    # 检查表结构
    echo ""
    echo "📊 检查测试数据库表结构："
    mysql -u root -p -e "USE enterprise_test; SHOW TABLES;" 2>/dev/null
    
    # 检查数据量
    echo ""
    echo "📈 检查测试数据库数据量："
    mysql -u root -p -e "USE enterprise_test; SELECT 'users' as table_name, COUNT(*) as count FROM users UNION ALL SELECT 'products' as table_name, COUNT(*) as count FROM products UNION ALL SELECT 'categories' as table_name, COUNT(*) as count FROM categories UNION ALL SELECT 'company_info' as table_name, COUNT(*) as count FROM company_info;" 2>/dev/null
    
else
    echo "❌ 测试数据库 enterprise_test 不存在"
    echo "🔧 创建测试数据库..."
    mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo "📝 初始化测试数据库..."
    mysql -u root -p enterprise_test < mysql/init.sql
fi

# 检查开发数据库
echo ""
echo "🔍 检查开发数据库 enterprise_dev："
if mysql -u root -p -e "USE enterprise_dev;" > /dev/null 2>&1; then
    echo "✅ 开发数据库 enterprise_dev 存在"
    echo "📈 开发数据库数据量："
    mysql -u root -p -e "USE enterprise_dev; SELECT 'users' as table_name, COUNT(*) as count FROM users UNION ALL SELECT 'products' as table_name, COUNT(*) as count FROM products UNION ALL SELECT 'categories' as table_name, COUNT(*) as count FROM categories UNION ALL SELECT 'company_info' as table_name, COUNT(*) as count FROM company_info;" 2>/dev/null
else
    echo "❌ 开发数据库 enterprise_dev 不存在"
fi

# 检查后端服务配置
echo ""
echo "🔧 检查后端服务配置..."
cd enterprise-backend

if [ -f "test.env" ]; then
    echo "✅ test.env 配置文件存在"
    echo "📋 test.env 内容："
    cat test.env
else
    echo "❌ test.env 配置文件不存在"
fi

echo ""
echo "🎯 建议的解决方案："

echo "1. 确保启动测试环境时设置正确的环境变量："
echo "   export ENV=test"
echo "   export DATABASE_URL='mysql+pymysql://root:root@localhost:3306/enterprise_test'"

echo ""
echo "2. 重新启动测试环境："
echo "   cd enterprise-backend"
echo "   export ENV=test"
echo "   python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001"

echo ""
echo "3. 如果数据不一致，可以重新初始化测试数据库："
echo "   mysql -u root -p -e 'DROP DATABASE IF EXISTS enterprise_test;'"
echo "   mysql -u root -p -e 'CREATE DATABASE enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'"
echo "   mysql -u root -p enterprise_test < mysql/init.sql"

echo ""
echo "4. 检查Docker容器配置（如果使用Docker）："
echo "   docker-compose -f docker-compose.test.yml down"
echo "   docker-compose -f docker-compose.test.yml up -d" 