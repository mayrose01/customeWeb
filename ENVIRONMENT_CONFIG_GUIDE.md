# 环境配置指南

## 🎯 环境配置说明

你的项目现在支持多个环境，每个环境都有独立的数据库和端口配置。这样做是**完全正常且推荐的做法**。

## 📊 环境配置对比

### 1. 本地开发环境
```bash
# 数据库配置
数据库名: enterprise_local (或你本地的数据库名)
用户名: local_user (或你本地的用户名)
密码: local_password (或你本地的密码)
端口: 3306

# 服务端口
后端API: http://localhost:8000
前端: http://localhost:3000
```

### 2. Docker开发环境
```bash
# 数据库配置
数据库名: enterprise_dev
用户名: dev_user
密码: dev_password
端口: 3308 (映射到容器内3306)

# 服务端口
后端API: http://localhost:8002
前端: http://localhost:3002
Nginx: http://localhost:8080
```

### 3. Docker测试环境
```bash
# 数据库配置
数据库名: enterprise_test
用户名: test_user
密码: test_password
端口: 3307 (映射到容器内3306)

# 服务端口
后端API: http://localhost:8001
前端: http://localhost:3001
Nginx: http://localhost:8080
```

### 4. Docker生产环境
```bash
# 数据库配置
数据库名: enterprise_pro
用户名: prod_user
密码: prod_password
端口: 3309 (映射到容器内3306)

# 服务端口
后端API: http://localhost:8000
前端: http://localhost:3000
Nginx: http://localhost:80/443
```

## 🔧 如何切换环境

### 方法1: 使用环境变量
```bash
# 本地开发
export ENVIRONMENT=development
python -m uvicorn app.main:app --reload

# Docker测试环境
export ENVIRONMENT=testing
docker-compose -f docker-compose.test.yml up -d

# Docker生产环境
export ENVIRONMENT=production
docker-compose -f docker-compose.prod.yml up -d
```

### 方法2: 使用配置文件
```bash
# 创建环境配置文件
cp .env.example .env.development
cp .env.example .env.testing
cp .env.example .env.production

# 编辑配置文件
nano .env.development
nano .env.testing
nano .env.production
```

## 📝 环境变量配置示例

### 本地开发环境 (.env.development)
```env
ENVIRONMENT=development
DATABASE_URL=mysql://local_user:local_password@localhost:3306/enterprise_local
SECRET_KEY=dev-secret-key
CORS_ORIGINS=["http://localhost:3000", "http://localhost:5173"]
LOG_LEVEL=DEBUG
```

### Docker测试环境 (.env.testing)
```env
ENVIRONMENT=testing
DATABASE_URL=mysql://test_user:test_password@mysql_test:3306/enterprise_test
SECRET_KEY=test-secret-key
CORS_ORIGINS=["http://localhost:3001", "http://test.yourdomain.com:8080"]
LOG_LEVEL=INFO
```

### Docker生产环境 (.env.production)
```env
ENVIRONMENT=production
DATABASE_URL=mysql://prod_user:prod_password@mysql_prod:3306/enterprise_pro
SECRET_KEY=your-production-secret-key
CORS_ORIGINS=["https://yourdomain.com", "https://www.yourdomain.com"]
LOG_LEVEL=INFO
```

## 🚀 快速启动不同环境

### 本地开发
```bash
cd enterprise-backend
export ENVIRONMENT=development
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Docker测试环境
```bash
cd /var/www/enterprise
docker-compose -f docker-compose.test.yml up -d
```

### Docker开发环境
```bash
cd /var/www/enterprise
docker-compose -f docker-compose.dev.yml up -d
```

### Docker生产环境
```bash
cd /var/www/enterprise
docker-compose -f docker-compose.prod.yml up -d
```

## 🔍 检查环境状态

### 健康检查
```bash
# 本地开发环境
curl http://localhost:8000/api/health

# Docker测试环境
curl http://localhost:8001/api/health

# Docker开发环境
curl http://localhost:8002/api/health

# Docker生产环境
curl https://yourdomain.com/api/health
```

### 环境信息
```bash
# 获取环境信息
curl http://localhost:8000/api/environment
```

## 🛠️ 数据库管理

### 本地数据库操作
```bash
# 连接本地数据库
mysql -u local_user -p enterprise_local

# 备份本地数据库
mysqldump -u local_user -p enterprise_local > backup_local.sql

# 恢复本地数据库
mysql -u local_user -p enterprise_local < backup_local.sql
```

### Docker数据库操作
```bash
# 连接Docker测试数据库
docker exec -it enterprise_mysql_test mysql -u test_user -p

# 备份Docker测试数据库
docker exec enterprise_mysql_test mysqldump -u test_user -p test_password enterprise_test > backup_test.sql

# 恢复Docker测试数据库
docker exec -i enterprise_mysql_test mysql -u test_user -p test_password enterprise_test < backup_test.sql
```

## 🔄 数据同步

### 从本地同步到Docker测试环境
```bash
# 备份本地数据
mysqldump -u local_user -p enterprise_local > local_data.sql

# 导入到Docker测试环境
docker exec -i enterprise_mysql_test mysql -u test_user -p test_password enterprise_test < local_data.sql
```

### 从Docker测试环境同步到本地
```bash
# 备份Docker测试数据
docker exec enterprise_mysql_test mysqldump -u test_user -p test_password enterprise_test > test_data.sql

# 导入到本地
mysql -u local_user -p enterprise_local < test_data.sql
```

## ⚠️ 注意事项

### 1. 端口冲突
- 确保不同环境使用不同的端口
- 本地环境通常使用标准端口 (3306, 8000, 3000)
- Docker环境使用映射端口 (3307-3309, 8001-8002, 3001-3002)

### 2. 数据隔离
- 不同环境的数据完全隔离
- 测试数据不会影响本地开发数据
- 生产数据与开发/测试数据完全分离

### 3. 配置管理
- 敏感信息使用环境变量
- 不同环境使用不同的配置文件
- 生产环境的密码要足够复杂

### 4. 网络访问
- 本地环境只能从本机访问
- Docker环境可以通过网络访问
- 生产环境需要配置域名和SSL

## 🎯 最佳实践

### 1. 开发流程
```bash
# 1. 在本地开发
export ENVIRONMENT=development
python -m uvicorn app.main:app --reload

# 2. 测试Docker环境
docker-compose -f docker-compose.test.yml up -d
curl http://localhost:8001/api/health

# 3. 部署到生产环境
docker-compose -f docker-compose.prod.yml up -d
```

### 2. 数据管理
```bash
# 定期备份数据
mysqldump -u local_user -p enterprise_local > backup_$(date +%Y%m%d).sql

# 清理旧数据
find . -name "backup_*.sql" -mtime +7 -delete
```

### 3. 监控和日志
```bash
# 查看应用日志
tail -f logs/app_dev.log
tail -f logs/app_test.log
tail -f logs/app_prod.log

# 查看Docker日志
docker logs enterprise_backend_test
docker logs enterprise_frontend_test
```

---

**总结**: 不同环境使用不同的数据库名称、密码和端口是**完全正常且推荐的做法**，这样可以确保环境隔离、数据安全和部署可靠性。 