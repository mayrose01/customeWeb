#!/usr/bin/env python3
"""
日志查看工具
"""

import os
import re
import sys
from datetime import datetime, timedelta
from collections import defaultdict

def read_log_file(log_file):
    """读取日志文件"""
    if not os.path.exists(log_file):
        print(f"日志文件不存在: {log_file}")
        return []
    
    with open(log_file, 'r', encoding='utf-8') as f:
        return f.readlines()

def parse_log_line(line):
    """解析日志行"""
    # 日志格式: 2024-01-01 12:00:00,000 - app.main - INFO - 消息内容
    pattern = r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}) - (\w+) - (\w+) - (.+)'
    match = re.match(pattern, line.strip())
    
    if match:
        timestamp, module, level, message = match.groups()
        return {
            'timestamp': timestamp,
            'module': module,
            'level': level,
            'message': message,
            'raw': line.strip()
        }
    return None

def filter_logs(logs, level=None, module=None, keyword=None, hours=None):
    """过滤日志"""
    filtered = []
    
    for log in logs:
        parsed = parse_log_line(log)
        if not parsed:
            continue
        
        # 时间过滤
        if hours:
            log_time = datetime.strptime(parsed['timestamp'], '%Y-%m-%d %H:%M:%S,%f')
            cutoff_time = datetime.now() - timedelta(hours=hours)
            if log_time < cutoff_time:
                continue
        
        # 级别过滤
        if level and parsed['level'] != level.upper():
            continue
        
        # 模块过滤
        if module and module not in parsed['module']:
            continue
        
        # 关键词过滤
        if keyword and keyword.lower() not in parsed['message'].lower():
            continue
        
        filtered.append(parsed)
    
    return filtered

def analyze_logs(logs):
    """分析日志"""
    stats = {
        'total': len(logs),
        'levels': defaultdict(int),
        'modules': defaultdict(int),
        'errors': [],
        'warnings': [],
        'deletions': [],
        'creations': [],
        'updates': []
    }
    
    for log in logs:
        stats['levels'][log['level']] += 1
        stats['modules'][log['module']] += 1
        
        message = log['message'].lower()
        
        if log['level'] == 'ERROR':
            stats['errors'].append(log)
        elif log['level'] == 'WARNING':
            stats['warnings'].append(log)
        
        if '删除' in log['message']:
            stats['deletions'].append(log)
        elif '创建' in log['message']:
            stats['creations'].append(log)
        elif '更新' in log['message']:
            stats['updates'].append(log)
    
    return stats

def print_logs(logs, limit=None):
    """打印日志"""
    if limit:
        logs = logs[-limit:]
    
    for log in logs:
        print(f"[{log['timestamp']}] {log['level']} - {log['module']} - {log['message']}")

def print_stats(stats):
    """打印统计信息"""
    print("\n=== 日志统计 ===")
    print(f"总日志条数: {stats['total']}")
    
    print("\n日志级别分布:")
    for level, count in stats['levels'].items():
        print(f"  {level}: {count}")
    
    print("\n模块分布:")
    for module, count in stats['modules'].items():
        print(f"  {module}: {count}")
    
    print(f"\n错误数量: {len(stats['errors'])}")
    print(f"警告数量: {len(stats['warnings'])}")
    print(f"删除操作: {len(stats['deletions'])}")
    print(f"创建操作: {len(stats['creations'])}")
    print(f"更新操作: {len(stats['updates'])}")

def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("使用方法:")
        print("  python3 log_viewer.py <log_file> [options]")
        print("\n选项:")
        print("  --level <level>     过滤日志级别 (INFO, WARNING, ERROR)")
        print("  --module <module>   过滤模块名")
        print("  --keyword <keyword> 过滤关键词")
        print("  --hours <hours>     只显示最近N小时的日志")
        print("  --limit <number>    限制显示条数")
        print("  --stats             显示统计信息")
        print("  --errors            只显示错误")
        print("  --warnings          只显示警告")
        print("  --deletions         只显示删除操作")
        print("  --creations         只显示创建操作")
        print("  --updates           只显示更新操作")
        return
    
    log_file = sys.argv[1]
    
    # 解析参数
    level = None
    module = None
    keyword = None
    hours = None
    limit = None
    show_stats = False
    show_errors = False
    show_warnings = False
    show_deletions = False
    show_creations = False
    show_updates = False
    
    i = 2
    while i < len(sys.argv):
        arg = sys.argv[i]
        
        if arg == '--level' and i + 1 < len(sys.argv):
            level = sys.argv[i + 1]
            i += 2
        elif arg == '--module' and i + 1 < len(sys.argv):
            module = sys.argv[i + 1]
            i += 2
        elif arg == '--keyword' and i + 1 < len(sys.argv):
            keyword = sys.argv[i + 1]
            i += 2
        elif arg == '--hours' and i + 1 < len(sys.argv):
            hours = int(sys.argv[i + 1])
            i += 2
        elif arg == '--limit' and i + 1 < len(sys.argv):
            limit = int(sys.argv[i + 1])
            i += 2
        elif arg == '--stats':
            show_stats = True
            i += 1
        elif arg == '--errors':
            show_errors = True
            i += 1
        elif arg == '--warnings':
            show_warnings = True
            i += 1
        elif arg == '--deletions':
            show_deletions = True
            i += 1
        elif arg == '--creations':
            show_creations = True
            i += 1
        elif arg == '--updates':
            show_updates = True
            i += 1
        else:
            i += 1
    
    # 读取日志
    raw_logs = read_log_file(log_file)
    if not raw_logs:
        return
    
    # 过滤日志
    logs = filter_logs(raw_logs, level, module, keyword, hours)
    
    # 根据特殊选项进一步过滤
    if show_errors:
        logs = [log for log in logs if log['level'] == 'ERROR']
    elif show_warnings:
        logs = [log for log in logs if log['level'] == 'WARNING']
    elif show_deletions:
        logs = [log for log in logs if '删除' in log['message']]
    elif show_creations:
        logs = [log for log in logs if '创建' in log['message']]
    elif show_updates:
        logs = [log for log in logs if '更新' in log['message']]
    
    # 显示统计信息
    if show_stats:
        stats = analyze_logs(logs)
        print_stats(stats)
    else:
        # 显示日志
        print_logs(logs, limit)

if __name__ == "__main__":
    main() 