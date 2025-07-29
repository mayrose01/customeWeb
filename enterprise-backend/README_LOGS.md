# 日志和备份系统使用说明

## 概述

为了确保数据安全和便于问题排查，系统已集成完整的日志记录和数据库备份功能。

## 日志系统

### 日志文件位置
- 日志文件存储在 `logs/` 目录下
- 日志文件按日期命名：`app_YYYYMMDD.log`
- 例如：`logs/app_20240726.log`

### 日志内容
系统会记录以下操作：

#### 1. API请求日志
- 所有API请求的开始和结束
- 请求方法、路径、状态码
- 处理时间
- 客户端IP地址

#### 2. 数据库操作日志
- **创建操作**：记录创建的产品、分类、用户等
- **更新操作**：记录更新前后的数据对比
- **删除操作**：记录删除前的完整数据（重要！）
- **错误操作**：记录无效的删除、更新尝试

#### 3. 系统日志
- 服务启动信息
- 数据库连接状态
- 错误和警告信息

### 日志级别
- `INFO`：正常操作信息
- `WARNING`：警告信息（如尝试删除有子分类的分类）
- `ERROR`：错误信息

## 日志查看工具

### 基本用法
```bash
# 查看今天的日志
python3 log_viewer.py logs/app_20240726.log

# 只显示最近1小时的日志
python3 log_viewer.py logs/app_20240726.log --hours 1

# 只显示错误日志
python3 log_viewer.py logs/app_20240726.log --errors

# 只显示删除操作
python3 log_viewer.py logs/app_20240726.log --deletions

# 显示统计信息
python3 log_viewer.py logs/app_20240726.log --stats
```

### 高级过滤
```bash
# 按关键词过滤
python3 log_viewer.py logs/app_20240726.log --keyword "删除产品"

# 按模块过滤
python3 log_viewer.py logs/app_20240726.log --module crud

# 按日志级别过滤
python3 log_viewer.py logs/app_20240726.log --level WARNING

# 限制显示条数
python3 log_viewer.py logs/app_20240726.log --limit 50
```

### 组合使用
```bash
# 显示最近2小时的所有删除操作
python3 log_viewer.py logs/app_20240726.log --hours 2 --deletions

# 显示包含"产品"关键词的错误日志
python3 log_viewer.py logs/app_20240726.log --errors --keyword "产品"
```

## 数据库备份系统

### 备份数据库
```bash
# 创建备份
python3 db_backup.py backup
```

备份文件将保存在 `backups/` 目录下，文件名格式：`enterprise_backup_YYYYMMDD_HHMMSS.sql`

### 查看备份列表
```bash
# 列出所有备份文件
python3 db_backup.py list
```

### 恢复数据库
```bash
# 从备份文件恢复
python3 db_backup.py restore backups/enterprise_backup_20240726_143022.sql
```

## 问题排查指南

### 1. 数据丢失排查
如果发现数据丢失，按以下步骤排查：

1. **查看删除日志**
   ```bash
   python3 log_viewer.py logs/app_$(date +%Y%m%d).log --deletions
   ```

2. **查看错误日志**
   ```bash
   python3 log_viewer.py logs/app_$(date +%Y%m%d).log --errors
   ```

3. **查看最近的API请求**
   ```bash
   python3 log_viewer.py logs/app_$(date +%Y%m%d).log --hours 24
   ```

### 2. 恢复数据
如果确认是误删除，可以：

1. **从备份恢复**
   ```bash
   python3 db_backup.py list
   python3 db_backup.py restore backups/enterprise_backup_YYYYMMDD_HHMMSS.sql
   ```

2. **从日志重建数据**
   删除日志会记录完整的删除前数据，可以手动重建

### 3. 性能问题排查
```bash
# 查看处理时间较长的请求
python3 log_viewer.py logs/app_$(date +%Y%m%d).log --keyword "处理时间"
```

## 安全建议

1. **定期备份**：建议每天至少备份一次数据库
2. **日志轮转**：定期清理旧的日志文件
3. **监控删除操作**：特别关注删除操作的日志
4. **权限控制**：确保只有授权人员可以访问日志和备份文件

## 示例场景

### 场景1：产品被误删除
```bash
# 1. 查看删除日志
python3 log_viewer.py logs/app_20240726.log --deletions --keyword "产品"

# 2. 查看具体删除时间
python3 log_viewer.py logs/app_20240726.log --keyword "删除产品" --hours 24

# 3. 从备份恢复
python3 db_backup.py restore backups/enterprise_backup_20240726_100000.sql
```

### 场景2：分类数据异常
```bash
# 1. 查看分类相关操作
python3 log_viewer.py logs/app_20240726.log --keyword "分类"

# 2. 查看警告信息
python3 log_viewer.py logs/app_20240726.log --warnings

# 3. 查看统计信息
python3 log_viewer.py logs/app_20240726.log --stats
```

## 注意事项

1. **日志文件大小**：日志文件会随时间增长，需要定期清理
2. **备份文件存储**：备份文件包含完整数据，注意存储空间
3. **敏感信息**：日志可能包含敏感信息，注意访问权限
4. **时间同步**：确保服务器时间准确，便于日志分析

## 联系支持

如果遇到问题或需要技术支持，请提供：
1. 相关的日志文件
2. 具体的错误信息
3. 操作步骤和时间
4. 数据库备份文件（如果涉及数据恢复） 