# 测试环境使用手册

## 概述

测试环境是一个独立于开发环境的完整系统，用于进行功能测试、集成测试和性能测试。它与开发环境完全隔离，使用独立的数据库、端口和文件存储。

## 环境配置

### 端口分配
- **前端应用**: http://localhost:3001
- **后端API**: http://localhost:8001
- **Nginx代理**: http://localhost:8080
- **MySQL数据库**: localhost:3307

### 数据库配置
- **数据库名**: enterprise_test_db
- **用户名**: test_user
- **密码**: test_password
- **端口**: 3307

### 文件存储
- **上传目录**: enterprise-backend/uploads_test
- **日志文件**: enterprise-backend/logs/app_test.log

## 快速开始

### 1. 启动测试环境
```bash
# 给脚本执行权限
chmod +x start_test_env.sh
chmod +x stop_test_env.sh

# 启动测试环境
./start_test_env.sh
```

### 2. 访问应用
- 前端应用: http://localhost:3001
- 后端API: http://localhost:8001
- Nginx代理: http://localhost:8080

### 3. 停止测试环境
```bash
./stop_test_env.sh
```

## 管理命令

### Docker Compose 命令
```bash
# 查看服务状态
docker-compose -f docker-compose.test.yml ps

# 查看日志
docker-compose -f docker-compose.test.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose.test.yml logs -f backend_test

# 重启服务
docker-compose -f docker-compose.test.yml restart

# 停止服务
docker-compose -f docker-compose.test.yml down

# 重新构建并启动
docker-compose -f docker-compose.test.yml up --build -d
```

### 数据库管理
```bash
# 连接到测试数据库
mysql -h localhost -P 3307 -u test_user -p enterprise_test_db

# 备份测试数据库
docker exec enterprise_mysql_test mysqldump -u test_user -ptest_password enterprise_test_db > test_backup.sql

# 恢复测试数据库
docker exec -i enterprise_mysql_test mysql -u test_user -ptest_password enterprise_test_db < test_backup.sql
```

## 测试环境与开发环境的区别

| 特性 | 开发环境 | 测试环境 |
|------|----------|----------|
| 数据库 | enterprise | enterprise_test_db |
| 前端端口 | 3000 | 3001 |
| 后端端口 | 8000 | 8001 |
| MySQL端口 | 3306 | 3307 |
| 上传目录 | uploads | uploads_test |
| 日志级别 | INFO | DEBUG |
| 日志文件 | app.log | app_test.log |
| 容器名称 | enterprise_* | enterprise_*_test |

## 测试建议

### 1. 功能测试
- 在测试环境中验证所有功能模块
- 测试用户注册、登录、权限管理
- 测试产品管理、分类管理
- 测试文件上传、图片处理
- 测试邮件发送功能

### 2. 集成测试
- 测试前后端API交互
- 测试数据库操作
- 测试文件上传和下载
- 测试邮件发送集成

### 3. 性能测试
- 测试并发用户访问
- 测试数据库查询性能
- 测试文件上传性能
- 测试API响应时间

### 4. 安全测试
- 测试用户认证和授权
- 测试SQL注入防护
- 测试XSS攻击防护
- 测试文件上传安全

## 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 检查端口占用
   lsof -i :3001
   lsof -i :8001
   lsof -i :3307
   
   # 停止占用端口的进程
   sudo kill -9 <PID>
   ```

2. **数据库连接失败**
   ```bash
   # 检查MySQL容器状态
   docker ps | grep mysql_test
   
   # 查看MySQL日志
   docker logs enterprise_mysql_test
   ```

3. **服务启动失败**
   ```bash
   # 查看所有服务日志
   docker-compose -f docker-compose.test.yml logs
   
   # 重新构建镜像
   docker-compose -f docker-compose.test.yml build --no-cache
   ```

4. **文件权限问题**
   ```bash
   # 修复文件权限
   sudo chown -R $USER:$USER enterprise-backend/uploads_test
   sudo chmod -R 755 enterprise-backend/uploads_test
   ```

## 数据管理

### 初始化测试数据
```bash
# 连接到测试数据库
mysql -h localhost -P 3307 -u test_user -p enterprise_test_db

# 执行初始化SQL
source mysql/init.sql
```

### 备份和恢复
```bash
# 备份测试数据
docker exec enterprise_mysql_test mysqldump -u test_user -ptest_password enterprise_test_db > test_data_backup.sql

# 恢复测试数据
docker exec -i enterprise_mysql_test mysql -u test_user -ptest_password enterprise_test_db < test_data_backup.sql
```

## 监控和日志

### 查看实时日志
```bash
# 查看所有服务日志
docker-compose -f docker-compose.test.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose.test.yml logs -f backend_test
docker-compose -f docker-compose.test.yml logs -f frontend_test
docker-compose -f docker-compose.test.yml logs -f nginx_test
```

### 查看应用日志
```bash
# 查看后端应用日志
tail -f enterprise-backend/logs/app_test.log

# 查看Nginx访问日志
docker exec enterprise_nginx_test tail -f /var/log/nginx/access.log
```

## 环境清理

### 完全清理测试环境
```bash
# 停止所有服务
docker-compose -f docker-compose.test.yml down -v

# 删除测试数据卷
docker volume rm enterprise_mysql_test_data

# 删除测试上传文件
rm -rf enterprise-backend/uploads_test/*

# 删除测试日志
rm -f enterprise-backend/logs/app_test.log
```

## 注意事项

1. **数据隔离**: 测试环境使用独立的数据库，不会影响开发环境的数据
2. **端口隔离**: 使用不同的端口避免与开发环境冲突
3. **文件隔离**: 上传文件存储在独立的目录中
4. **日志隔离**: 使用独立的日志文件便于调试
5. **网络隔离**: 使用独立的Docker网络

## 联系支持

如果在使用测试环境时遇到问题，请：
1. 查看相关日志文件
2. 检查Docker容器状态
3. 验证网络连接
4. 确认配置文件正确性 