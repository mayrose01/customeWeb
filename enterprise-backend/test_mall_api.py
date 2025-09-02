#!/usr/bin/env python3
"""
测试商城API是否正常工作的脚本
"""

import requests
import json

# API基础URL
BASE_URL = "http://localhost:8000/api"

def test_mall_apis():
    """测试商城相关的API接口"""
    
    print("🚀 开始测试商城API...")
    
    # 测试健康检查
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"✅ 健康检查: {response.status_code}")
        if response.status_code == 200:
            print(f"   响应: {response.json()}")
    except Exception as e:
        print(f"❌ 健康检查失败: {e}")
        return False
    
    # 测试商城分类API
    try:
        response = requests.get(f"{BASE_URL}/mall-category/")
        print(f"✅ 商城分类列表: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   分类数量: {len(data)}")
            if data:
                print(f"   第一个分类: {data[0]}")
        else:
            print(f"   错误响应: {response.text}")
    except Exception as e:
        print(f"❌ 商城分类API失败: {e}")
    
    # 测试商城产品API
    try:
        response = requests.get(f"{BASE_URL}/mall-product/")
        print(f"✅ 商城产品列表: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   产品数量: {data.get('total', len(data))}")
            if data.get('items'):
                print(f"   第一个产品: {data['items'][0]}")
        else:
            print(f"   错误响应: {response.text}")
    except Exception as e:
        print(f"❌ 商城产品API失败: {e}")
    
    # 测试商城订单API
    try:
        response = requests.get(f"{BASE_URL}/mall-order/")
        print(f"✅ 商城订单列表: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   订单数量: {data.get('total', len(data))}")
            if data.get('items'):
                print(f"   第一个订单: {data['items'][0]}")
        else:
            print(f"   错误响应: {response.text}")
    except Exception as e:
        print(f"❌ 商城订单API失败: {e}")
    
    return True

def test_create_category():
    """测试创建分类"""
    print("\n🧪 测试创建分类...")
    
    category_data = {
        "name": "测试分类",
        "description": "这是一个测试分类",
        "sort_order": 999,
        "status": "active"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/mall-category/",
            json=category_data,
            headers={"Content-Type": "application/json"}
        )
        print(f"✅ 创建分类: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   创建成功: {data}")
            return data.get('id')
        else:
            print(f"   错误响应: {response.text}")
            return None
    except Exception as e:
        print(f"❌ 创建分类失败: {e}")
        return None

def test_create_product():
    """测试创建产品"""
    print("\n🧪 测试创建产品...")
    
    product_data = {
        "title": "测试产品",
        "description": "这是一个测试产品",
        "category_id": 1,  # 假设分类ID为1
        "base_price": 99.99,
        "stock": 100,
        "status": "active",
        "sort_order": 999
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/mall-product/",
            json=product_data,
            headers={"Content-Type": "application/json"}
        )
        print(f"✅ 创建产品: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   创建成功: {data}")
            return data.get('id')
        else:
            print(f"   错误响应: {response.text}")
            return None
    except Exception as e:
        print(f"❌ 创建产品失败: {e}")
        return None

if __name__ == "__main__":
    print("=" * 50)
    print("商城API测试工具")
    print("=" * 50)
    
    # 测试基本API
    if test_mall_apis():
        print("\n" + "=" * 50)
        print("开始测试创建操作...")
        
        # 测试创建分类
        category_id = test_create_category()
        
        # 测试创建产品
        product_id = test_create_product()
        
        print("\n" + "=" * 50)
        print("测试完成！")
        if category_id:
            print(f"✅ 测试分类创建成功，ID: {category_id}")
        if product_id:
            print(f"✅ 测试产品创建成功，ID: {product_id}")
    else:
        print("❌ API测试失败，请检查后端服务是否正常运行")
