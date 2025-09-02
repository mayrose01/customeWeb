#!/usr/bin/env python3
"""
数据库迁移脚本：为公司信息表添加新字段
- address: 公司地址
- working_hours: 工作时间  
- company_image: 公司图片路径
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal, engine
from sqlalchemy import text

def add_company_info_fields():
    """为公司信息表添加新字段"""
    db = SessionLocal()
    try:
        # 检查字段是否已存在
        result = db.execute(text("""
            SELECT COLUMN_NAME 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = 'company_info' 
            AND TABLE_SCHEMA = DATABASE()
        """))
        existing_columns = [row[0] for row in result]
        
        # 添加新字段
        if 'address' not in existing_columns:
            db.execute(text("ALTER TABLE company_info ADD COLUMN address VARCHAR(500)"))
            print("✅ 已添加 address 字段")
        else:
            print("ℹ️  address 字段已存在")
            
        if 'working_hours' not in existing_columns:
            db.execute(text("ALTER TABLE company_info ADD COLUMN working_hours VARCHAR(200)"))
            print("✅ 已添加 working_hours 字段")
        else:
            print("ℹ️  working_hours 字段已存在")
            
        if 'company_image' not in existing_columns:
            db.execute(text("ALTER TABLE company_info ADD COLUMN company_image VARCHAR(255)"))
            print("✅ 已添加 company_image 字段")
        else:
            print("ℹ️  company_image 字段已存在")
        
        db.commit()
        print("🎉 数据库迁移完成！")
        
    except Exception as e:
        db.rollback()
        print(f"❌ 迁移失败: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    print("开始执行数据库迁移...")
    add_company_info_fields() 