#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
用户API测试脚本
测试用户注册、登录、token刷新等功能
"""

import requests
import json

BASE_URL = "http://localhost:8000/api"

def test_user_api():
    """测试用户API功能"""
    print("开始测试用户API...")
    
    # 1. 测试用户注册
    print("\n1. 测试用户注册...")
    register_data = {
        "username": "testuser2",
        "password": "testpass123",
        "email": "test2@example.com",
        "phone": "13800138001",
        "role": "customer"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/user/register", json=register_data)
        print(f"注册响应: {response.status_code}")
        if response.status_code == 200:
            print("注册成功")
        else:
            print(f"注册失败: {response.text}")
    except Exception as e:
        print(f"注册请求失败: {e}")
    
    # 2. 测试用户登录
    print("\n2. 测试用户登录...")
    login_data = {
        "username": "testuser2",
        "password": "testpass123"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/user/login", data=login_data)
        print(f"登录响应: {response.status_code}")
        if response.status_code == 200:
            token_data = response.json()
            token = token_data.get("access_token")
            print("登录成功，获取到token")
            
            # 3. 测试获取用户列表（需要管理员权限）
            print("\n3. 测试获取用户列表...")
            headers = {"Authorization": f"Bearer {token}"}
            response = requests.get(f"{BASE_URL}/user/", headers=headers)
            print(f"获取用户列表响应: {response.status_code}")
            if response.status_code == 200:
                users = response.json()
                print(f"用户列表: {len(users)} 个用户")
                for user in users:
                    print(f"  - {user['username']} ({user['role']})")
            else:
                print(f"获取用户列表失败: {response.text}")
            
            # 4. 测试token刷新
            print("\n4. 测试token刷新...")
            response = requests.post(f"{BASE_URL}/user/refresh-token", headers=headers)
            print(f"Token刷新响应: {response.status_code}")
            if response.status_code == 200:
                new_token_data = response.json()
                new_token = new_token_data.get("access_token")
                print("Token刷新成功")
            else:
                print(f"Token刷新失败: {response.text}")
                
        else:
            print(f"登录失败: {response.text}")
    except Exception as e:
        print(f"登录请求失败: {e}")
    
    # 5. 测试微信登录（模拟）
    print("\n5. 测试微信登录...")
    wx_login_data = {"wx_code": "test_wx_code_456"}
    
    try:
        response = requests.post(f"{BASE_URL}/user/wx-login", json=wx_login_data)
        print(f"微信登录响应: {response.status_code}")
        if response.status_code == 200:
            wx_token_data = response.json()
            wx_token = wx_token_data.get("access_token")
            print("微信登录成功")
        else:
            print(f"微信登录失败: {response.text}")
    except Exception as e:
        print(f"微信登录请求失败: {e}")
    
    # 6. 测试App登录（模拟）
    print("\n6. 测试App登录...")
    app_login_data = {"app_openid": "test_app_openid_456"}
    
    try:
        response = requests.post(f"{BASE_URL}/user/app-login", json=app_login_data)
        print(f"App登录响应: {response.status_code}")
        if response.status_code == 200:
            app_token_data = response.json()
            app_token = app_token_data.get("access_token")
            print("App登录成功")
        else:
            print(f"App登录失败: {response.text}")
    except Exception as e:
        print(f"App登录请求失败: {e}")
    
    print("\n用户API测试完成")

if __name__ == "__main__":
    test_user_api() 