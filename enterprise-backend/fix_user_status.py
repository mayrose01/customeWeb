#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修复用户状态脚本
将所有用户设置为启用状态
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

def fix_user_status():
    """修复用户状态"""
    try:
        # 连接数据库
        conn = pymysql.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        logger.info("开始修复用户状态...")
        
        # 检查用户表
        cursor.execute("SELECT COUNT(*) FROM users")
        user_count = cursor.fetchone()[0]
        logger.info(f"当前用户总数: {user_count}")
        
        # 查看当前用户状态
        cursor.execute("SELECT id, username, role, status FROM users")
        users = cursor.fetchall()
        logger.info("当前用户状态:")
        for user in users:
            logger.info(f"  ID={user[0]}, 用户名={user[1]}, 角色={user[2]}, 状态={user[3]}")
        
        # 将所有用户状态设置为启用（1）
        cursor.execute("UPDATE users SET status = 1 WHERE status = 0 OR status IS NULL")
        updated_count = cursor.rowcount
        logger.info(f"更新了 {updated_count} 个用户的状态")
        
        # 确保至少有一个管理员用户
        cursor.execute("SELECT COUNT(*) FROM users WHERE role = 'admin'")
        admin_count = cursor.fetchone()[0]
        
        if admin_count == 0:
            # 创建默认管理员用户
            cursor.execute("""
                INSERT INTO users (username, password_hash, email, role, status)
                VALUES ('admin', '$2b$12$ie933aHQVEyIVIF6Wbz2EebSqrfBGtYrc5R/dZDzoHM8mmnlITpty', 'admin@example.com', 'admin', 1)
            """)
            logger.info("创建默认管理员用户: admin/admin")
        
        # 提交更改
        conn.commit()
        logger.info("用户状态修复完成")
        
        # 显示修复后的用户状态
        cursor.execute("SELECT id, username, role, status FROM users")
        users = cursor.fetchall()
        logger.info("修复后的用户状态:")
        for user in users:
            logger.info(f"  ID={user[0]}, 用户名={user[1]}, 角色={user[2]}, 状态={user[3]}")
        
        return True
        
    except Exception as e:
        logger.error(f"修复用户状态失败: {e}")
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
    logger.info("开始执行用户状态修复...")
    
    if fix_user_status():
        logger.info("用户状态修复成功")
    else:
        logger.error("用户状态修复失败")
        return
    
    logger.info("用户状态修复脚本执行完成")

if __name__ == "__main__":
    main() 