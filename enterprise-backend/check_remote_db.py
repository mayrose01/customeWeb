#!/usr/bin/env python3
"""
检查远程服务器数据库连接和状态
"""

import os
import sys
from sqlalchemy import create_engine, text

def check_remote_database():
    """检查远程数据库连接和状态"""
    
    # 远程服务器数据库配置
    SERVER_IP = "47.243.41.30"
    DATABASE_URL = f"mysql+pymysql://enterprise_user:enterprise_password_2024@{SERVER_IP}:3306/enterprise_db"
    
    print("🔍 检查远程服务器数据库...")
    print("=" * 50)
    print(f"服务器IP: {SERVER_IP}")
    print(f"数据库URL: {DATABASE_URL}")
    print("=" * 50)
    
    try:
        # 创建数据库引擎
        engine = create_engine(DATABASE_URL, echo=False)
        
        # 测试连接
        with engine.connect() as conn:
            result = conn.execute(text("SELECT 1"))
            print("✅ 远程数据库连接成功")
            
            # 检查数据库
            result = conn.execute(text("SELECT DATABASE()"))
            db_name = result.fetchone()[0]
            print(f"📊 当前数据库: {db_name}")
            
            # 检查表
            result = conn.execute(text("SHOW TABLES"))
            tables = [row[0] for row in result.fetchall()]
            print(f"📋 数据库表: {', '.join(tables)}")
            
            # 检查users表
            if 'users' in tables:
                print("\n👥 检查用户表...")
                
                # 检查表结构
                result = conn.execute(text("DESCRIBE users"))
                columns = result.fetchall()
                print("📝 用户表结构:")
                for col in columns:
                    print(f"   {col[0]} - {col[1]} - {col[2]} - {col[3]} - {col[4]} - {col[5]}")
                
                # 检查用户数量
                result = conn.execute(text("SELECT COUNT(*) FROM users"))
                user_count = result.fetchone()[0]
                print(f"\n👤 用户总数: {user_count}")
                
                # 检查管理员用户
                result = conn.execute(text("SELECT id, username, email, role, status FROM users WHERE role = 'admin'"))
                admins = result.fetchall()
                print(f"\n👑 管理员用户:")
                if admins:
                    for admin in admins:
                        print(f"   ID: {admin[0]}, 用户名: {admin[1]}, 邮箱: {admin[2]}, 角色: {admin[3]}, 状态: {admin[4]}")
                else:
                    print("   ❌ 没有找到管理员用户")
                
                # 检查所有用户
                result = conn.execute(text("SELECT id, username, email, role, status FROM users LIMIT 10"))
                users = result.fetchall()
                print(f"\n👥 前10个用户:")
                if users:
                    for user in users:
                        print(f"   ID: {user[0]}, 用户名: {user[1]}, 邮箱: {user[2]}, 角色: {user[3]}, 状态: {user[4]}")
                else:
                    print("   ❌ 没有找到任何用户")
            else:
                print("❌ users表不存在")
        
    except Exception as e:
        print(f"❌ 远程数据库连接失败: {e}")
        print("\n🔧 可能的解决方案:")
        print("1. 检查服务器MySQL服务是否运行")
        print("2. 检查数据库用户权限")
        print("3. 检查数据库是否存在")
        print("4. 检查网络连接和防火墙")
        print("5. 检查MySQL是否允许远程连接")
        return False
    
    return True

if __name__ == "__main__":
    success = check_remote_database()
    
    print("=" * 50)
    if success:
        print("✅ 远程数据库检查完成")
    else:
        print("❌ 远程数据库检查失败")
        sys.exit(1) 