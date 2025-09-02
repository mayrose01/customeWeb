#!/usr/bin/env python3
"""
检查用户密码哈希和验证
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app import models, crud
from sqlalchemy.orm import Session

def check_passwords():
    """检查用户密码"""
    db = SessionLocal()
    try:
        # 获取所有customer角色的用户
        users = db.query(models.User).filter(models.User.role == "customer").all()
        print(f"数据库中共有 {len(users)} 个客户端用户:")
        
        for user in users:
            print(f"\n用户: {user.username}")
            print(f"  邮箱: {user.email}")
            print(f"  手机: {user.phone}")
            print(f"  密码哈希: {user.password_hash}")
            
            # 测试密码验证
            test_passwords = ["123456", "password", "admin", "test", user.username]
            for pwd in test_passwords:
                try:
                    is_valid = crud.verify_password(pwd, user.password_hash)
                    print(f"  密码 '{pwd}': {'✓ 正确' if is_valid else '✗ 错误'}")
                except Exception as e:
                    print(f"  密码 '{pwd}' 验证出错: {e}")
        
        # 测试认证函数
        print(f"\n测试认证函数:")
        for user in users:
            print(f"\n用户: {user.username}")
            
            # 测试用户名登录
            auth_user = crud.authenticate_client_user(db, user.username, "123456")
            print(f"  用户名+123456: {'✓ 成功' if auth_user else '✗ 失败'}")
            
            # 测试邮箱登录（如果有邮箱）
            if user.email:
                auth_user = crud.authenticate_client_user(db, user.email, "123456")
                print(f"  邮箱+123456: {'✓ 成功' if auth_user else '✗ 失败'}")
            
            # 测试手机号登录（如果有手机号）
            if user.phone:
                auth_user = crud.authenticate_client_user(db, user.phone, "123456")
                print(f"  手机+123456: {'✓ 成功' if auth_user else '✗ 失败'}")
        
    except Exception as e:
        print(f"检查过程中出错: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    check_passwords() 