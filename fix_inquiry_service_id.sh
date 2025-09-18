#!/bin/bash

# 修复询盘表，移除service_id字段
# 这个脚本会安全地移除inquiries表中的service_id字段

echo "开始修复询盘表，移除service_id字段..."

# 检查数据库连接
mysql -u root -proot -e "SELECT 1;" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "错误: 无法连接到数据库"
    exit 1
fi

echo "1. 检查当前inquiries表结构..."
mysql -u root -proot -e "USE enterprise_prod; DESCRIBE inquiries;" 2>/dev/null

echo "2. 检查是否有service_id字段..."
SERVICE_ID_EXISTS=$(mysql -u root -proot -e "USE enterprise_prod; SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='enterprise_prod' AND TABLE_NAME='inquiries' AND COLUMN_NAME='service_id';" 2>/dev/null | grep -c "service_id")

if [ "$SERVICE_ID_EXISTS" -gt 0 ]; then
    echo "发现service_id字段，准备移除..."
    
    echo "3. 备份当前inquiries表..."
    mysqldump -u root -proot enterprise_prod inquiries > backup_inquiries_$(date +%Y%m%d_%H%M%S).sql
    
    echo "4. 移除service_id字段..."
    mysql -u root -proot -e "USE enterprise_prod; ALTER TABLE inquiries DROP COLUMN service_id;" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ service_id字段移除成功"
    else
        echo "❌ service_id字段移除失败"
        exit 1
    fi
else
    echo "✅ inquiries表中没有service_id字段，无需移除"
fi

echo "5. 检查修复后的表结构..."
mysql -u root -proot -e "USE enterprise_prod; DESCRIBE inquiries;" 2>/dev/null

echo "6. 检查inquiries表中的数据..."
mysql -u root -proot -e "USE enterprise_prod; SELECT COUNT(*) as inquiry_count FROM inquiries;" 2>/dev/null

echo "✅ 询盘表修复完成！"
echo "现在询盘功能应该可以正常工作了。"
