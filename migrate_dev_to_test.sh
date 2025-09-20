#!/bin/bash

# 开发环境数据库迁移到测试环境脚本
# 开发环境：localhost:3306, root/root, enterprise_dev
# 测试环境：localhost:3307, test_user/test_password, enterprise_test

echo "开始迁移开发环境数据库到测试环境..."

# 1. 导出开发环境数据库结构
echo "1. 导出开发环境数据库结构..."
mysqldump -h localhost -P 3306 -u root -proot --no-data --routines --triggers enterprise_dev > dev_structure.sql

# 2. 导出开发环境数据库数据
echo "2. 导出开发环境数据库数据..."
mysqldump -h localhost -P 3306 -u root -proot --no-create-info --ignore-table=enterprise_dev.mall_addresses enterprise_dev > dev_data.sql

# 3. 导出mall_addresses表数据（单独处理，因为测试环境可能已有此表）
echo "3. 导出mall_addresses表数据..."
mysqldump -h localhost -P 3306 -u root -proot --no-create-info enterprise_dev mall_addresses > mall_addresses_data.sql

# 4. 备份测试环境数据库
echo "4. 备份测试环境数据库..."
mysqldump -h localhost -P 3307 -u test_user -ptest_password enterprise_test > test_backup_$(date +%Y%m%d_%H%M%S).sql

# 5. 清空测试环境数据库
echo "5. 清空测试环境数据库..."
mysql -h localhost -P 3307 -u test_user -ptest_password -e "DROP DATABASE IF EXISTS enterprise_test; CREATE DATABASE enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 6. 导入数据库结构到测试环境
echo "6. 导入数据库结构到测试环境..."
mysql -h localhost -P 3307 -u test_user -ptest_password enterprise_test < dev_structure.sql

# 7. 导入数据到测试环境
echo "7. 导入数据到测试环境..."
mysql -h localhost -P 3307 -u test_user -ptest_password enterprise_test < dev_data.sql

# 8. 导入mall_addresses表数据
echo "8. 导入mall_addresses表数据..."
mysql -h localhost -P 3307 -u test_user -ptest_password enterprise_test < mall_addresses_data.sql

# 9. 清理临时文件
echo "9. 清理临时文件..."
rm -f dev_structure.sql dev_data.sql mall_addresses_data.sql

echo "数据库迁移完成！"
echo "开发环境数据库已成功迁移到测试环境"
echo "测试环境地址：localhost:3307, test_user/test_password, enterprise_test"
