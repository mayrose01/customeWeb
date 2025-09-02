# Docker 数据管理指南

## 🎯 数据持久化说明

### ✅ 你的配置支持数据持久化

根据你的 `docker-compose.test.yml` 配置，**数据会持久化**：

```yaml
volumes:
  - mysql_test_data:/var/lib/mysql  # 命名卷，数据会持久化
  - ./enterprise-backend/uploads_test:/app/uploads  # 绑定挂载，数据会持久化
  - ./enterprise-backend/logs:/app/logs  # 绑定挂载，数据会持久化
```

## 📊 数据持久化对比

### 1. 命名卷 (Named Volumes) - ✅ 持久化
```yaml
volumes:
  - mysql_test_data:/var/lib/mysql
```
- **数据位置**: Docker管理的卷
- **持久化**: ✅ 重启后数据保留
- **管理**: `docker volume` 命令管理

### 2. 绑定挂载 (Bind Mounts) - ✅ 持久化
```yaml
volumes:
  - ./uploads_test:/app/uploads
```
- **数据位置**: 主机文件系统
- **持久化**: ✅ 重启后数据保留
- **管理**: 直接操作主机文件

### 3. 临时存储 - ❌ 不持久化
```yaml
# 没有配置 volumes
```
- **数据位置**: 容器内部
- **持久化**: ❌ 重启后数据丢失
- **管理**: 无法管理

## 🔍 当前环境数据状态

### 测试环境数据持久化
```bash
# 数据库数据
- 位置: mysql_test_data 命名卷
- 持久化: ✅ 重启后保留
- 管理: docker volume ls

# 上传文件
- 位置: ./enterprise-backend/uploads_test/
- 持久化: ✅ 重启后保留
- 管理: 直接操作文件

# 日志文件
- 位置: ./enterprise-backend/logs/
- 持久化: ✅ 重启后保留
- 管理: 直接操作文件
```

### 开发环境数据持久化
```bash
# 数据库数据
- 位置: mysql_dev_data 命名卷
- 持久化: ✅ 重启后保留
- 管理: docker volume ls

# 上传文件
- 位置: ./enterprise-backend/uploads_dev/
- 持久化: ✅ 重启后保留
- 管理: 直接操作文件
```

## 🛠️ 数据管理命令

### 查看数据卷
```bash
# 列出所有数据卷
docker volume ls

# 查看特定数据卷详情
docker volume inspect mysql_test_data
docker volume inspect mysql_dev_data
```

### 备份数据
```bash
# 备份数据库
docker exec enterprise_mysql_test mysqldump -u test_user -p test_password enterprise_test > backup_test_$(date +%Y%m%d).sql

# 备份上传文件
tar -czf uploads_test_backup_$(date +%Y%m%d).tar.gz enterprise-backend/uploads_test/

# 备份日志文件
tar -czf logs_test_backup_$(date +%Y%m%d).tar.gz enterprise-backend/logs/
```

### 恢复数据
```bash
# 恢复数据库
docker exec -i enterprise_mysql_test mysql -u test_user -p test_password enterprise_test < backup_test_20241201.sql

# 恢复上传文件
tar -xzf uploads_test_backup_20241201.tar.gz

# 恢复日志文件
tar -xzf logs_test_backup_20241201.tar.gz
```

### 清理数据
```bash
# 删除数据卷（谨慎操作）
docker volume rm mysql_test_data

# 删除上传文件
rm -rf enterprise-backend/uploads_test/*

# 删除日志文件
rm -rf enterprise-backend/logs/*
```

## 🔄 环境间数据同步

### 从开发环境同步到测试环境
```bash
# 1. 备份开发环境数据
docker exec enterprise_mysql_dev mysqldump -u dev_user -p dev_password enterprise_dev > dev_data.sql

# 2. 恢复测试环境数据
docker exec -i enterprise_mysql_test mysql -u test_user -p test_password enterprise_test < dev_data.sql

# 3. 同步上传文件
rsync -avz enterprise-backend/uploads_dev/ enterprise-backend/uploads_test/
```

