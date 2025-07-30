# 企业管理系统测试环境

## 🎯 概述

这是一个独立于开发环境的完整测试环境，用于进行功能测试、集成测试和性能测试。测试环境与开发环境完全隔离，使用独立的数据库、端口和文件存储。

## 🚀 快速开始

### 启动测试环境
```bash
./start_test_env.sh
```

### 停止测试环境
```bash
./stop_test_env.sh
```

### 检查测试环境状态
```bash
./test_env_check.sh
```

## 📋 访问信息

| 服务 | URL | 端口 | 说明 |
|------|-----|------|------|
| 前端应用 | http://localhost:3001 | 3001 | Vue.js 前端应用 |
| 后端API | http://localhost:8001 | 8001 | FastAPI 后端服务 |
| Nginx代理 | http://localhost:8080 | 8080 | 反向代理服务器 |
| MySQL数据库 | localhost:3307 | 3307 | 测试数据库 |

## 🗄️ 数据库信息

- **数据库名**: `enterprise_test_db`
- **用户名**: `test_user`
- **密码**: `test_password`
- **端口**: `3307`

## 📁 文件结构

```
enterprise/
├── docker-compose.test.yml          # 测试环境Docker配置
├── start_test_env.sh               # 启动脚本
├── stop_test_env.sh                # 停止脚本
├── test_env_check.sh               # 状态检查脚本
├── test_env_manual.md              # 详细使用手册
├── enterprise-backend/
│   ├── test.env                    # 测试环境配置
│   ├── uploads_test/               # 测试环境上传目录
│   └── logs/app_test.log           # 测试环境日志
└── nginx/
    └── nginx.test.conf             # 测试环境Nginx配置
```

## 🔧 环境差异

| 特性 | 开发环境 | 测试环境 |
|------|----------|----------|
| 数据库 | `enterprise` | `enterprise_test_db` |
| 前端端口 | `3000` | `3001` |
| 后端端口 | `8000` | `8001` |
| MySQL端口 | `3306` | `3307` |
| 上传目录 | `uploads` | `uploads_test` |
| 日志级别 | `INFO` | `DEBUG` |
| 日志文件 | `app.log` | `app_test.log` |
| 容器名称 | `enterprise_*` | `enterprise_*_test` |

## 📊 管理命令

### Docker Compose 命令
```bash
# 查看服务状态
docker-compose -f docker-compose.test.yml ps

# 查看日志
docker-compose -f docker-compose.test.yml logs -f

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

## 🧪 测试建议

### 功能测试
- 用户注册、登录、权限管理
- 产品管理、分类管理
- 文件上传、图片处理
- 邮件发送功能

### 集成测试
- 前后端API交互
- 数据库操作
- 文件上传和下载
- 邮件发送集成

### 性能测试
- 并发用户访问
- 数据库查询性能
- 文件上传性能
- API响应时间

### 安全测试
- 用户认证和授权
- SQL注入防护
- XSS攻击防护
- 文件上传安全

## 🔍 故障排除

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

## 📝 注意事项

1. **数据隔离**: 测试环境使用独立的数据库，不会影响开发环境的数据
2. **端口隔离**: 使用不同的端口避免与开发环境冲突
3. **文件隔离**: 上传文件存储在独立的目录中
4. **日志隔离**: 使用独立的日志文件便于调试
5. **网络隔离**: 使用独立的Docker网络

## 📚 相关文档

- [测试环境使用手册](test_env_manual.md) - 详细的使用说明
- [部署指南](DEPLOYMENT_GUIDE.md) - 生产环境部署说明
- [开发环境README](README.md) - 开发环境说明

## 🆘 支持

如果在使用测试环境时遇到问题：

1. 运行 `./test_env_check.sh` 检查环境状态
2. 查看相关日志文件
3. 检查Docker容器状态
4. 验证网络连接
5. 确认配置文件正确性 