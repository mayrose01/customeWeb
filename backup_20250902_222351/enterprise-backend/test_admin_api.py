#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
管理员API测试脚本
测试管理员登录和用户管理功能
"""

import requests
import json

BASE_URL = "http://localhost:8000/api"

def test_admin_api():
    """测试管理员API功能"""
    print("开始测试管理员API...")
    
    # 1. 管理员登录
    print("\n1. 管理员登录...")
    login_data = {
        "username": "admin",
        "password": "admin"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/user/login", data=login_data)
        print(f"管理员登录响应: {response.status_code}")
        if response.status_code == 200:
            token_data = response.json()
            admin_token = token_data.get("access_token")
            print("管理员登录成功，获取到token")
            
            headers = {"Authorization": f"Bearer {admin_token}"}
            
            # 2. 获取用户列表
            print("\n2. 获取用户列表...")
            response = requests.get(f"{BASE_URL}/user/", headers=headers)
            print(f"获取用户列表响应: {response.status_code}")
            if response.status_code == 200:
                users = response.json()
                print(f"用户列表: {len(users)} 个用户")
                for user in users:
                    print(f"  - {user['username']} ({user['role']}) - 状态: {user['status']}")
            else:
                print(f"获取用户列表失败: {response.text}")
            
            # 3. 按角色筛选用户
            print("\n3. 按角色筛选用户...")
            response = requests.get(f"{BASE_URL}/user/?role=customer", headers=headers)
            print(f"筛选客户用户响应: {response.status_code}")
            if response.status_code == 200:
                users = response.json()
                print(f"客户用户: {len(users)} 个")
                for user in users:
                    print(f"  - {user['username']} ({user['role']})")
            else:
                print(f"筛选用户失败: {response.text}")
            
            # 4. 获取单个用户信息
            print("\n4. 获取单个用户信息...")
            response = requests.get(f"{BASE_URL}/user/7", headers=headers)  # testuser2的ID
            print(f"获取用户信息响应: {response.status_code}")
            if response.status_code == 200:
                user = response.json()
                print(f"用户信息: {user['username']} ({user['role']}) - 邮箱: {user['email']}")
            else:
                print(f"获取用户信息失败: {response.text}")
            
            # 5. 更新用户信息
            print("\n5. 更新用户信息...")
            update_data = {
                "email": "updated@example.com",
                "phone": "13900139000"
            }
            response = requests.put(f"{BASE_URL}/user/7", json=update_data, headers=headers)
            print(f"更新用户信息响应: {response.status_code}")
            if response.status_code == 200:
                user = response.json()
                print(f"用户更新成功: {user['username']} - 邮箱: {user['email']}")
            else:
                print(f"更新用户信息失败: {response.text}")
            
            # 6. 管理员修改用户密码
            print("\n6. 管理员修改用户密码...")
            password_data = {
                "username": "testuser2",
                "new_password": "newpass123"
            }
            response = requests.post(f"{BASE_URL}/user/admin/change-password", json=password_data, headers=headers)
            print(f"修改密码响应: {response.status_code}")
            if response.status_code == 200:
                print("密码修改成功")
            else:
                print(f"修改密码失败: {response.text}")
                
        else:
            print(f"管理员登录失败: {response.text}")
    except Exception as e:
        print(f"管理员API测试失败: {e}")
    
    print("\n管理员API测试完成")

if __name__ == "__main__":
    test_admin_api() 