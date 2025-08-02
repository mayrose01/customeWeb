# 企业网站部署策略

## 当前部署方案

### 生产环境配置
- **服务器**: 阿里云CentOS 8
- **IP**: 47.243.41.30
- **域名**: https://catusfoto.top
- **部署方式**: Systemd + Nginx + MySQL

### 架构说明
```
生产环境:
├── 前端: Nginx静态文件 (/var/www/enterprise-frontend/)
├── 后端: FastAPI + Uvicorn (systemd服务)
├── 数据库: MySQL/MariaDB
└── 反向代理: Nginx
```

## 部署方案对比

### 方案1: 当前Systemd部署 (推荐)
**优点:**
- 资源占用少，适合小内存服务器
- 启动速度快
- 配置简单，易于维护
- 与现有架构兼容

**缺点:**
- 需要手动管理依赖
- 前端构建可能遇到内存不足问题

### 方案2: Docker化部署
**优点:**
- 环境隔离，一致性好
- 易于扩展和迁移
- 自动化程度高

**缺点:**
- 资源占用较大
- 小内存服务器可能不适合
- 需要额外的Docker学习成本

### 方案3: 混合部署 (当前采用)
**优点:**
- 结合两种方案的优势
- 本地构建前端，避免服务器资源不足
- 后端使用systemd，资源占用少
- 提供Docker验证环境

## 自动化部署脚本

### 1. 完整自动化部署
```bash
./automated-deploy.sh
```
**功能:**
- 从GitHub拉取最新代码
- 本地构建前端（避免服务器内存不足）
- 上传构建文件到服务器
- 更新后端代码和依赖
- 重启所有服务
- 检查服务状态

### 2. 仅更新代码
```bash
./update_production.sh
```
**功能:**
- 在服务器上直接更新代码
- 更新后端依赖
- 重启服务

### 3. 仅构建前端
```bash
./local-build-upload.sh
```
**功能:**
- 本地构建前端
- 上传到服务器

## Docker验证环境

### 启动验证环境
```bash
./docker-test-env.sh start
```

### 停止验证环境
```bash
./docker-test-env.sh stop
```

### 查看状态
```bash
./docker-test-env.sh status
```

### 查看日志
```bash
./docker-test-env.sh logs
```

## 部署流程

### 日常更新流程
1. **开发阶段**: 在本地进行开发和测试
2. **验证阶段**: 使用Docker验证环境测试
3. **部署阶段**: 运行 `./automated-deploy.sh`
4. **验证阶段**: 检查生产环境是否正常

### 紧急修复流程
1. **快速修复**: 直接修改代码并提交
2. **快速部署**: 运行 `./update_production.sh`
3. **验证**: 检查服务状态

## 监控和维护

### 服务状态检查
```bash
# 检查后端服务
ssh root@47.243.41.30 "systemctl status enterprise-backend"

# 检查Nginx服务
ssh root@47.243.41.30 "systemctl status nginx"

# 检查MySQL服务
ssh root@47.243.41.30 "systemctl status mysql"
```

### 日志查看
```bash
# 后端日志
ssh root@47.243.41.30 "journalctl -u enterprise-backend -f"

# Nginx日志
ssh root@47.243.41.30 "tail -f /var/log/nginx/access.log"
```

### 备份和恢复
```bash
# 备份代码
ssh root@47.243.41.30 "cd /var/www/enterprise && tar -czf backup-$(date +%Y%m%d).tar.gz ."

# 恢复代码
ssh root@47.243.41.30 "cd /var/www/enterprise && tar -xzf backup-YYYYMMDD.tar.gz"
```

## 性能优化建议

### 前端优化
- 使用本地构建，避免服务器内存不足
- 启用Gzip压缩
- 使用CDN加速静态资源

### 后端优化
- 使用Uvicorn多进程
- 启用数据库连接池
- 配置适当的缓存策略

### 服务器优化
- 定期清理日志文件
- 监控磁盘空间使用
- 配置适当的防火墙规则

## 故障排除

### 常见问题

1. **前端构建失败**
   - 原因: 服务器内存不足
   - 解决: 使用本地构建上传方案

2. **后端启动失败**
   - 原因: 数据库连接问题
   - 解决: 检查数据库配置和连接

3. **Nginx配置错误**
   - 原因: 配置文件语法错误
   - 解决: 检查nginx.conf配置

### 回滚方案
```bash
# 回滚到备份
ssh root@47.243.41.30 "cd /var/www/enterprise && cp -r backup/* . && systemctl restart enterprise-backend"
```

## 总结

当前采用**混合部署方案**是最佳选择：

1. **生产环境**: Systemd + Nginx + MySQL (资源占用少)
2. **构建环境**: 本地构建前端 (避免服务器资源不足)
3. **验证环境**: Docker容器 (环境一致性)
4. **自动化**: 完整的部署脚本 (减少人工操作)

这种方案既保证了生产环境的稳定性，又提供了灵活的开发和验证环境。 