#!/usr/bin/env python3
"""
为company_info表添加phone字段 - MySQL版本
"""

import pymysql
import os

def update_company_phone():
    """为company_info表添加phone字段"""
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
        
        # 检查当前表结构
        cursor.execute("DESCRIBE company_info")
        columns = cursor.fetchall()
        column_names = [col[0] for col in columns]
        
        print("当前company_info表结构:")
        for col in columns:
            print(f"  {col[0]} {col[1]}")
        
        # 添加phone字段
        if "phone" not in column_names:
            print("添加字段: phone VARCHAR(50)")
            cursor.execute("ALTER TABLE company_info ADD COLUMN phone VARCHAR(50)")
            print("phone字段添加成功")
        else:
            print("phone字段已存在")
        
        conn.commit()
        print("company_info表结构更新完成")
        
        # 显示更新后的表结构
        cursor.execute("DESCRIBE company_info")
        columns = cursor.fetchall()
        print("\n更新后的company_info表结构:")
        for col in columns:
            print(f"  {col[0]} {col[1]}")
            
    except Exception as e:
        print(f"更新失败: {e}")
        if 'conn' in locals():
            conn.rollback()
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    print("开始更新company_info表结构...")
    update_company_phone()
    print("更新完成！") 