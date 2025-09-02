# Docker 环境 GitLab CI/CD 指南

## 🐳 Docker 环境的优势

使用Docker环境进行CI/CD有以下优势：

1. **环境一致性**: 开发、测试、生产环境完全一致
2. **快速部署**: 容器化部署比传统部署更快
3. **易于扩展**: 可以轻松添加新服务（如Redis、Elasticsearch等）
4. **隔离性好**: 不同环境使用不同的容器网络
5. **回滚简单**: 可以快速回滚到之前的镜像版本

## 📋 环境配置

### 端口分配

| 环境 | MySQL | 后端API | 前端 | Nginx | 说明 |
|------|-------|---------|------|-------|------|
| 开发 | 3308 | 8002 | 3002 | 8080 | 开发环境 |
| 测试 | 3307 | 8001 | 3001 | 8080 | 测试环境 |
| 生产 | 3309 | 8000 | 3000 | 80/443 | 生产环境 |

### 数据库配置

| 环境 | 数据库名 | 用户名 | 密码 |
|------|----------|--------|------|
| 开发 | enterprise_dev | dev_user | dev_password |
| 测试 | enterprise_test | test_user | test_password |
| 生产 | enterprise_pro | prod_user | prod_password |

## 🚀 快速开始

### 第一步：准备 GitLab 项目

1. **创建 GitLab 项目**
   ```bash
   # 在 GitLab 中创建新项目
   # 项目名称：enterprise-website-docker
   ```

2. **推送现有代码**
   ```bash
   git remote add gitlab <your-gitlab-repo-url>
   git push -u gitlab main
   git checkout -b develop
   git push -u gitlab develop
   ```

### 第二步：配置 GitLab 变量

在 GitLab 项目设置 → CI/CD → Variables 中添加：

#### 开发环境变量
```
DEV_SSH_HOST=your-dev-server-ip
DEV_SSH_USER=your-ssh-user
DEV_PROJECT_PATH=/var/www/enterprise
```

#### 测试环境变量
```
TEST_SSH_HOST=your-test-server-ip
TEST_SSH_USER=your-ssh-user
TEST_PROJECT_PATH=/var/www/enterprise
```

#### 生产环境变量
```
PROD_SSH_HOST=your-prod-server-ip
PROD_SSH_USER=your-ssh-user
PROD_PROJECT_PATH=/var/www/enterprise
PROD_DOMAIN=yourdomain.com
MYSQL_ROOT_PASSWORD=your-root-password
MYSQL_USER=prod_user
MYSQL_PASSWORD=prod_password
SECRET_KEY=your-production-secret-key
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

#### SSH 配置
```
SSH_PRIVATE_KEY=你的SSH私钥内容
SSH_KNOWN_HOSTS=你的服务器SSH公钥指纹
```

### 第三步：服务器准备

#### 安装 Docker 和 Docker Compose
```bash
# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 重启 shell 或重新登录
newgrp docker
```

#### 创建项目目录
```bash
# 创建项目目录
sudo mkdir -p /var/www/enterprise
sudo chown -R $USER:$USER /var/www/enterprise

# 克隆项目
cd /var/www/enterprise
git clone <your-gitlab-repo-url> .
```

### 第四步：配置 Nginx

#### 开发环境 Nginx 配置
```bash
sudo nano /var/www/enterprise/nginx/nginx.dev.conf
```

```nginx
events {
    worker_connections 1024;
}

