#!/usr/bin/env python3
"""
数据库迁移管理脚本
用于管理数据库结构的变更
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

# 添加项目根目录到Python路径
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.config import settings

def run_command(command, description=""):
    """运行命令并显示结果"""
    print(f"🔄 {description}")
    print(f"执行命令: {command}")
    
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        if result.stdout:
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ 命令执行失败: {e}")
        if e.stderr:
            print(f"错误信息: {e.stderr}")
        return False

def check_alembic_installed():
    """检查Alembic是否已安装"""
    try:
        import alembic
        return True
    except ImportError:
        print("❌ Alembic未安装，请先安装: pip install alembic")
        return False

def init_migrations():
    """初始化迁移环境"""
    if not check_alembic_installed():
        return False
    
    print("🚀 初始化数据库迁移环境...")
    
    # 检查是否已经初始化
    if os.path.exists("migrations"):
        print("⚠️  迁移环境已存在，跳过初始化")
        return True
    
    # 初始化Alembic
    if not run_command("alembic init migrations", "初始化Alembic迁移环境"):
        return False
    
    print("✅ 迁移环境初始化完成")
    return True

def create_migration(message):
    """创建新的迁移文件"""
    if not check_alembic_installed():
        return False
    
    if not message:
        print("❌ 请提供迁移描述信息")
        return False
    
    print(f"📝 创建迁移: {message}")
    
    # 创建迁移文件
    if not run_command(f'alembic revision --autogenerate -m "{message}"', "生成迁移文件"):
        return False
    
    print("✅ 迁移文件创建完成")
    print("💡 请检查生成的迁移文件，确认无误后运行迁移")
    return True

def upgrade_database(revision="head"):
    """升级数据库到指定版本"""
    if not check_alembic_installed():
        return False
    
    print(f"⬆️  升级数据库到版本: {revision}")
    
    # 显示当前版本
    run_command("alembic current", "查看当前数据库版本")
    
    # 执行升级
    if not run_command(f"alembic upgrade {revision}", "执行数据库升级"):
        return False
    
    print("✅ 数据库升级完成")
    return True

def downgrade_database(revision):
    """降级数据库到指定版本"""
    if not check_alembic_installed():
        return False
    
    print(f"⬇️  降级数据库到版本: {revision}")
    
    # 显示当前版本
    run_command("alembic current", "查看当前数据库版本")
    
    # 执行降级
    if not run_command(f"alembic downgrade {revision}", "执行数据库降级"):
        return False
    
    print("✅ 数据库降级完成")
    return True

def show_history():
    """显示迁移历史"""
    if not check_alembic_installed():
        return False
    
    print("📋 迁移历史:")
    run_command("alembic history --verbose", "显示迁移历史")
    return True

def show_current():
    """显示当前数据库版本"""
    if not check_alembic_installed():
        return False
    
    print("📍 当前数据库版本:")
    run_command("alembic current", "显示当前版本")
    return True

def show_pending():
    """显示待执行的迁移"""
    if not check_alembic_installed():
        return False
    
    print("⏳ 待执行的迁移:")
    run_command("alembic heads", "显示最新版本")
    run_command("alembic current", "显示当前版本")
    return True

def reset_database():
    """重置数据库（危险操作）"""
    if not check_alembic_installed():
        return False
    
    print("⚠️  警告: 这将删除所有数据并重新创建数据库结构")
    confirm = input("确认继续? (yes/no): ")
    
    if confirm.lower() != 'yes':
        print("❌ 操作已取消")
        return False
    
    print("🔄 重置数据库...")
    
    # 降级到基础版本
    if not run_command("alembic downgrade base", "降级到基础版本"):
        return False
    
    # 升级到最新版本
    if not run_command("alembic upgrade head", "升级到最新版本"):
        return False
    
    print("✅ 数据库重置完成")
    return True

def main():
    parser = argparse.ArgumentParser(description="数据库迁移管理工具")
    parser.add_argument("--env", default="development", help="环境 (development/testing/production)")
    
    subparsers = parser.add_subparsers(dest="command", help="可用命令")
    
    # 初始化命令
    subparsers.add_parser("init", help="初始化迁移环境")
    
    # 创建迁移命令
    create_parser = subparsers.add_parser("create", help="创建新的迁移文件")
    create_parser.add_argument("message", help="迁移描述信息")
    
    # 升级命令
    upgrade_parser = subparsers.add_parser("upgrade", help="升级数据库")
    upgrade_parser.add_argument("--revision", default="head", help="目标版本 (默认: head)")
    
    # 降级命令
    downgrade_parser = subparsers.add_parser("downgrade", help="降级数据库")
    downgrade_parser.add_argument("revision", help="目标版本")
    
    # 查看历史命令
    subparsers.add_parser("history", help="显示迁移历史")
    
    # 查看当前版本命令
    subparsers.add_parser("current", help="显示当前数据库版本")
    
    # 查看待执行迁移命令
    subparsers.add_parser("pending", help="显示待执行的迁移")
    
    # 重置数据库命令
    subparsers.add_parser("reset", help="重置数据库 (危险操作)")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    # 设置环境变量
    os.environ["ENVIRONMENT"] = args.env
    print(f"🌍 当前环境: {args.env}")
    print(f"🗄️  数据库URL: {settings.DATABASE_URL}")
    print("=" * 50)
    
    # 执行对应命令
    if args.command == "init":
        init_migrations()
    elif args.command == "create":
        create_migration(args.message)
    elif args.command == "upgrade":
        upgrade_database(args.revision)
    elif args.command == "downgrade":
        downgrade_database(args.revision)
    elif args.command == "history":
        show_history()
    elif args.command == "current":
        show_current()
    elif args.command == "pending":
        show_pending()
    elif args.command == "reset":
        reset_database()

if __name__ == "__main__":
    main()
