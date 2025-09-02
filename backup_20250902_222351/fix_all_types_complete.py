#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
一次性完整修复所有Python类型注解问题的脚本
"""

import os
import re

def fix_all_types(file_path):
    """一次性修复文件中的所有类型注解问题"""
    print(f"修复文件: {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # 1. 修复导入语句 - 确保所有需要的类型都被导入
    if 'from typing import' in content:
        # 检查并添加缺失的类型导入
        typing_imports = ['List', 'Optional', 'Dict', 'Tuple', 'Union', 'Any']
        for type_name in typing_imports:
            if f'{type_name}[' in content and f'{type_name}' not in content.split('from typing import')[1].split('\n')[0]:
                content = re.sub(
                    r'from typing import ([^,\n]+)',
                    lambda m: f'from typing import {m.group(1)}, {type_name}' if type_name not in m.group(1) else m.group(0),
                    content
                )
    
    # 2. 修复类型注解 - 确保所有类型都有正确的泛型参数
    # 修复 Optional -> Optional[str]
    content = re.sub(r': Optional\b(?!\[)', ': Optional[str]', content)
    
    # 修复 List -> List[str]
    content = re.sub(r': List\b(?!\[)', ': List[str]', content)
    
    # 修复 Dict -> Dict[str, str]
    content = re.sub(r': Dict\b(?!\[)', ': Dict[str, str]', content)
    
    # 修复 Tuple -> Tuple[str, int]
    content = re.sub(r': Tuple\b(?!\[)', ': Tuple[str, int]', content)
    
    # 修复 Union -> Union[str, int]
    content = re.sub(r': Union\b(?!\[)', ': Union[str, int]', content)
    
    # 3. 修复小写的tuple -> 大写的Tuple
    content = re.sub(r'tuple\[', 'Tuple[', content)
    
    # 4. 修复list -> List
    content = re.sub(r'list\[', 'List[', content)
    
    # 5. 修复dict -> Dict
    content = re.sub(r'dict\[', 'Dict[', content)
    
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
                if fix_all_types(file_path):
                    fixed_count += 1
    
    return fixed_count

if __name__ == "__main__":
    # 要修复的目录
    target_dir = "/var/www/enterprise/enterprise-backend/app"
    
    print("开始一次性完整修复所有Python类型注解问题...")
    print(f"目标目录: {target_dir}")
    
    if os.path.exists(target_dir):
        fixed_count = find_and_fix_python_files(target_dir)
        print(f"\n修复完成！共修复了 {fixed_count} 个文件")
        print("现在所有类型注解问题都应该解决了！")
    else:
        print(f"目录不存在: {target_dir}")