http {
    upstream backend_dev {
        server backend_dev:8000;
    }

    upstream frontend_dev {
        server frontend_dev:80;
    }

    server {
        listen 80;
        server_name dev.yourdomain.com;

        # 前端静态文件
        location / {
            proxy_pass http://frontend_dev;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # API代理
        location /api/ {
            proxy_pass http://backend_dev;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # 上传文件代理
        location /uploads/ {
            proxy_pass http://backend_dev;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

#### 生产环境 Nginx 配置
```bash
sudo nano /var/www/enterprise/nginx/nginx.prod.conf
```

```nginx
events {
    worker_connections 1024;
}

http {
    upstream backend_prod {
        server backend_prod:8000;
    }

    upstream frontend_prod {
        server frontend_prod:80;
    }

    server {
        listen 80;
        server_name yourdomain.com www.yourdomain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name yourdomain.com www.yourdomain.com;

        ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

        # 前端静态文件
        location / {
            proxy_pass http://frontend_prod;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # API代理
        location /api/ {
            proxy_pass http://backend_prod;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # 上传文件代理
        location /uploads/ {
            proxy_pass http://backend_prod;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### 第五步：创建环境变量文件

#### 生产环境变量文件
```bash
sudo nano /var/www/enterprise/.env.prod
```

```env
MYSQL_ROOT_PASSWORD=your-root-password
MYSQL_USER=prod_user
MYSQL_PASSWORD=prod_password
SECRET_KEY=your-production-secret-key
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### 第六步：测试 Docker 环境

#### 启动测试环境
```bash
cd /var/www/enterprise
docker-compose -f docker-compose.test.yml up -d
```

#### 检查服务状态
```bash
# 查看所有容器
docker ps

# 查看容器日志
docker logs enterprise_backend_test
docker logs enterprise_frontend_test
docker logs enterprise_nginx_test

# 测试健康检查
curl http://localhost:8001/api/health
curl http://localhost:3001
```

## 🔄 CI/CD 流程

### 开发流程

1. **创建功能分支**
   ```bash
   git checkout -b feature/new-feature
   ```

2. **开发完成后提交**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/new-feature
   ```

3. **创建合并请求**
   - 在 GitLab 中创建从 `feature/new-feature` 到 `develop` 的合并请求
   - 自动触发 Docker 测试
   - 通过测试后合并到 `develop` 分支

4. **自动部署到开发环境**
   - 合并到 `develop` 分支后自动部署到开发环境
   - 可以在 `http://dev.yourdomain.com:8080` 查看效果

### 测试流程

1. **开发环境测试通过后**
   - 在 GitLab 中手动触发测试环境部署
   - 部署到 `http://test.yourdomain.com:8080`

2. **测试环境验证**
   - 进行完整的集成测试
   - 验证所有功能正常

### 生产部署流程

1. **创建生产合并请求**
   - 从 `develop` 分支创建到 `main` 分支的合并请求
   - 进行代码审查

2. **手动部署到生产环境**
   - 合并到 `main` 分支后
   - 在 GitLab CI/CD 界面手动触发生产环境部署
   - 自动备份数据库
   - 部署到 `https://yourdomain.com`

## 🛠️ 常用 Docker 命令

### 环境管理
```bash
# 启动开发环境
docker-compose -f docker-compose.dev.yml up -d

# 启动测试环境
docker-compose -f docker-compose.test.yml up -d

# 启动生产环境
docker-compose -f docker-compose.prod.yml up -d

# 停止环境
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.test.yml down
docker-compose -f docker-compose.prod.yml down

# 查看日志
docker-compose -f docker-compose.test.yml logs -f backend_test
```

### 数据库管理
```bash
# 进入数据库容器
docker exec -it enterprise_mysql_test mysql -u test_user -p

# 备份数据库
docker exec enterprise_mysql_test mysqldump -u test_user -p test_password enterprise_test > backup.sql

# 恢复数据库
docker exec -i enterprise_mysql_test mysql -u test_user -p test_password enterprise_test < backup.sql
```

### 镜像管理
```bash
# 构建镜像
docker build -t enterprise-backend:latest ./enterprise-backend
docker build -t enterprise-frontend:latest ./enterprise-frontend

# 查看镜像
docker images

# 清理镜像
docker image prune -f
docker system prune -f
```

## 📊 监控和维护

### 容器监控
```bash
# 查看容器资源使用
docker stats

# 查看容器日志
docker logs -f enterprise_backend_test

# 进入容器
docker exec -it enterprise_backend_test bash
```

### 日志管理
```bash
# 查看所有容器日志
docker-compose -f docker-compose.test.yml logs

# 查看特定服务日志
docker-compose -f docker-compose.test.yml logs backend_test

# 实时查看日志
docker-compose -f docker-compose.test.yml logs -f
```

### 备份策略
```bash
# 创建备份脚本
nano backup-docker.sh
```

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/enterprise"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据库
docker exec enterprise_mysql_prod mysqldump -u prod_user -p$MYSQL_PASSWORD enterprise_pro > $BACKUP_DIR/production_backup_$DATE.sql

# 备份上传文件
tar -czf $BACKUP_DIR/uploads_backup_$DATE.tar.gz enterprise-backend/uploads_prod/

# 压缩备份文件
gzip $BACKUP_DIR/production_backup_$DATE.sql

# 删除7天前的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: production_backup_$DATE.sql.gz, uploads_backup_$DATE.tar.gz"
```

```bash
chmod +x backup-docker.sh
```

## 🔧 故障排除

### 常见问题

#### 1. 容器启动失败
```bash
# 查看容器状态
docker ps -a

# 查看容器日志
docker logs enterprise_backend_test

# 重新构建镜像
docker-compose -f docker-compose.test.yml build --no-cache
```

#### 2. 数据库连接失败
```bash
# 检查数据库容器
docker exec -it enterprise_mysql_test mysql -u test_user -p

# 检查网络连接
docker network ls
docker network inspect enterprise_test_network
```

#### 3. 端口冲突
```bash
# 查看端口占用
netstat -tlnp | grep :8001

# 修改端口映射
# 在 docker-compose.yml 中修改 ports 配置
```

#### 4. 磁盘空间不足
```bash
# 清理 Docker 资源
docker system prune -a

# 查看磁盘使用
df -h
docker system df
```

### 性能优化

#### 1. 镜像优化
```dockerfile
# 使用多阶段构建
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
WORKDIR /app
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### 2. 资源限制
```yaml
# 在 docker-compose.yml 中添加资源限制
services:
  backend_test:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

## 🎯 最佳实践

### 1. 镜像管理
- 使用语义化版本标签
- 定期清理旧镜像
- 使用多阶段构建优化镜像大小

### 2. 数据持久化
- 使用 Docker volumes 持久化数据
- 定期备份数据库和上传文件
- 使用外部存储服务（如AWS S3）

### 3. 安全考虑
- 使用非 root 用户运行容器
- 定期更新基础镜像
- 扫描镜像安全漏洞

### 4. 监控告警
- 设置容器健康检查
- 监控容器资源使用
- 配置日志聚合和分析

---

**Docker 环境为你的 CI/CD 流程提供了更好的隔离性和一致性，同时简化了部署和维护工作。** 