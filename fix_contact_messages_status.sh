#!/bin/bash

# 修复开发环境contact_messages表，添加status字段
# 使其与生产环境保持一致

echo "开始修复开发环境contact_messages表，添加status字段..."

# 检查数据库连接
mysql -u root -proot -e "SELECT 1;" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "错误: 无法连接到数据库"
    exit 1
fi

echo "1. 检查当前contact_messages表结构..."
mysql -u root -proot -e "USE enterprise_dev; DESCRIBE contact_messages;" 2>/dev/null

echo "2. 检查是否有status字段..."
STATUS_EXISTS=$(mysql -u root -proot -e "USE enterprise_dev; SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='enterprise_dev' AND TABLE_NAME='contact_messages' AND COLUMN_NAME='status';" 2>/dev/null | grep -c "status")

if [ "$STATUS_EXISTS" -eq 0 ]; then
    echo "发现缺少status字段，准备添加..."
    
    echo "3. 备份当前contact_messages表..."
    mysqldump -u root -proot enterprise_dev contact_messages > backup_contact_messages_$(date +%Y%m%d_%H%M%S).sql
    
    echo "4. 添加status字段..."
    mysql -u root -proot -e "USE enterprise_dev; ALTER TABLE contact_messages ADD COLUMN status ENUM('new', 'read', 'replied') DEFAULT 'new';" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ status字段添加成功"
    else
        echo "❌ status字段添加失败"
        exit 1
    fi
else
    echo "✅ contact_messages表中已有status字段，无需添加"
fi

echo "5. 检查修复后的表结构..."
mysql -u root -proot -e "USE enterprise_dev; DESCRIBE contact_messages;" 2>/dev/null

echo "6. 检查contact_messages表中的数据..."
mysql -u root -proot -e "USE enterprise_dev; SELECT COUNT(*) as message_count FROM contact_messages;" 2>/dev/null

echo "✅ contact_messages表修复完成！"
echo "现在开发环境和生产环境的表结构保持一致了。"
