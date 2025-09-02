#!/usr/bin/env python3
"""
更新数据库表结构 - MySQL版本
包括：company_info、carousel_images、contact_fields、contact_messages、services表
"""

import pymysql
import os
from datetime import datetime

def update_database_schema():
    """更新数据库表结构"""
    # MySQL连接配置
    db_config = {
        'host': 'localhost',
        'port': 3306,
        'user': 'root',
        'password': 'root',
        'database': 'enterprise',
        'charset': 'utf8mb4'
    }
    
    try:
        conn = pymysql.connect(**db_config)
        cursor = conn.cursor()
        
        print("开始更新数据库表结构...")
        
        # 1. 更新company_info表
        print("\n1. 更新company_info表...")
        cursor.execute("DESCRIBE company_info")
        columns = cursor.fetchall()
        column_names = [col[0] for col in columns]
        
        # 删除旧字段
        old_fields = ['company_name_cn', 'company_name_en', 'logo', 'background', 'business', 'factory', 'address']
        for field in old_fields:
            if field in column_names:
                print(f"删除旧字段: {field}")
                cursor.execute(f"ALTER TABLE company_info DROP COLUMN {field}")
        
        # 添加新字段
        new_fields = [
            ("name", "VARCHAR(255)"),
            ("logo_url", "VARCHAR(255)"),
            ("main_business", "TEXT"),
            ("main_pic_url", "VARCHAR(255)"),
            ("about_text", "TEXT")
        ]
        
        for field_name, field_type in new_fields:
            if field_name not in column_names:
                print(f"添加字段: {field_name} {field_type}")
                cursor.execute(f"ALTER TABLE company_info ADD COLUMN {field_name} {field_type}")
        
        # 2. 创建carousel_images表
        print("\n2. 创建carousel_images表...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS carousel_images (
                id INT AUTO_INCREMENT PRIMARY KEY,
                image_url VARCHAR(255) NOT NULL,
                caption VARCHAR(255),
                description TEXT,
                sort_order INT DEFAULT 0,
                is_active TINYINT(1) DEFAULT 1
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        print("carousel_images表创建成功")
        
        # 3. 创建contact_fields表
        print("\n3. 创建contact_fields表...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS contact_fields (
                id INT AUTO_INCREMENT PRIMARY KEY,
                field_name VARCHAR(50) NOT NULL,
                field_label VARCHAR(50) NOT NULL,
                field_type VARCHAR(20) NOT NULL,
                is_required TINYINT(1) DEFAULT 0,
                sort_order INT DEFAULT 0
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        print("contact_fields表创建成功")
        
        # 4. 创建contact_messages表
        print("\n4. 创建contact_messages表...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS contact_messages (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(100) NOT NULL,
                phone VARCHAR(50),
                message TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        print("contact_messages表创建成功")
        
        # 5. 创建services表
        print("\n5. 创建services表...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS services (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                description TEXT,
                image_url VARCHAR(255),
                sort_order INT DEFAULT 0,
                is_active TINYINT(1) DEFAULT 1
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        print("services表创建成功")
        
        # 6. 插入默认的contact_fields数据
        print("\n6. 插入默认的contact_fields数据...")
        default_fields = [
            ('name', '姓名', 'text', 1, 1),
            ('email', '邮箱', 'email', 1, 2),
            ('phone', '电话', 'tel', 0, 3),
            ('message', '留言内容', 'textarea', 1, 4)
        ]
        
        for field_name, field_label, field_type, is_required, sort_order in default_fields:
            cursor.execute("""
                INSERT INTO contact_fields (field_name, field_label, field_type, is_required, sort_order)
                VALUES (%s, %s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE
                field_label = VALUES(field_label),
                field_type = VALUES(field_type),
                is_required = VALUES(is_required),
                sort_order = VALUES(sort_order)
            """, (field_name, field_label, field_type, is_required, sort_order))
        
        print("默认contact_fields数据插入成功")
        
        conn.commit()
        print("\n数据库表结构更新完成！")
        
        # 显示所有表
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        print("\n当前数据库中的所有表:")
        for table in tables:
            print(f"  - {table[0]}")
            
    except Exception as e:
        print(f"更新失败: {e}")
        if 'conn' in locals():
            conn.rollback()
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    update_database_schema() 