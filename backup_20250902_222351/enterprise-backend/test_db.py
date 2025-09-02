#!/usr/bin/env python3

from app.database import engine
from sqlalchemy import text

def test_database():
    try:
        with engine.connect() as conn:
            # 检查表是否存在
            result = conn.execute(text('SHOW TABLES'))
            tables = [row[0] for row in result]
            print("数据库表:", tables)
            
            # 检查inquiry表结构
            if 'inquiry' in tables:
                result = conn.execute(text('DESCRIBE inquiry'))
                columns = [row[0] for row in result]
                print("inquiry表字段:", columns)
            
            # 检查contact_messages表结构
            if 'contact_messages' in tables:
                result = conn.execute(text('DESCRIBE contact_messages'))
                columns = [row[0] for row in result]
                print("contact_messages表字段:", columns)
                
    except Exception as e:
        print(f"数据库测试失败: {e}")

if __name__ == "__main__":
    test_database() 