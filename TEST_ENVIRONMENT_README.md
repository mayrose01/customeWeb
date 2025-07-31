# 测试环境说明

## 概述

测试环境是一个独立的运行环境，用于测试新功能、验证修复和进行集成测试。它与开发环境和生产环境完全隔离，确保测试过程不会影响其他环境的数据。

## 环境配置

### 服务端口
- **前端**: `http://localhost:3001`
- **后端API**: `http://localhost:8001`
- **数据库**: `localhost:3307`

### 数据库配置
- **数据库名**: `enterprise_test`
- **用户名**: `test_user`
- **密码**: `test_password`
- **端口**: `3307`

### 环境变量
- **ENV**: `test`
- **DATABASE_URL**: `mysql+pymysql://test_user:test_password@localhost:3307/enterprise_test`

## 启动测试环境

### 方法一：使用Docker Compose（推荐）

```bash
# 启动测试环境
docker-compose -f docker-compose.test.yml up -d

# 查看服务状态
docker-compose -f docker-compose.test.yml ps

# 查看日志
docker-compose -f docker-compose.test.yml logs -f

# 停止测试环境
docker-compose -f docker-compose.test.yml down
```

### 方法二：使用启动脚本

```bash
# 启动测试环境
./start_test_env.sh

# 停止测试环境
./stop_test_env.sh
```

## 数据库管理

### 连接数据库
```bash
mysql -h localhost -P 3307 -u test_user -p enterprise_test
```

### 备份数据库
```bash
docker exec enterprise_mysql_test mysqldump -u test_user -ptest_password enterprise_test > test_backup.sql
```

### 恢复数据库
```bash
docker exec -i enterprise_mysql_test mysql -u test_user -ptest_password enterprise_test < test_backup.sql
```

## 环境对比

| 项目 | 开发环境 | 测试环境 | 说明 |
|------|----------|----------|------|
| 前端端口 | 3000 | 3001 | 避免端口冲突 |
| 后端端口 | 8000 | 8001 | 避免端口冲突 |
| 数据库端口 | 3306 | 3307 | 避免端口冲突 |
| 数据库 | `enterprise` | `enterprise_test` | 数据隔离 |
| 上传目录 | `uploads` | `uploads_test` | 文件隔离 |
| 日志级别 | INFO | DEBUG | 便于调试 |

## 测试数据

测试环境包含以下默认数据：

### 管理员账户
- **用户名**: `admin`
- **密码**: `admin123`
- **邮箱**: `admin@test.com`
- **角色**: `admin`

### 默认内容
- 公司信息
- 轮播图
- 产品分类
- 示例产品
- 联系字段

## 注意事项

1. **数据隔离**: 测试环境使用独立的数据库，不会影响开发或生产环境
2. **端口隔离**: 使用不同的端口避免与开发环境冲突
3. **文件隔离**: 上传文件存储在独立的目录中
4. **定期清理**: 建议定期清理测试数据，保持环境整洁

## 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 检查端口占用
   lsof -i :3001
   lsof -i :8001
   lsof -i :3307
   ```

2. **数据库连接失败**
   ```bash
   # 检查MySQL容器状态
   docker ps | grep mysql
   
   # 查看MySQL日志
   docker logs enterprise_mysql_test
   ```

3. **服务启动失败**
   ```bash
   # 查看服务日志
   docker-compose -f docker-compose.test.yml logs
   ```

### 重置测试环境

```bash
# 停止并删除所有测试容器和数据
docker-compose -f docker-compose.test.yml down -v

# 重新启动
docker-compose -f docker-compose.test.yml up -d
```

## 开发建议

1. **功能测试**: 在测试环境中验证新功能
2. **回归测试**: 确保修改不会破坏现有功能
3. **性能测试**: 在测试环境中进行性能测试
4. **数据验证**: 验证数据迁移和更新脚本 