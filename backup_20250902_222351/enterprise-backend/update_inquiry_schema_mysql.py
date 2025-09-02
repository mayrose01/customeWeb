#!/usr/bin/env python3
import pymysql
import sys

def update_database_schema():
    # 数据库连接配置
    db_config = {
        'host': 'localhost',
        'user': 'root',
        'password': 'root',  # 根据实际情况修改
        'database': 'enterprise',
        'charset': 'utf8mb4'
    }
    
    try:
        # 连接数据库
        connection = pymysql.connect(**db_config)
        cursor = connection.cursor()
        
        print("开始更新数据库表结构...")
        
        # 检查inquiry表是否存在user_id字段
        cursor.execute("SHOW COLUMNS FROM inquiry LIKE 'user_id'")
        result = cursor.fetchone()
        
        if not result:
            print("为inquiry表添加user_id字段...")
            cursor.execute("""
                ALTER TABLE inquiry 
                ADD COLUMN user_id INT NULL,
                ADD CONSTRAINT fk_inquiry_user 
                FOREIGN KEY (user_id) REFERENCES users(id) 
                ON DELETE SET NULL
            """)
            print("✓ inquiry表user_id字段添加成功")
        else:
            print("✓ inquiry表user_id字段已存在")
        
        # 检查contact_messages表是否存在user_id字段
        cursor.execute("SHOW COLUMNS FROM contact_messages LIKE 'user_id'")
        result = cursor.fetchone()
        
        if not result:
            print("为contact_messages表添加user_id字段...")
            cursor.execute("""
                ALTER TABLE contact_messages 
                ADD COLUMN user_id INT NULL,
                ADD CONSTRAINT fk_contact_messages_user 
                FOREIGN KEY (user_id) REFERENCES users(id) 
                ON DELETE SET NULL
            """)
            print("✓ contact_messages表user_id字段添加成功")
        else:
            print("✓ contact_messages表user_id字段已存在")
        
        # 提交更改
        connection.commit()
        print("✓ 数据库表结构更新完成")
        
    except Exception as e:
        print(f"❌ 更新失败: {e}")
        connection.rollback()
        sys.exit(1)
    finally:
        cursor.close()
        connection.close()

if __name__ == "__main__":
    update_database_schema() 