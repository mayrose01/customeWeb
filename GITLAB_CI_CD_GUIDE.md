# GitLab CI/CD 持续集成/持续部署指南

## 概述

本指南将帮助你为现有的企业官网项目配置GitLab CI/CD，实现自动化测试、构建和部署，同时确保不影响现有的开发、测试和生产环境。

## 一、CI/CD 流程设计

### 1. 分支策略
```
main (生产环境)     ← 手动部署到生产环境
develop (开发环境)   ← 自动部署到开发环境
feature/*          ← 功能分支，只进行测试
```

### 2. 环境隔离
- **开发环境 (develop)**: 自动部署，用于功能测试
- **测试环境 (test)**: 手动部署，用于集成测试
- **生产环境 (main)**: 手动部署，需要审批

### 3. 部署流程
```
代码提交 → 自动测试 → 构建 → 部署到对应环境
```

## 二、GitLab 配置步骤

### 1. 创建 GitLab 项目

1. 在 GitLab 中创建新项目
2. 将现有代码推送到 GitLab：
```bash
git remote add gitlab <your-gitlab-repo-url>
git push -u gitlab main
git push -u gitlab develop
```

### 2. 配置 GitLab 变量

在 GitLab 项目设置中配置以下变量：

#### 开发环境变量
```
DEV_SSH_HOST=your-dev-server-ip
DEV_SSH_USER=your-ssh-user
DEV_BACKEND_PATH=/var/www/enterprise/enterprise-backend
DEV_FRONTEND_PATH=/var/www/enterprise/enterprise-frontend
```

#### 测试环境变量
```
TEST_SSH_HOST=your-test-server-ip
TEST_SSH_USER=your-ssh-user
TEST_BACKEND_PATH=/var/www/enterprise/enterprise-backend
TEST_FRONTEND_PATH=/var/www/enterprise/enterprise-frontend
```

#### 生产环境变量
```
PROD_SSH_HOST=your-prod-server-ip
PROD_SSH_USER=your-ssh-user
PROD_BACKEND_PATH=/var/www/enterprise/enterprise-backend
PROD_FRONTEND_PATH=/var/www/enterprise/enterprise-frontend
PROD_DB_HOST=localhost
PROD_MYSQL_USER=enterprise_user
PROD_MYSQL_PASSWORD=your-prod-db-password
PROD_MYSQL_DATABASE=enterprise_pro
```

#### SSH 配置
```
SSH_PRIVATE_KEY=你的SSH私钥内容
SSH_KNOWN_HOSTS=你的服务器SSH公钥指纹
```

### 3. 配置 SSH 密钥

1. 生成 SSH 密钥对：
```bash
ssh-keygen -t rsa -b 4096 -C "gitlab-ci"
```

2. 将公钥添加到服务器：
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub user@your-server
```

3. 在 GitLab 变量中设置私钥：
- 变量名：`SSH_PRIVATE_KEY`
- 变量值：`cat ~/.ssh/id_rsa` 的输出内容

4. 获取服务器 SSH 指纹：
```bash
ssh-keyscan -H your-server-ip
```

5. 在 GitLab 变量中设置：
- 变量名：`SSH_KNOWN_HOSTS`
- 变量值：`ssh-keyscan -H your-server-ip` 的输出内容

## 三、服务器准备

### 1. 创建环境目录结构

```bash
# 在服务器上创建目录结构
sudo mkdir -p /var/www/enterprise
sudo chown -R $USER:$USER /var/www/enterprise

# 克隆项目到各个环境
cd /var/www/enterprise
git clone <your-gitlab-repo-url> enterprise-backend
git clone <your-gitlab-repo-url> enterprise-frontend
```

### 2. 配置 Systemd 服务

#### 开发环境服务
```bash
sudo nano /etc/systemd/system/enterprise-backend-dev.service
```

```ini
[Unit]
Description=Enterprise Backend API (Development)
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/enterprise/enterprise-backend
Environment=PATH=/var/www/enterprise/enterprise-backend/venv/bin
Environment=ENVIRONMENT=development
ExecStart=/var/www/enterprise/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --workers 2
Restart=always

[Install]
WantedBy=multi-user.target
```

#### 测试环境服务
```bash
sudo nano /etc/systemd/system/enterprise-backend-test.service
```

```ini
[Unit]
Description=Enterprise Backend API (Testing)
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/enterprise/enterprise-backend
Environment=PATH=/var/www/enterprise/enterprise-backend/venv/bin
Environment=ENVIRONMENT=testing
ExecStart=/var/www/enterprise/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8002 --workers 2
Restart=always

[Install]
WantedBy=multi-user.target
```

#### 生产环境服务
```bash
sudo nano /etc/systemd/system/enterprise-backend.service
```

```ini
[Unit]
Description=Enterprise Backend API (Production)
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/enterprise/enterprise-backend
Environment=PATH=/var/www/enterprise/enterprise-backend/venv/bin
Environment=ENVIRONMENT=production
ExecStart=/var/www/enterprise/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always

