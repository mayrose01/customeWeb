#!/bin/bash

# 从开发环境复制数据库到测试环境

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🔄 从开发环境复制数据库到测试环境...${NC}"

# 检查开发环境数据库连接
echo -e "${BLUE}🔍 检查开发环境数据库...${NC}"
if ! mysql -u root -proot -e "USE enterprise_dev;" 2>/dev/null; then
    echo -e "${RED}❌ 开发环境数据库连接失败${NC}"
    exit 1
fi

# 检查测试环境Docker容器
echo -e "${BLUE}🔍 检查测试环境Docker容器...${NC}"
if ! docker exec enterprise_mysql_test mysql -u test_user -ptest_password -e "SELECT 1;" 2>/dev/null; then
    echo -e "${RED}❌ 测试环境数据库连接失败，请先启动测试环境${NC}"
    exit 1
fi

# 1. 导出开发环境数据库结构和数据
echo -e "${YELLOW}📤 导出开发环境数据库...${NC}"
mysqldump -u root -proot --routines --triggers --single-transaction enterprise_dev > /tmp/enterprise_dev_backup.sql

# 2. 修改SQL文件，将数据库名从enterprise_dev改为enterprise_test
echo -e "${YELLOW}🔧 修改数据库名称...${NC}"
sed 's/enterprise_dev/enterprise_test/g' /tmp/enterprise_dev_backup.sql > /tmp/enterprise_test_import.sql

# 3. 清空测试环境数据库
echo -e "${YELLOW}🧹 清空测试环境数据库...${NC}"
docker exec enterprise_mysql_test mysql -u test_user -ptest_password -e "DROP DATABASE IF EXISTS enterprise_test; CREATE DATABASE enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 4. 导入数据到测试环境
echo -e "${YELLOW}📥 导入数据到测试环境...${NC}"
docker exec -i enterprise_mysql_test mysql -u test_user -ptest_password enterprise_test < /tmp/enterprise_test_import.sql

# 5. 验证导入结果
echo -e "${BLUE}🔍 验证导入结果...${NC}"
TABLE_COUNT=$(docker exec enterprise_mysql_test mysql -u test_user -ptest_password -e "USE enterprise_test; SHOW TABLES;" | wc -l)
echo -e "${GREEN}✅ 成功导入 $((TABLE_COUNT-1)) 个表${NC}"

# 6. 显示表列表
echo -e "${BLUE}📋 测试环境表列表:${NC}"
docker exec enterprise_mysql_test mysql -u test_user -ptest_password -e "USE enterprise_test; SHOW TABLES;"

# 7. 检查用户数据
echo -e "${BLUE}👥 检查用户数据:${NC}"
docker exec enterprise_mysql_test mysql -u test_user -ptest_password -e "USE enterprise_test; SELECT username, email, role FROM users LIMIT 5;"

# 清理临时文件
rm -f /tmp/enterprise_dev_backup.sql /tmp/enterprise_test_import.sql

echo -e "${GREEN}🎉 数据库复制完成！${NC}"
echo -e "${BLUE}📋 测试环境访问信息:${NC}"
echo -e "   🌐 前端: http://localhost:3001"
echo -e "   🔧 后端: http://localhost:8001"
echo -e "   🗄️  数据库: localhost:3307"
echo -e "   👤 管理员: admin / admin123"
