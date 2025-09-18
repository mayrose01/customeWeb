# Docker 部署指南

## 📋 概述

本指南说明如何使用Docker进行企业官网项目的部署，支持开发、测试、生产三个环境的统一管理。

## 🏗️ 架构设计

### 统一Dockerfile
- **后端**: `enterprise-backend/Dockerfile` - 适用于所有环境
- **前端**: `enterprise-frontend/Dockerfile` - 适用于所有环境

### 分层Compose配置
- **基础配置**: `docker-compose.yml` - 定义所有环境共有的服务结构
- **开发环境**: `docker-compose.dev.yml` - 开发环境覆盖配置
- **测试环境**: `docker-compose.test.yml` - 测试环境覆盖配置
- **生产环境**: `docker-compose.prod.yml` - 生产环境覆盖配置

## 🚀 快速开始

### 1. 环境变量设置

```bash
# 设置开发环境变量
source ./set_env.sh dev

# 设置测试环境变量
source ./set_env.sh test

# 设置生产环境变量（需要先设置PROD_*变量）
export PROD_DATABASE_URL="mysql+pymysql://user:password@host:port/database"
export PROD_SECRET_KEY="your-production-secret-key"
source ./set_env.sh prod
```

### 2. 部署操作

```bash
# 开发环境
./deploy.sh dev up        # 启动开发环境
./deploy.sh dev build     # 构建开发环境镜像
./deploy.sh dev logs      # 查看开发环境日志

# 测试环境
./deploy.sh test up       # 启动测试环境
./deploy.sh test build    # 构建测试环境镜像
./deploy.sh test status   # 查看测试环境状态

# 生产环境
./deploy.sh prod up       # 启动生产环境
./deploy.sh prod build    # 构建生产环境镜像
./deploy.sh prod restart  # 重启生产环境
```

## 🔧 环境配置详解

### 开发环境 (dev)
- **端口映射**: 数据库(3308), 后端(8002), 前端(3002), Nginx(8080)
- **代码挂载**: 支持热更新，代码修改后自动生效
- **调试模式**: 启用DEBUG日志级别
- **单Worker**: 便于调试和开发

### 测试环境 (test)
- **端口映射**: 数据库(3307), 后端(8001), 前端(3001), Nginx(8080)
- **代码挂载**: 支持热更新，便于测试
- **测试数据**: 使用独立的测试数据库
- **双Worker**: 平衡性能和资源使用

### 生产环境 (prod)
- **端口映射**: 数据库(3306), 后端(8000), 前端(3000), Nginx(80/443)
- **无代码挂载**: 使用构建的镜像，确保一致性
- **资源限制**: 配置CPU和内存限制
- **多Worker**: 使用8个Worker进程，提高性能
- **健康检查**: 自动监控服务状态

## 📦 镜像构建

### 后端镜像特点
- 基于Python 3.11-slim
- 包含MySQL客户端库
- 非root用户运行（安全）
- 内置健康检查
- 支持环境变量配置Worker数量

### 前端镜像特点
- 多阶段构建（构建+生产）
- 基于Node.js 18 Alpine
- 使用Nginx Alpine作为生产服务器
- 非root用户运行（安全）
- 内置健康检查

## 🔒 安全特性

### 容器安全
- 所有服务使用非root用户运行
- 最小化镜像大小
- 定期更新基础镜像
- 健康检查监控

### 网络安全
- 自定义网络隔离
- 内部服务通信
- 端口映射控制
- SSL/TLS支持

### 数据安全
- 数据卷持久化
- 环境变量注入敏感信息
- 不包含硬编码密码
- 生产环境资源限制

## 📊 监控和日志

### 健康检查
```bash
# 检查服务状态
./deploy.sh [env] status

# 查看服务日志
./deploy.sh [env] logs
```

### 日志管理
- 后端日志: `backend_logs` 数据卷
- Nginx日志: `nginx_logs` 数据卷
- 数据库日志: 容器内部日志

## 🔄 部署流程

### 开发环境部署
```bash
# 1. 设置环境变量
source ./set_env.sh dev

# 2. 启动服务
./deploy.sh dev up

# 3. 查看状态
./deploy.sh dev status
```

### 测试环境部署
```bash
# 1. 设置环境变量
source ./set_env.sh test

# 2. 构建镜像
./deploy.sh test build

# 3. 启动服务
./deploy.sh test up

# 4. 运行测试
# 测试完成后停止服务
./deploy.sh test down
```

### 生产环境部署
```bash
# 1. 设置生产环境变量
export PROD_DATABASE_URL="mysql+pymysql://user:password@host:port/database"
export PROD_SECRET_KEY="your-production-secret-key"
export PROD_MYSQL_ROOT_PASSWORD="your-mysql-root-password"
export PROD_MYSQL_PASSWORD="your-mysql-password"
export PROD_VITE_API_BASE_URL="https://yourdomain.com/api"

# 2. 设置环境变量
source ./set_env.sh prod

# 3. 构建生产镜像
./deploy.sh prod build

# 4. 启动生产服务（自动运行数据库迁移）
./deploy.sh prod up

# 5. 检查服务状态
./deploy.sh prod status

# 6. 检查数据库迁移状态
./deploy.sh prod migrate-check
```

## 🛠️ 故障排除

### 常见问题

#### 1. 服务启动失败
```bash
# 检查环境变量
./check_environment_config.sh

# 查看详细日志
./deploy.sh [env] logs
```

#### 2. 数据库连接失败
```bash
# 检查数据库服务状态
docker-compose -f docker-compose.yml -f docker-compose.[env].yml ps mysql

# 查看数据库日志
docker-compose -f docker-compose.yml -f docker-compose.[env].yml logs mysql
```

#### 3. 前端无法访问后端
```bash
# 检查网络连接
docker network ls
docker network inspect enterprise_enterprise_network

# 检查服务间通信
docker exec -it enterprise_backend_[env] curl http://mysql:3306
```

### 清理操作
```bash
# 停止并删除容器
./deploy.sh [env] down

# 删除镜像
docker rmi enterprise-backend_backend enterprise-frontend_frontend

# 清理数据卷（谨慎操作）
docker volume prune
```

## 📈 性能优化

### 生产环境优化
- 使用多Worker进程
- 配置资源限制
- 启用健康检查
- 使用数据卷持久化

### 开发环境优化
- 代码热更新
- 单Worker便于调试
- 详细日志输出
- 快速重启

## 📝 数据库迁移

### 自动迁移
部署过程中会自动运行数据库迁移：
1. 启动数据库服务
2. 等待数据库就绪
3. 运行数据库迁移
4. 启动应用服务

### 手动迁移
```bash
# 运行数据库迁移
./deploy.sh [env] migrate

# 检查迁移状态
./deploy.sh [env] migrate-check
```

### 迁移管理
```bash
# 创建新的迁移文件
./migrate.sh [env] create "迁移描述"

# 查看迁移历史
./migrate.sh [env] history

# 查看当前版本
./migrate.sh [env] current
```

## 🔧 自定义配置

### 添加新的环境变量
1. 在 `docker-compose.yml` 中添加环境变量定义
2. 在对应的覆盖文件中设置默认值
3. 在 `set_env.sh` 中添加环境变量设置
4. 更新 `check_environment_config.sh` 检查脚本

### 修改服务配置
1. 在基础 `docker-compose.yml` 中定义服务结构
2. 在环境覆盖文件中修改特定配置
3. 重新构建和部署服务

## 📞 技术支持

如有问题，请参考：
1. 本部署指南
2. Docker官方文档
3. 项目README.md
4. 联系开发团队
