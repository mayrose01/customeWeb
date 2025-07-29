#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
调试用户状态脚本
检查用户的实际状态
"""

import pymysql
import logging

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

def debug_user_status():
    """调试用户状态"""
    try:
        # 连接数据库
        conn = pymysql.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        logger.info("开始调试用户状态...")
        
        # 查看所有用户
        cursor.execute("SELECT id, username, role, status, password_hash FROM users ORDER BY id")
        users = cursor.fetchall()
        logger.info(f"当前用户总数: {len(users)}")
        logger.info("用户详细信息:")
        for user in users:
            logger.info(f"  ID={user[0]}, 用户名={user[1]}, 角色={user[2]}, 状态={user[3]}, 密码Hash={'有' if user[4] else '无'}")
        
        # 检查testuser2的状态
        cursor.execute("SELECT id, username, role, status FROM users WHERE username = 'testuser2'")
        testuser = cursor.fetchone()
        if testuser:
            logger.info(f"testuser2状态: ID={testuser[0]}, 用户名={testuser[1]}, 角色={testuser[2]}, 状态={testuser[3]}")
        else:
            logger.info("testuser2不存在")
        
        # 检查微信用户
        cursor.execute("SELECT id, username, role, status, wx_openid FROM users WHERE wx_openid IS NOT NULL")
        wx_users = cursor.fetchall()
        logger.info(f"微信用户数量: {len(wx_users)}")
        for user in wx_users:
            logger.info(f"  微信用户: ID={user[0]}, 用户名={user[1]}, 角色={user[2]}, 状态={user[3]}, OpenID={user[4]}")
        
        # 检查App用户
        cursor.execute("SELECT id, username, role, status, app_openid FROM users WHERE app_openid IS NOT NULL")
        app_users = cursor.fetchall()
        logger.info(f"App用户数量: {len(app_users)}")
        for user in app_users:
            logger.info(f"  App用户: ID={user[0]}, 用户名={user[1]}, 角色={user[2]}, 状态={user[3]}, OpenID={user[4]}")
        
        return True
        
    except Exception as e:
        logger.error(f"调试用户状态失败: {e}")
        return False
    
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

def main():
    """主函数"""
    logger.info("开始执行用户状态调试...")
    
    if debug_user_status():
        logger.info("用户状态调试完成")
    else:
        logger.error("用户状态调试失败")
        return
    
    logger.info("用户状态调试脚本执行完成")

if __name__ == "__main__":
    main() 