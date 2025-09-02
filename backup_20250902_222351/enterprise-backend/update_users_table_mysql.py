#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
用户表结构更新脚本
添加多端支持字段：微信OpenID、UnionID、App OpenID、头像等
"""

import pymysql
import logging
from datetime import datetime

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 数据库配置
DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'root',
    'database': 'enterprise',
    'charset': 'utf8mb4'
}

def update_users_table():
    """更新用户表结构"""
    try:
        # 连接数据库
        conn = pymysql.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        logger.info("开始更新用户表结构...")
        
        # 检查表是否存在
        cursor.execute("SHOW TABLES LIKE 'users'")
        if not cursor.fetchone():
            logger.error("users表不存在，请先创建表")
            return False
        
        # 检查字段是否已存在，如果不存在则添加
        columns_to_add = [
            ("wx_openid", "VARCHAR(50) UNIQUE NULL COMMENT '微信OpenID（小程序用户唯一标识）'"),
            ("wx_unionid", "VARCHAR(50) NULL COMMENT '微信UnionID（同一微信账号下唯一）'"),
            ("app_openid", "VARCHAR(50) UNIQUE NULL COMMENT 'App端第三方登录openid'"),
            ("avatar_url", "VARCHAR(255) NULL COMMENT '头像地址'")
        ]
        
        for column_name, column_def in columns_to_add:
            # 检查字段是否已存在
            cursor.execute(f"SHOW COLUMNS FROM users LIKE '{column_name}'")
            if not cursor.fetchone():
                logger.info(f"添加字段: {column_name}")
                cursor.execute(f"ALTER TABLE users ADD COLUMN {column_name} {column_def}")
            else:
                logger.info(f"字段已存在: {column_name}")
        
        # 更新现有字段的注释
        column_comments = [
            ("username", "用户名/昵称（可选）"),
            ("password_hash", "密码Hash（如果有密码则存储）"),
            ("email", "邮箱（可选）"),
            ("phone", "手机号（可选，便于手机号注册登录）"),
            ("role", "用户角色：admin/customer/app_user/wx_user"),
            ("status", "状态：1启用，0禁用"),
            ("created_at", "注册时间"),
            ("updated_at", "更新时间")
        ]
        
        for column_name, comment in column_comments:
            try:
                cursor.execute(f"ALTER TABLE users MODIFY COLUMN {column_name} VARCHAR(255) COMMENT '{comment}'")
                logger.info(f"更新字段注释: {column_name}")
            except Exception as e:
                logger.warning(f"更新字段注释失败: {column_name}, 错误: {e}")
        
        # 提交更改
        conn.commit()
        logger.info("用户表结构更新完成")
        
        # 显示表结构
        cursor.execute("DESCRIBE users")
        columns = cursor.fetchall()
        logger.info("当前用户表结构:")
        for column in columns:
            logger.info(f"  {column[0]}: {column[1]} {column[2]} {column[3]} {column[4]} {column[5]}")
        
        return True
        
    except Exception as e:
        logger.error(f"更新用户表结构失败: {e}")
        if 'conn' in locals():
            conn.rollback()
        return False
    
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

def create_indexes():
    """创建索引"""
    try:
        conn = pymysql.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        logger.info("创建用户表索引...")
        
        # 创建索引
        indexes = [
            ("idx_users_wx_openid", "users", "wx_openid"),
            ("idx_users_app_openid", "users", "app_openid"),
            ("idx_users_role", "users", "role"),
            ("idx_users_status", "users", "status")
        ]
        
        for index_name, table_name, column_name in indexes:
            try:
                cursor.execute(f"CREATE INDEX {index_name} ON {table_name} ({column_name})")
                logger.info(f"创建索引: {index_name}")
            except Exception as e:
                logger.warning(f"创建索引失败: {index_name}, 错误: {e}")
        
        conn.commit()
        logger.info("索引创建完成")
        return True
        
    except Exception as e:
        logger.error(f"创建索引失败: {e}")
        if 'conn' in locals():
            conn.rollback()
        return False
    
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

def main():
    """主函数"""
    logger.info("开始执行用户表结构更新...")
    
    # 更新表结构
    if update_users_table():
        logger.info("表结构更新成功")
        
        # 创建索引
        if create_indexes():
            logger.info("索引创建成功")
        else:
            logger.error("索引创建失败")
    else:
        logger.error("表结构更新失败")
        return
    
    logger.info("用户表结构更新脚本执行完成")

if __name__ == "__main__":
    main() 