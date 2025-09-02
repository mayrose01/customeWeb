#!/usr/bin/env python3
"""
MySQL数据库迁移脚本：为产品表添加时间字段
"""

import pymysql
from datetime import datetime

def update_mysql_product_schema():
    """更新MySQL产品表结构，添加时间字段"""
    
    # MySQL连接配置
    connection = pymysql.connect(
        host='localhost',
        user='root',
        password='root',
        database='enterprise',
        charset='utf8mb4'
    )
    
    cursor = connection.cursor()
    
    try:
        # 检查是否已经存在时间字段
        cursor.execute("DESCRIBE product")
        columns = [column[0] for column in cursor.fetchall()]
        
        if 'created_at' not in columns:
            print("添加 created_at 字段...")
            cursor.execute("ALTER TABLE product ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
        
        if 'updated_at' not in columns:
            print("添加 updated_at 字段...")
            cursor.execute("ALTER TABLE product ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")
        
        # 为现有记录设置时间字段
        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        cursor.execute("UPDATE product SET created_at = %s, updated_at = %s WHERE created_at IS NULL", (current_time, current_time))
        
        connection.commit()
        print("MySQL数据库迁移完成！")
        
        # 显示更新后的表结构
        cursor.execute("DESCRIBE product")
        print("\n更新后的产品表结构：")
        for column in cursor.fetchall():
            print(f"  {column[0]} ({column[1]})")
            
    except Exception as e:
        print(f"迁移失败: {e}")
        connection.rollback()
    finally:
        cursor.close()
        connection.close()

if __name__ == "__main__":
    update_mysql_product_schema() 