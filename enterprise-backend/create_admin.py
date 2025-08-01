#!/usr/bin/env python3
"""
创建管理员账户脚本
用于在生产环境中创建管理员用户
"""

import os
import sys
from sqlalchemy import create_engine, text
from passlib.context import CryptContext
from datetime import datetime, timezone, timedelta

# 密码加密上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """加密密码"""
    return pwd_context.hash(password)

def create_admin_user():
    """创建管理员用户"""
    
    # 生产环境数据库配置
    DATABASE_URL = "mysql+pymysql://enterprise_user:enterprise_password_2024@localhost:3306/enterprise_db"
    
    try:
        # 创建数据库引擎
        engine = create_engine(DATABASE_URL, echo=True)
        
        # 测试连接
        with engine.connect() as conn:
            result = conn.execute(text("SELECT 1"))
            print("✅ 数据库连接成功")
        
        # 创建管理员用户
        admin_username = "admin"
        admin_password = "admin123"
        admin_email = "admin@catusfoto.top"
        
        # 加密密码
        hashed_password = hash_password(admin_password)
        
        # 检查用户是否已存在
        with engine.connect() as conn:
            # 检查用户是否存在
            result = conn.execute(text("SELECT id, username, role FROM users WHERE username = :username"), 
                                {"username": admin_username})
            existing_user = result.fetchone()
            
            if existing_user:
                print(f"⚠️  用户 '{admin_username}' 已存在")
                print(f"   用户ID: {existing_user[0]}")
                print(f"   用户名: {existing_user[1]}")
                print(f"   角色: {existing_user[2]}")
                
                # 更新密码
                conn.execute(text("""
                    UPDATE users 
                    SET password_hash = :password_hash, 
                        updated_at = :updated_at 
                    WHERE username = :username
                """), {
                    "password_hash": hashed_password,
                    "updated_at": datetime.now(timezone(timedelta(hours=8))),
                    "username": admin_username
                })
                conn.commit()
                print("✅ 已更新管理员密码")
            else:
                # 创建新用户
                conn.execute(text("""
                    INSERT INTO users (username, password_hash, email, role, status, created_at, updated_at)
                    VALUES (:username, :password_hash, :email, 'admin', 1, :created_at, :updated_at)
                """), {
                    "username": admin_username,
                    "password_hash": hashed_password,
                    "email": admin_email,
                    "created_at": datetime.now(timezone(timedelta(hours=8))),
                    "updated_at": datetime.now(timezone(timedelta(hours=8)))
                })
                conn.commit()
                print("✅ 已创建管理员用户")
            
            # 验证结果
            result = conn.execute(text("""
                SELECT id, username, email, role, status, created_at 
                FROM users 
                WHERE username = :username
            """), {"username": admin_username})
            
            user = result.fetchone()
            if user:
                print("\n📋 管理员账户信息:")
                print(f"   ID: {user[0]}")
                print(f"   用户名: {user[1]}")
                print(f"   邮箱: {user[2]}")
                print(f"   角色: {user[3]}")
                print(f"   状态: {'启用' if user[4] == 1 else '禁用'}")
                print(f"   创建时间: {user[5]}")
                print(f"\n🔑 登录凭据:")
                print(f"   用户名: {admin_username}")
                print(f"   密码: {admin_password}")
                print(f"\n🌐 登录地址: https://catusfoto.top/admin/login")
        
    except Exception as e:
        print(f"❌ 错误: {e}")
        return False
    
    return True

if __name__ == "__main__":
    print("🚀 开始创建管理员用户...")
    print("=" * 50)
    
    success = create_admin_user()
    
    print("=" * 50)
    if success:
        print("✅ 管理员用户创建/更新完成")
    else:
        print("❌ 管理员用户创建失败")
        sys.exit(1) 