### 从测试环境同步到开发环境
```bash
# 1. 备份测试环境数据
docker exec enterprise_mysql_test mysqldump -u test_user -p test_password enterprise_test > test_data.sql

# 2. 恢复开发环境数据
docker exec -i enterprise_mysql_dev mysql -u dev_user -p dev_password enterprise_dev < test_data.sql

# 3. 同步上传文件
rsync -avz enterprise-backend/uploads_test/ enterprise-backend/uploads_dev/
```

## 📋 数据持久化检查清单

### 启动环境前检查
```bash
# 1. 检查数据卷是否存在
docker volume ls | grep mysql

# 2. 检查上传目录是否存在
ls -la enterprise-backend/uploads_test/
ls -la enterprise-backend/uploads_dev/

# 3. 检查日志目录是否存在
ls -la enterprise-backend/logs/
```

### 启动环境后检查
```bash
# 1. 检查数据库连接
docker exec enterprise_mysql_test mysql -u test_user -p -e "SHOW DATABASES;"

# 2. 检查数据是否保留
docker exec enterprise_mysql_test mysql -u test_user -p enterprise_test -e "SELECT COUNT(*) FROM company_info;"

# 3. 检查上传文件
ls -la enterprise-backend/uploads_test/

# 4. 检查日志文件
ls -la enterprise-backend/logs/
```

## ⚠️ 注意事项

### 1. 数据卷管理
```bash
# 查看数据卷使用情况
docker system df -v

# 清理未使用的数据卷
docker volume prune
```

### 2. 磁盘空间管理
```bash
# 查看磁盘使用情况
df -h

# 查看Docker使用情况
docker system df
```

### 3. 备份策略
```bash
# 创建自动备份脚本
nano backup-docker.sh
```

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/enterprise"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份测试环境数据库
docker exec enterprise_mysql_test mysqldump -u test_user -p test_password enterprise_test > $BACKUP_DIR/test_db_$DATE.sql

# 备份开发环境数据库
docker exec enterprise_mysql_dev mysqldump -u dev_user -p dev_password enterprise_dev > $BACKUP_DIR/dev_db_$DATE.sql

# 备份上传文件
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz enterprise-backend/uploads_*/

# 压缩数据库备份
gzip $BACKUP_DIR/test_db_$DATE.sql
gzip $BACKUP_DIR/dev_db_$DATE.sql

# 删除7天前的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

```bash
chmod +x backup-docker.sh
```

## 🎯 最佳实践

### 1. 定期备份
```bash
# 添加到 crontab
0 2 * * * /var/www/enterprise/backup-docker.sh
```

### 2. 环境隔离
- 开发环境和测试环境使用不同的数据卷
- 避免环境间数据污染
- 定期清理测试数据

### 3. 监控数据增长
```bash
# 监控数据卷大小
docker volume inspect mysql_test_data | grep Size

# 监控上传文件大小
du -sh enterprise-backend/uploads_test/
du -sh enterprise-backend/uploads_dev/
```

### 4. 数据迁移
```bash
# 从本地迁移到Docker
mysqldump -u local_user -p enterprise_local > local_data.sql
docker exec -i enterprise_mysql_test mysql -u test_user -p test_password enterprise_test < local_data.sql
```

## 🔍 故障排除

### 1. 数据丢失问题
```bash
# 检查数据卷状态
docker volume inspect mysql_test_data

# 检查容器状态
docker ps -a | grep mysql

# 查看容器日志
docker logs enterprise_mysql_test
```

### 2. 磁盘空间不足
```bash
# 清理Docker资源
docker system prune -a

# 清理日志文件
find enterprise-backend/logs/ -name "*.log" -mtime +7 -delete
```

### 3. 权限问题
```bash
# 修复文件权限
sudo chown -R $USER:$USER enterprise-backend/uploads_*/
sudo chown -R $USER:$USER enterprise-backend/logs/
```

---

**总结**: 你的Docker配置已经正确设置了数据持久化，重启后数据会保留。开发环境和测试环境的数据是隔离的，各自独立管理。 