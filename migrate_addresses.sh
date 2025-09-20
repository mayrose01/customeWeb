#!/bin/bash

# 迁移mall_addresses表从开发环境到测试环境

echo "开始迁移mall_addresses表..."

# 1. 导出开发环境的mall_addresses表
echo "1. 导出开发环境的mall_addresses表..."
mysqldump -h localhost -P 3306 -u root -proot --no-create-info enterprise_dev mall_addresses > mall_addresses_dev.sql

# 2. 清空测试环境的mall_addresses表
echo "2. 清空测试环境的mall_addresses表..."
mysql -h localhost -P 3307 -u test_user -ptest_password -e "USE enterprise_test; DELETE FROM mall_addresses;"

# 3. 导入数据到测试环境
echo "3. 导入数据到测试环境..."
mysql -h localhost -P 3307 -u test_user -ptest_password enterprise_test < mall_addresses_dev.sql

# 4. 清理临时文件
echo "4. 清理临时文件..."
rm -f mall_addresses_dev.sql

echo "mall_addresses表迁移完成！"

# 验证迁移结果
echo "验证迁移结果..."
echo "开发环境数据："
mysql -h localhost -P 3306 -u root -proot -e "USE enterprise_dev; SELECT COUNT(*) as count FROM mall_addresses;"

echo "测试环境数据："
mysql -h localhost -P 3307 -u test_user -ptest_password -e "USE enterprise_test; SELECT COUNT(*) as count FROM mall_addresses;"
