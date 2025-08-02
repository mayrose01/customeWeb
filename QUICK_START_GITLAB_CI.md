# GitLab CI/CD 快速开始指南

## 🚀 5分钟快速配置

### 第一步：准备 GitLab 项目

1. **创建 GitLab 项目**
   ```bash
   # 在 GitLab 中创建新项目
   # 项目名称：enterprise-website
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

#### 必需变量
```
SSH_PRIVATE_KEY=你的SSH私钥内容
SSH_KNOWN_HOSTS=你的服务器SSH公钥指纹
DEV_SSH_HOST=你的开发服务器IP
DEV_SSH_USER=你的SSH用户名
DEV_BACKEND_PATH=/var/www/enterprise/enterprise-backend
DEV_FRONTEND_PATH=/var/www/enterprise/enterprise-frontend
```

#### 可选变量（如果有测试和生产环境）
```
TEST_SSH_HOST=你的测试服务器IP
TEST_SSH_USER=你的SSH用户名
TEST_BACKEND_PATH=/var/www/enterprise/enterprise-backend
TEST_FRONTEND_PATH=/var/www/enterprise/enterprise-frontend
PROD_SSH_HOST=你的生产服务器IP
PROD_SSH_USER=你的SSH用户名
PROD_BACKEND_PATH=/var/www/enterprise/enterprise-backend
PROD_FRONTEND_PATH=/var/www/enterprise/enterprise-frontend
```

### 第三步：生成 SSH 密钥

```bash
# 生成 SSH 密钥
ssh-keygen -t rsa -b 4096 -C "gitlab-ci"

# 将公钥添加到服务器
ssh-copy-id -i ~/.ssh/id_rsa.pub user@your-server

# 获取私钥内容（用于 GitLab 变量）
cat ~/.ssh/id_rsa

# 获取服务器 SSH 指纹
ssh-keyscan -H your-server-ip
```

### 第四步：服务器准备

```bash
# 在服务器上执行
sudo mkdir -p /var/www/enterprise
sudo chown -R $USER:$USER /var/www/enterprise

# 克隆项目
cd /var/www/enterprise
git clone <your-gitlab-repo-url> enterprise-backend
git clone <your-gitlab-repo-url> enterprise-frontend

# 设置后端环境
cd enterprise-backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 设置前端环境
cd ../enterprise-frontend
npm install
```

### 第五步：配置服务

#### 创建后端服务文件
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
ExecStart=/var/www/enterprise/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --workers 2
Restart=always

[Install]
WantedBy=multi-user.target
```

#### 创建 Nginx 配置
```bash
sudo nano /etc/nginx/sites-available/enterprise-dev
```

```nginx
server {
    listen 80;
    server_name dev.yourdomain.com;
    
    location / {
        root /var/www/enterprise/enterprise-frontend/dist;
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://localhost:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### 启用服务
```bash
sudo systemctl daemon-reload
sudo systemctl enable enterprise-backend-dev
sudo systemctl start enterprise-backend-dev

sudo ln -s /etc/nginx/sites-available/enterprise-dev /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 第六步：添加健康检查接口

在 `enterprise-backend/app/main.py` 中添加：

```python
@app.get("/api/health")
async def health_check():
    return {"status": "healthy"}
```

### 第七步：测试 CI/CD

1. **创建功能分支**
   ```bash
   git checkout -b feature/test-ci
   ```

2. **修改代码并提交**
   ```bash
   echo "# Test CI/CD" >> README.md
   git add README.md
   git commit -m "test: add CI/CD test"
   git push origin feature/test-ci
   ```

3. **创建合并请求**
   - 在 GitLab 中创建从 `feature/test-ci` 到 `develop` 的合并请求
   - 观察 CI/CD 流水线执行

4. **合并到开发分支**
   - 合并请求通过后，代码会自动部署到开发环境

## 📋 检查清单

### GitLab 配置
- [ ] 项目已创建
- [ ] 代码已推送
- [ ] SSH 密钥已配置
- [ ] 环境变量已设置

### 服务器配置
- [ ] 目录结构已创建
- [ ] 项目已克隆
- [ ] 虚拟环境已设置
- [ ] 服务已启动
- [ ] Nginx 已配置

### 测试验证
- [ ] 健康检查接口可访问
- [ ] 前端页面可访问
- [ ] API 接口可访问
- [ ] CI/CD 流水线正常执行

## 🔧 常见问题

### 1. SSH 连接失败
```bash
# 检查 SSH 密钥
ssh-add -l

# 测试连接
ssh -T user@your-server
```

### 2. 服务启动失败
```bash
# 检查服务状态
sudo systemctl status enterprise-backend-dev

# 查看日志
sudo journalctl -u enterprise-backend-dev -f
```

### 3. Nginx 配置错误
```bash
# 检查配置
sudo nginx -t

# 查看错误日志
sudo tail -f /var/log/nginx/error.log
```

## 🎯 下一步

1. **完善测试**：添加单元测试和集成测试
2. **配置生产环境**：设置生产环境部署
3. **添加监控**：配置日志监控和告警
4. **优化性能**：添加缓存和CDN

## 💡 提示

- 确保所有敏感信息都存储在 GitLab 变量中
- 定期备份数据库和配置文件
- 监控服务器资源使用情况
- 保持依赖包更新

---

**恭喜！** 你的 GitLab CI/CD 已经配置完成。现在每次推送到 `develop` 分支都会自动部署到开发环境。 