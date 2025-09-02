#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
登录调试脚本
详细检查登录过程中的每个步骤
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app import crud, models
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def debug_login_process():
    """调试登录过程"""
    print("开始调试登录过程...")
    
    db = SessionLocal()
    try:
        # 1. 检查用户是否存在
        username = "testuser2"
        print(f"\n1. 检查用户 '{username}' 是否存在...")
        user = crud.get_user_by_username(db, username)
        if user:
            print(f"用户存在: ID={user.id}, 用户名={user.username}, 角色={user.role}, 状态={user.status}")
            print(f"密码Hash: {'有' if user.password_hash else '无'}")
        else:
            print("用户不存在")
            return
        
        # 2. 检查密码验证
        password = "testpass123"
        print(f"\n2. 检查密码验证...")
        if user.password_hash:
            is_valid = crud.verify_password(password, user.password_hash)
            print(f"密码验证结果: {is_valid}")
        else:
            print("用户没有密码Hash")
            return
        
        # 3. 检查用户状态
        print(f"\n3. 检查用户状态...")
        print(f"用户状态值: {user.status} (类型: {type(user.status)})")
        print(f"状态比较 (user.status != 1): {user.status != 1}")
        
        # 4. 检查数据库中的实际值
        print(f"\n4. 检查数据库中的实际值...")
        from sqlalchemy import text
        result = db.execute(text("SELECT id, username, role, status FROM users WHERE username = :username"), 
                          {"username": username})
        db_user = result.fetchone()
        if db_user:
            print(f"数据库中的用户: ID={db_user[0]}, 用户名={db_user[1]}, 角色={db_user[2]}, 状态={db_user[3]}")
            print(f"状态类型: {type(db_user[3])}")
        else:
            print("数据库中未找到用户")
        
        # 5. 测试完整的登录流程
        print(f"\n5. 测试完整的登录流程...")
        if user and user.password_hash:
            # 验证密码
            if crud.verify_password(password, user.password_hash):
                print("✓ 密码验证成功")
                # 检查状态
                if user.status == 1:
                    print("✓ 用户状态正常")
                    print("✓ 登录应该成功")
                else:
                    print(f"✗ 用户状态异常: {user.status}")
            else:
                print("✗ 密码验证失败")
        else:
            print("✗ 用户或密码Hash不存在")
        
    except Exception as e:
        print(f"调试过程中出错: {e}")
    finally:
        db.close()

def test_password_hash():
    """测试密码Hash功能"""
    print("\n测试密码Hash功能...")
    
    password = "testpass123"
    hashed = pwd_context.hash(password)
    print(f"原始密码: {password}")
    print(f"Hash结果: {hashed}")
    
    # 验证密码
    is_valid = pwd_context.verify(password, hashed)
    print(f"密码验证: {is_valid}")
    
    # 验证错误密码
    wrong_password = "wrongpass"
    is_valid_wrong = pwd_context.verify(wrong_password, hashed)
    print(f"错误密码验证: {is_valid_wrong}")

if __name__ == "__main__":
    debug_login_process()
    test_password_hash() 