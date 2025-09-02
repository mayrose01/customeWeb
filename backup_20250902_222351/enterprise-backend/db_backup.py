#!/usr/bin/env python3
"""
数据库备份和恢复工具
"""

import os
import subprocess
import logging
from datetime import datetime

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 数据库配置
DB_HOST = "localhost"
DB_PORT = "3306"
DB_USER = "root"
DB_PASSWORD = "root"
DB_NAME = "enterprise"

# 备份目录
BACKUP_DIR = "backups"
os.makedirs(BACKUP_DIR, exist_ok=True)

def backup_database():
    """备份数据库"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = os.path.join(BACKUP_DIR, f"enterprise_backup_{timestamp}.sql")
    
    try:
        cmd = [
            "mysqldump",
            f"--host={DB_HOST}",
            f"--port={DB_PORT}",
            f"--user={DB_USER}",
            f"--password={DB_PASSWORD}",
            "--single-transaction",
            "--routines",
            "--triggers",
            DB_NAME
        ]
        
        with open(backup_file, 'w') as f:
            result = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, text=True)
        
        if result.returncode == 0:
            logger.info(f"数据库备份成功: {backup_file}")
            return backup_file
        else:
            logger.error(f"数据库备份失败: {result.stderr}")
            return None
            
    except Exception as e:
        logger.error(f"备份过程中出现错误: {e}")
        return None

def restore_database(backup_file):
    """恢复数据库"""
    if not os.path.exists(backup_file):
        logger.error(f"备份文件不存在: {backup_file}")
        return False
    
    try:
        cmd = [
            "mysql",
            f"--host={DB_HOST}",
            f"--port={DB_PORT}",
            f"--user={DB_USER}",
            f"--password={DB_PASSWORD}",
            DB_NAME
        ]
        
        with open(backup_file, 'r') as f:
            result = subprocess.run(cmd, stdin=f, stderr=subprocess.PIPE, text=True)
        
        if result.returncode == 0:
            logger.info(f"数据库恢复成功: {backup_file}")
            return True
        else:
            logger.error(f"数据库恢复失败: {result.stderr}")
            return False
            
    except Exception as e:
        logger.error(f"恢复过程中出现错误: {e}")
        return False

def list_backups():
    """列出所有备份文件"""
    backup_files = []
    for file in os.listdir(BACKUP_DIR):
        if file.endswith('.sql'):
            file_path = os.path.join(BACKUP_DIR, file)
            file_size = os.path.getsize(file_path)
            file_time = datetime.fromtimestamp(os.path.getmtime(file_path))
            backup_files.append({
                'file': file,
                'path': file_path,
                'size': file_size,
                'time': file_time
            })
    
    # 按时间排序
    backup_files.sort(key=lambda x: x['time'], reverse=True)
    return backup_files

def main():
    """主函数"""
    import sys
    
    if len(sys.argv) < 2:
        print("使用方法:")
        print("  python3 db_backup.py backup    # 备份数据库")
        print("  python3 db_backup.py restore <file>  # 恢复数据库")
        print("  python3 db_backup.py list      # 列出备份文件")
        return
    
    command = sys.argv[1]
    
    if command == "backup":
        backup_file = backup_database()
        if backup_file:
            print(f"备份成功: {backup_file}")
        else:
            print("备份失败")
    
    elif command == "restore":
        if len(sys.argv) < 3:
            print("请指定备份文件路径")
            return
        
        backup_file = sys.argv[2]
        if restore_database(backup_file):
            print("恢复成功")
        else:
            print("恢复失败")
    
    elif command == "list":
        backups = list_backups()
        if backups:
            print("备份文件列表:")
            for backup in backups:
                print(f"  {backup['file']} - {backup['time']} - {backup['size']} bytes")
        else:
            print("没有找到备份文件")
    
    else:
        print(f"未知命令: {command}")

if __name__ == "__main__":
    main() 