#!/usr/bin/env python3
"""
密码哈希一致性测试脚本
验证不同环境下的密码哈希生成和验证是否一致
"""

from passlib.context import CryptContext

def test_password_hash():
    # 创建密码上下文
    pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
    
    # 测试密码
    test_password = 'admin123'
    
    # 生成新的哈希
    new_hash = pwd_context.hash(test_password)
    print(f"新生成的哈希: {new_hash}")
    
    # 测试验证
    is_valid = pwd_context.verify(test_password, new_hash)
    print(f"验证结果: {is_valid}")
    
    # 测试生产环境中的哈希
    production_hash = '$2b$12$iLAPXE1/HEs6q.4DYjcOReyG1jDCJgV5SP79WDkUyHjhk6DuOjZUa'
    is_production_valid = pwd_context.verify(test_password, production_hash)
    print(f"生产环境哈希验证: {is_production_valid}")
    
    # 测试开发环境中的哈希
    dev_hash = '$2b$12$iwUIRJcULo4iFIMLivO3X.It7Cbmk.JzeWPdsFkYTNuVMLXJh8yk2'
    is_dev_valid = pwd_context.verify(test_password, dev_hash)
    print(f"开发环境哈希验证: {is_dev_valid}")
    
    return is_production_valid and is_dev_valid

if __name__ == "__main__":
    print("🔍 开始密码哈希一致性测试...")
    result = test_password_hash()
    if result:
        print("✅ 所有哈希验证通过")
    else:
        print("❌ 哈希验证失败") 