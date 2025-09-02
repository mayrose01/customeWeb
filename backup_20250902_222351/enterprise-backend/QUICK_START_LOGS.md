# 日志和备份系统 - 快速开始

## 🚀 已完成的配置

✅ **日志系统已启用**
- 所有API请求都会被记录
- 所有数据库操作（创建、更新、删除）都会被记录
- 删除操作会记录完整的删除前数据
- 日志文件：`logs/app_YYYYMMDD.log`

✅ **数据库备份系统已配置**
- 自动备份到 `backups/` 目录
- 备份文件格式：`enterprise_backup_YYYYMMDD_HHMMSS.sql`

## 📋 常用命令

### 查看日志
```bash
# 查看今天的日志
python3 log_viewer.py logs/app_$(date +%Y%m%d).log

# 只查看删除操作
python3 log_viewer.py logs/app_$(date +%Y%m%d).log --deletions

# 只查看错误
python3 log_viewer.py logs/app_$(date +%Y%m%d).log --errors

# 查看最近1小时的日志
python3 log_viewer.py logs/app_$(date +%Y%m%d).log --hours 1
```

### 数据库备份
```bash
# 创建备份
python3 db_backup.py backup

# 查看备份列表
python3 db_backup.py list

# 恢复数据库（谨慎使用）
python3 db_backup.py restore backups/enterprise_backup_YYYYMMDD_HHMMSS.sql
```

## 🔍 问题排查

### 如果数据丢失了：
1. **立即查看删除日志**：
   ```bash
   python3 log_viewer.py logs/app_$(date +%Y%m%d).log --deletions
   ```

2. **查看最近的错误**：
   ```bash
   python3 log_viewer.py logs/app_$(date +%Y%m%d).log --errors
   ```

3. **从备份恢复**：
   ```bash
   python3 db_backup.py list
   python3 db_backup.py restore backups/最新的备份文件.sql
   ```

### 如果系统异常：
1. **查看API请求日志**：
   ```bash
   python3 log_viewer.py logs/app_$(date +%Y%m%d).log --hours 2
   ```

2. **查看统计信息**：
   ```bash
   python3 log_viewer.py logs/app_$(date +%Y%m%d).log --stats
   ```

## 📁 文件说明

- `logs/` - 日志文件目录
- `backups/` - 数据库备份目录
- `log_viewer.py` - 日志查看工具
- `db_backup.py` - 数据库备份工具
- `README_LOGS.md` - 详细使用说明

## ⚠️ 重要提醒

1. **定期备份**：建议每天备份一次数据库
2. **监控删除**：特别关注删除操作的日志
3. **日志清理**：定期清理旧的日志文件
4. **权限控制**：确保只有授权人员访问日志和备份

## 🆘 紧急情况

如果遇到数据问题，按以下顺序处理：

1. **立即停止服务**（防止进一步数据丢失）
2. **查看删除日志**（确认丢失的数据）
3. **从备份恢复**（如果有备份）
4. **从日志重建**（如果日志记录了完整数据）

---

**现在你的数据安全了！** 🛡️

每次删除操作都会被完整记录，包括删除前的所有数据。如果出现问题，可以快速定位和恢复。 