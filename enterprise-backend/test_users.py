#!/usr/bin/env python3
"""
测试用户数据库脚本
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app import models, crud
from sqlalchemy.orm import Session

def test_users():
    """测试用户数据库"""
    db = SessionLocal()
    try:
        # 获取所有用户
        users = db.query(models.User).all()
        print(f"数据库中共有 {len(users)} 个用户:")
        
        for user in users:
            print(f"ID: {user.id}")
            print(f"  用户名: {user.username}")
            print(f"  邮箱: {user.email}")
            print(f"  手机: {user.phone}")
            print(f"  角色: {user.role}")
            print(f"  状态: {user.status}")
            print(f"  创建时间: {user.created_at}")
            print("  " + "-" * 30)
        
        # 测试密码验证
        if users:
            test_user = users[0]
            print(f"\n测试密码验证 - 用户: {test_user.username}")
            print(f"密码哈希: {test_user.password_hash}")
            
            # 测试一些常见密码
            test_passwords = ["123456", "password", "admin", "test"]
            for pwd in test_passwords:
                is_valid = crud.verify_password(pwd, test_user.password_hash)
                print(f"  密码 '{pwd}': {'正确' if is_valid else '错误'}")
        
        # 测试用户查找
        print(f"\n测试用户查找:")
        if users:
            test_username = users[0].username
            user = crud.get_user_by_username(db, test_username)
            print(f"  通过用户名 '{test_username}' 查找: {'成功' if user else '失败'}")
            
            if users[0].email:
                test_email = users[0].email
                user = crud.get_user_by_email(db, test_email)
                print(f"  通过邮箱 '{test_email}' 查找: {'成功' if user else '失败'}")
        
    except Exception as e:
        print(f"测试过程中出错: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    test_users() 