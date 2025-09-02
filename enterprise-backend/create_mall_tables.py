#!/usr/bin/env python3
"""
创建商城相关数据库表的迁移脚本
"""

import os
import sys
import pymysql
from pymysql import Error

# 数据库配置 - 使用开发环境配置
DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,  # 开发环境端口
    'user': 'root',
    'password': 'root',
    'database': 'enterprise_dev',
    'charset': 'utf8mb4'
}

def create_mall_tables():
    """创建商城相关的数据库表"""
    try:
        # 连接数据库
        connection = pymysql.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        print("✅ 成功连接到数据库")
        
        # 创建商城分类表
        create_mall_categories_table = """
        CREATE TABLE IF NOT EXISTS mall_categories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            parent_id INT,
            image VARCHAR(255),
            sort_order INT DEFAULT 0,
            status VARCHAR(20) DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (parent_id) REFERENCES mall_categories(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        # 创建商城产品表
        create_mall_products_table = """
        CREATE TABLE IF NOT EXISTS mall_products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            description TEXT,
            images JSON,
            category_id INT NOT NULL,
            base_price DECIMAL(10,2) DEFAULT 0.00,
            stock INT DEFAULT 0,
            status VARCHAR(20) DEFAULT 'active',
            sort_order INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (category_id) REFERENCES mall_categories(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        # 创建商城产品规格表
        create_mall_product_specifications_table = """
        CREATE TABLE IF NOT EXISTS mall_product_specifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            name VARCHAR(100) NOT NULL,
            sort_order INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES mall_products(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        # 创建商城产品规格值表
        create_mall_product_specification_values_table = """
        CREATE TABLE IF NOT EXISTS mall_product_specification_values (
            id INT AUTO_INCREMENT PRIMARY KEY,
            specification_id INT NOT NULL,
            value VARCHAR(100) NOT NULL,
            sort_order INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (specification_id) REFERENCES mall_product_specifications(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        # 创建商城产品SKU表
        create_mall_product_skus_table = """
        CREATE TABLE IF NOT EXISTS mall_product_skus (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            sku_code VARCHAR(100) UNIQUE NOT NULL,
            price DECIMAL(10,2) NOT NULL,
            stock INT DEFAULT 0,
            weight DECIMAL(8,3) DEFAULT 0.000,
            specifications JSON,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES mall_products(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        # 创建商城订单表
        create_mall_orders_table = """
        CREATE TABLE IF NOT EXISTS mall_orders (
            id INT AUTO_INCREMENT PRIMARY KEY,
            order_no VARCHAR(100) UNIQUE NOT NULL,
            user_id INT NOT NULL,
            total_amount DECIMAL(10,2) NOT NULL,
            status VARCHAR(20) DEFAULT 'pending',
            payment_status VARCHAR(20) DEFAULT 'unpaid',
            payment_method VARCHAR(50),
            payment_time TIMESTAMP NULL,
            shipping_address TEXT,
            shipping_company VARCHAR(100),
            tracking_number VARCHAR(100),
            shipping_time TIMESTAMP NULL,
            remark TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        # 创建商城订单项表
        create_mall_order_items_table = """
        CREATE TABLE IF NOT EXISTS mall_order_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            order_id INT NOT NULL,
            product_id INT NOT NULL,
            sku_id INT,
            product_name VARCHAR(255) NOT NULL,
            sku_specifications JSON,
            price DECIMAL(10,2) NOT NULL,
            quantity INT NOT NULL,
            subtotal DECIMAL(10,2) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (order_id) REFERENCES mall_orders(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES mall_products(id) ON DELETE CASCADE,
            FOREIGN KEY (sku_id) REFERENCES mall_product_skus(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        # 创建商城购物车表
        create_mall_carts_table = """
        CREATE TABLE IF NOT EXISTS mall_carts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        # 创建商城购物车项表
        create_mall_cart_items_table = """
        CREATE TABLE IF NOT EXISTS mall_cart_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            cart_id INT NOT NULL,
            product_id INT NOT NULL,
            sku_id INT,
            quantity INT NOT NULL DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (cart_id) REFERENCES mall_carts(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES mall_products(id) ON DELETE CASCADE,
            FOREIGN KEY (sku_id) REFERENCES mall_product_skus(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        # 执行创建表的SQL语句
        tables = [
            ("商城分类表", create_mall_categories_table),
            ("商城产品表", create_mall_products_table),
            ("商城产品规格表", create_mall_product_specifications_table),
            ("商城产品规格值表", create_mall_product_specification_values_table),
            ("商城产品SKU表", create_mall_product_skus_table),
            ("商城订单表", create_mall_orders_table),
            ("商城订单项表", create_mall_order_items_table),
            ("商城购物车表", create_mall_carts_table),
            ("商城购物车项表", create_mall_cart_items_table)
        ]
        
        for table_name, sql in tables:
            try:
                cursor.execute(sql)
                print(f"✅ 成功创建{table_name}")
            except Error as e:
                print(f"❌ 创建{table_name}失败: {e}")
        
        # 提交更改
        connection.commit()
        print("✅ 所有表创建完成")
        
        # 插入一些示例数据
        insert_sample_data(cursor)
        
        connection.commit()
        print("✅ 示例数据插入完成")
        
    except Error as e:
        print(f"❌ 数据库连接失败: {e}")
        return False
    finally:
        if connection:
            cursor.close()
            connection.close()
            print("✅ 数据库连接已关闭")
    
    return True

def insert_sample_data(cursor):
    """插入示例数据"""
    try:
        # 插入示例分类
        sample_categories = [
            ("电子产品", "手机、电脑、配件等数码产品", None, None, 1, "active"),
            ("服装鞋帽", "男装、女装、童装、鞋帽等", None, None, 2, "active"),
            ("家居用品", "家具、装饰、厨具等家居产品", None, None, 3, "active"),
            ("美妆护肤", "护肤品、彩妆、香水等", None, None, 4, "active"),
            ("运动户外", "运动装备、户外用品等", None, None, 5, "active")
        ]
        
        for category in sample_categories:
            cursor.execute("""
                INSERT INTO mall_categories (name, description, parent_id, image, sort_order, status)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, category)
        
        print("✅ 插入示例分类数据")
        
        # 插入示例产品
        sample_products = [
            ("智能手机", "最新款智能手机，性能强劲", '[]', 1, 2999.00, 50, "active", 1),
            ("无线耳机", "高品质无线蓝牙耳机", '[]', 1, 299.00, 100, "active", 2),
            ("智能手表", "多功能智能手表", '[]', 1, 899.00, 30, "active", 3),
            ("男士休闲鞋", "舒适休闲鞋", '[]', 2, 299.00, 80, "active", 1),
            ("女士连衣裙", "时尚连衣裙", '[]', 2, 199.00, 60, "active", 2)
        ]
        
        for product in sample_products:
            cursor.execute("""
                INSERT INTO mall_products (title, description, images, category_id, base_price, stock, status, sort_order)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, product)
        
        print("✅ 插入示例产品数据")
        
    except Error as e:
        print(f"❌ 插入示例数据失败: {e}")

if __name__ == "__main__":
    print("🚀 开始创建商城数据库表...")
    
    # 检查数据库配置
    if len(sys.argv) > 1:
        if sys.argv[1] == "--help":
            print("用法: python create_mall_tables.py [--help]")
            print("创建商城相关的数据库表")
            sys.exit(0)
    
    # 创建表
    success = create_mall_tables()
    
    if success:
        print("🎉 商城数据库表创建成功！")
    else:
        print("💥 商城数据库表创建失败！")
        sys.exit(1)
