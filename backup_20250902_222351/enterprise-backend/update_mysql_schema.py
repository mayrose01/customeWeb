#!/usr/bin/env python3
"""
更新MySQL数据库表结构的脚本
"""

import pymysql
from sqlalchemy import create_engine, text

# 数据库连接配置
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'root',
    'database': 'enterprise',
    'charset': 'utf8mb4'
}

def update_category_table():
    """更新category表结构"""
    try:
        # 连接MySQL
        connection = pymysql.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        print("正在更新category表结构...")
        
        # 检查image字段是否存在
        cursor.execute("SHOW COLUMNS FROM category LIKE 'image'")
        if not cursor.fetchone():
            print("添加image字段...")
            cursor.execute("ALTER TABLE category ADD COLUMN image VARCHAR(255)")
        
        # 检查sort_order字段是否存在
        cursor.execute("SHOW COLUMNS FROM category LIKE 'sort_order'")
        if not cursor.fetchone():
            print("添加sort_order字段...")
            cursor.execute("ALTER TABLE category ADD COLUMN sort_order INT DEFAULT 0")
        
        connection.commit()
        print("category表结构更新完成！")
        
        # 显示更新后的表结构
        cursor.execute("DESCRIBE category")
        columns = cursor.fetchall()
        print("\n当前category表结构:")
        for column in columns:
            print(f"  {column[0]} - {column[1]}")
            
    except Exception as e:
        print(f"更新表结构时出错: {e}")
    finally:
        if 'connection' in locals():
            connection.close()

if __name__ == "__main__":
    update_category_table() 