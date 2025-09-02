#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
修复tuple类型注解的脚本
"""

import os
import re

def fix_tuple_types(file_path):
    """修复文件中的tuple类型注解"""
    print(f"修复文件: {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 修复类型注解
    original_content = content
    
    # 修复 tuple[List, int] -> Tuple[List, int]
    content = re.sub(r'tuple\[List, int\]', 'Tuple[List, int]', content)
    content = re.sub(r'tuple\[List, str\]', 'Tuple[List, str]', content)
    content = re.sub(r'tuple\[List, Any\]', 'Tuple[List, Any]', content)
    
    # 如果内容有变化，写回文件
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ 已修复: {file_path}")
        return True
    else:
        print(f"⚠️ 无需修复: {file_path}")
        return False

def find_and_fix_python_files(directory):
    """查找并修复Python文件"""
    fixed_count = 0
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.py'):
                file_path = os.path.join(root, file)
                if fix_tuple_types(file_path):
                    fixed_count += 1
    
    return fixed_count

if __name__ == "__main__":
    # 要修复的目录
    target_dir = "/var/www/enterprise/enterprise-backend/app"
    
    print("开始修复tuple类型注解...")
    print(f"目标目录: {target_dir}")
    
    if os.path.exists(target_dir):
        fixed_count = find_and_fix_python_files(target_dir)
        print(f"\n修复完成！共修复了 {fixed_count} 个文件")
    else:
        print(f"目录不存在: {target_dir}")
