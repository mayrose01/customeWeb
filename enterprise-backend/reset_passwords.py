#!/usr/bin/env python3
"""
重置客户端用户密码脚本
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app import models, crud
from sqlalchemy.orm import Session

def reset_client_passwords():
    """重置客户端用户密码为123456"""
    db = SessionLocal()
    try:
        # 获取所有customer角色的用户
        users = db.query(models.User).filter(models.User.role == "customer").all()
        print(f"找到 {len(users)} 个客户端用户，正在重置密码...")
        
        for user in users:
            print(f"重置用户 {user.username} 的密码...")
            
            # 生成新的密码哈希
            new_password_hash = crud.get_password_hash("123456")
            
            # 更新用户密码
            user.password_hash = new_password_hash
            db.commit()
            
            print(f"  ✓ 用户 {user.username} 密码已重置为 '123456'")
        
        print(f"\n所有 {len(users)} 个客户端用户的密码已重置为 '123456'")
        
        # 验证重置结果
        print(f"\n验证重置结果:")
        for user in users:
            is_valid = crud.verify_password("123456", user.password_hash)
            print(f"  用户 {user.username}: {'✓ 密码正确' if is_valid else '✗ 密码错误'}")
        
    except Exception as e:
        print(f"重置密码过程中出错: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    reset_client_passwords() 