[Install]
WantedBy=multi-user.target
```

### 3. 配置 Nginx

#### 开发环境配置
```bash
sudo nano /etc/nginx/sites-available/enterprise-dev
```

```nginx
server {
    listen 80;
    server_name dev.yourdomain.com;
    
    # 前端静态文件
    location / {
        root /var/www/enterprise/enterprise-frontend/dist;
        try_files $uri $uri/ /index.html;
    }
    
    # API代理到开发环境
    location /api/ {
        proxy_pass http://localhost:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # 上传文件代理
    location /uploads/ {
        proxy_pass http://localhost:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### 测试环境配置
```bash
sudo nano /etc/nginx/sites-available/enterprise-test
```

```nginx
server {
    listen 80;
    server_name test.yourdomain.com;
    
    # 前端静态文件
    location / {
        root /var/www/enterprise/enterprise-frontend/dist;
        try_files $uri $uri/ /index.html;
    }
    
    # API代理到测试环境
    location /api/ {
        proxy_pass http://localhost:8002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # 上传文件代理
    location /uploads/ {
        proxy_pass http://localhost:8002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### 生产环境配置
```bash
sudo nano /etc/nginx/sites-available/enterprise
```

```nginx
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
        root /var/www/enterprise/enterprise-frontend/dist;
        try_files $uri $uri/ /index.html;
        
        # 缓存设置
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # API代理
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 上传文件代理
    location /uploads/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 4. 启用服务

```bash
# 启用并启动服务
sudo systemctl daemon-reload
sudo systemctl enable enterprise-backend-dev
sudo systemctl enable enterprise-backend-test
sudo systemctl enable enterprise-backend
sudo systemctl start enterprise-backend-dev
sudo systemctl start enterprise-backend-test
sudo systemctl start enterprise-backend

# 启用 Nginx 配置
sudo ln -s /etc/nginx/sites-available/enterprise-dev /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/enterprise-test /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/enterprise /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 四、项目配置

### 1. 添加测试文件

#### 后端测试
```bash
mkdir -p enterprise-backend/tests
```

创建 `enterprise-backend/tests/__init__.py`：
```python
# 测试包初始化文件
```

创建 `enterprise-backend/tests/test_api.py`：
```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_company_info():
    response = client.get("/api/company/")
    assert response.status_code == 200

def test_categories():
    response = client.get("/api/category/")
    assert response.status_code == 200
```

#### 前端测试
```bash
cd enterprise-frontend
npm install --save-dev @vue/test-utils jest
```

创建 `enterprise-frontend/jest.config.js`：
```javascript
module.exports = {
  testEnvironment: 'jsdom',
  transform: {
    '^.+\\.vue$': '@vue/vue3-jest',
    '^.+\\js$': 'babel-jest',
  },
  moduleFileExtensions: ['vue', 'js', 'json', 'jsx', 'ts', 'tsx', 'node'],
  testMatch: ['**/tests/**/*.spec.js'],
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
}
```

### 2. 添加健康检查接口

在 `enterprise-backend/app/main.py` 中添加：
```python
@app.get("/api/health")
async def health_check():
    return {"status": "healthy"}
```

### 3. 配置环境变量

#### 开发环境
创建 `enterprise-backend/dev.env`：
```env
DATABASE_URL=mysql://dev_user:dev_password@localhost:3306/enterprise_dev
SECRET_KEY=dev-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
CORS_ORIGINS=["http://localhost:3000", "https://dev.yourdomain.com"]
ENVIRONMENT=development
```

#### 测试环境
创建 `enterprise-backend/test.env`：
```env
DATABASE_URL=mysql://test_user:test_password@localhost:3306/enterprise_test
SECRET_KEY=test-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
CORS_ORIGINS=["https://test.yourdomain.com"]
ENVIRONMENT=testing
```

#### 生产环境
创建 `enterprise-backend/production.env`：
```env
DATABASE_URL=mysql://enterprise_user:your_password@localhost:3306/enterprise_pro
SECRET_KEY=your-production-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
CORS_ORIGINS=["https://yourdomain.com"]
ENVIRONMENT=production
```

## 五、CI/CD 流程说明

### 1. 开发流程

1. **创建功能分支**：
```bash
git checkout -b feature/new-feature
```

2. **开发完成后提交**：
```bash
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

3. **创建合并请求**：
   - 在 GitLab 中创建从 `feature/new-feature` 到 `develop` 的合并请求
   - 自动触发测试阶段
   - 通过测试后合并到 `develop` 分支

4. **自动部署到开发环境**：
   - 合并到 `develop` 分支后自动部署到开发环境
   - 可以在 `https://dev.yourdomain.com` 查看效果

### 2. 测试流程

1. **开发环境测试通过后**：
   - 在 GitLab 中手动触发测试环境部署
   - 部署到 `https://test.yourdomain.com`

2. **测试环境验证**：
   - 进行完整的集成测试
   - 验证所有功能正常

### 3. 生产部署流程

1. **创建生产合并请求**：
   - 从 `develop` 分支创建到 `main` 分支的合并请求
   - 进行代码审查

2. **手动部署到生产环境**：
   - 合并到 `main` 分支后
   - 在 GitLab CI/CD 界面手动触发生产环境部署
   - 自动备份数据库
   - 部署到 `https://yourdomain.com`

## 六、监控和维护

### 1. 日志监控

```bash
# 查看开发环境日志
sudo journalctl -u enterprise-backend-dev -f

# 查看测试环境日志
sudo journalctl -u enterprise-backend-test -f

# 查看生产环境日志
sudo journalctl -u enterprise-backend -f

# 查看 Nginx 日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 2. 性能监控

```bash
# 监控系统资源
htop

# 监控磁盘使用
df -h

# 监控内存使用
free -h

# 监控网络连接
netstat -tlnp
```

### 3. 数据库备份

```bash
# 创建备份脚本
nano backup.sh
```

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/enterprise"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份生产数据库
mysqldump -u enterprise_user -p$PROD_MYSQL_PASSWORD enterprise_pro > $BACKUP_DIR/production_backup_$DATE.sql

# 压缩备份文件
gzip $BACKUP_DIR/production_backup_$DATE.sql

# 删除7天前的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Backup completed: production_backup_$DATE.sql.gz"
```

```bash
chmod +x backup.sh
```

## 七、安全考虑

### 1. 访问控制

- 使用 SSH 密钥认证
- 限制服务器访问权限
- 定期更新 SSH 密钥

### 2. 环境隔离

- 不同环境使用不同的数据库
- 不同环境使用不同的端口
- 不同环境使用不同的域名

### 3. 数据安全

- 生产环境部署前自动备份数据库
- 敏感信息使用 GitLab 变量存储
- 定期检查日志文件

## 八、故障排除

### 1. 常见问题

#### SSH 连接失败
```bash
# 检查 SSH 密钥
ssh-add -l

# 测试 SSH 连接
ssh -T user@your-server

# 检查 known_hosts
cat ~/.ssh/known_hosts
```

#### 部署失败
```bash
# 检查服务状态
sudo systemctl status enterprise-backend-dev
sudo systemctl status enterprise-backend-test
sudo systemctl status enterprise-backend

# 检查日志
sudo journalctl -u enterprise-backend-dev --since "1 hour ago"
```

#### 数据库连接失败
```bash
# 检查 MySQL 服务
sudo systemctl status mysql

# 测试数据库连接
mysql -u enterprise_user -p enterprise_pro
```

### 2. 回滚策略

如果生产环境部署出现问题：

1. **快速回滚**：
```bash
# 回滚到上一个版本
git checkout HEAD~1
git push -f origin main
```

2. **数据库回滚**：
```bash
# 恢复数据库备份
mysql -u enterprise_user -p enterprise_pro < backup_20231201_120000.sql
```

## 九、成本估算

### GitLab CI/CD 成本
- **GitLab.com 免费版**：适合小团队
- **GitLab.com 付费版**：$4/用户/月
- **自建 GitLab**：服务器成本 + 维护成本

### 服务器成本
- **开发环境**：1核2GB，约 $10/月
- **测试环境**：1核2GB，约 $10/月
- **生产环境**：2核4GB，约 $20/月

### 总成本
- **小团队（5人）**：约 $50-100/月
- **中等团队（10人）**：约 $100-200/月

## 十、最佳实践

### 1. 代码质量
- 使用 ESLint 和 Prettier 保持代码风格一致
- 编写单元测试和集成测试
- 使用 TypeScript 提高代码质量

### 2. 部署策略
- 使用蓝绿部署或金丝雀部署
- 设置部署窗口，避免在业务高峰期部署
- 实现自动回滚机制

### 3. 监控告警
- 设置服务健康检查
- 配置错误率告警
- 监控响应时间和吞吐量

### 4. 文档维护
- 保持 README 文件更新
- 记录部署流程和故障排除步骤
- 定期更新技术文档

---

通过这个完整的 GitLab CI/CD 配置，你可以实现：

1. **自动化测试**：每次代码提交都会自动运行测试
2. **自动化构建**：自动构建前端和后端代码
3. **自动化部署**：根据分支自动部署到对应环境
4. **环境隔离**：开发、测试、生产环境完全隔离
5. **安全部署**：生产环境需要手动确认部署
6. **监控告警**：集成监控和告警机制

这个方案不会影响你现有的开发、测试和生产环境，而是为它们添加了自动化的 CI/CD 流程。 