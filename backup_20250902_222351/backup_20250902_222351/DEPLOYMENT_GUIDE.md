# 企业官网部署指南

## 部署方案选择

### 方案一：云服务器部署（推荐）

#### 1. 服务器准备
- **推荐配置**：2核4GB内存，50GB SSD
- **操作系统**：Ubuntu 20.04 LTS 或 CentOS 8
- **云服务商**：阿里云、腾讯云、AWS、DigitalOcean

#### 2. 环境安装
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Python 3.11
sudo apt install python3.11 python3.11-venv python3.11-dev -y

# 安装Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装MySQL
sudo apt install mysql-server -y
sudo mysql_secure_installation

# 安装Nginx
sudo apt install nginx -y

# 安装Docker（可选）
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

#### 3. 项目部署
```bash
# 克隆项目
git clone <your-repo-url>
cd enterprise

# 给部署脚本执行权限
chmod +x deploy.sh

# 开发环境部署
./deploy.sh development

# 生产环境部署
./deploy.sh production
```

### 方案二：Docker容器化部署

#### 1. 安装Docker和Docker Compose
```bash
# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 2. 配置环境变量
```bash
# 创建环境变量文件
cp enterprise-backend/production.env.example enterprise-backend/production.env

# 编辑配置文件
nano enterprise-backend/production.env
```

#### 3. 启动服务
```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 方案三：静态托管 + API服务

#### 1. 前端部署到Vercel
```bash
# 安装Vercel CLI
npm i -g vercel

# 进入前端目录
cd enterprise-frontend

# 构建项目
npm run build

# 部署到Vercel
vercel --prod
```

#### 2. 后端部署到云服务器
```bash
# 只部署后端
cd enterprise-backend
./deploy.sh production
```

## 详细部署步骤

### 第一步：数据库配置

#### MySQL数据库设置
```sql
-- 创建数据库
CREATE DATABASE enterprise_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户
CREATE USER 'enterprise_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON enterprise_db.* TO 'enterprise_user'@'localhost';
FLUSH PRIVILEGES;
```

#### 数据库连接配置
编辑 `enterprise-backend/production.env`：
```env
DATABASE_URL=mysql://enterprise_user:your_password@localhost:3306/enterprise_db
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
CORS_ORIGINS=["https://yourdomain.com", "http://yourdomain.com"]
```

### 第二步：域名和SSL证书

#### 域名解析
1. 在域名服务商处添加A记录，指向服务器IP
2. 等待DNS解析生效（通常几分钟到几小时）

#### SSL证书配置
```bash
# 安装Certbot
sudo apt install certbot python3-certbot-nginx -y

# 获取SSL证书
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# 自动续期
sudo crontab -e
# 添加：0 12 * * * /usr/bin/certbot renew --quiet
```

### 第三步：Nginx配置

#### 创建Nginx配置文件
```bash
sudo nano /etc/nginx/sites-available/enterprise
```

配置内容：
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
        root /var/www/enterprise-frontend/dist;
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

#### 启用配置
```bash
sudo ln -s /etc/nginx/sites-available/enterprise /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 第四步：服务管理

#### 使用Systemd管理后端服务
```bash
# 创建服务文件
sudo nano /etc/systemd/system/enterprise-backend.service
```

服务配置：
```ini
[Unit]
Description=Enterprise Backend API
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/enterprise/enterprise-backend
Environment=PATH=/var/www/enterprise/enterprise-backend/venv/bin
ExecStart=/var/www/enterprise/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always

[Install]
WantedBy=multi-user.target
```

#### 启动服务
```bash
sudo systemctl daemon-reload
sudo systemctl enable enterprise-backend
sudo systemctl start enterprise-backend
sudo systemctl status enterprise-backend
```

### 第五步：监控和日志

#### 日志管理
```bash
# 查看后端日志
sudo journalctl -u enterprise-backend -f

# 查看Nginx日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

#### 性能监控
```bash
# 安装htop
sudo apt install htop -y

# 监控系统资源
htop

# 监控磁盘使用
df -h

# 监控内存使用
free -h
```

## 部署检查清单

### 环境检查
- [ ] Python 3.11 已安装
- [ ] Node.js 18 已安装
- [ ] MySQL 8.0 已安装并配置
- [ ] Nginx 已安装并配置
- [ ] 域名解析已生效
- [ ] SSL证书已配置

### 服务检查
- [ ] 后端API服务正常运行
- [ ] 前端静态文件已部署
- [ ] 数据库连接正常
- [ ] 文件上传功能正常
- [ ] 邮件发送功能正常

### 安全检查
- [ ] 防火墙已配置
- [ ] SSH密钥登录已配置
- [ ] 数据库密码已修改
- [ ] API密钥已设置
- [ ] 文件权限已正确设置

### 性能检查
- [ ] 页面加载速度正常
- [ ] 图片加载正常
- [ ] API响应时间正常
- [ ] 数据库查询性能正常

## 常见问题解决

### 1. 端口被占用
```bash
# 查看端口占用
sudo netstat -tlnp | grep :8000

# 杀死进程
sudo kill -9 <PID>
```

### 2. 权限问题
```bash
# 修改文件权限
sudo chown -R www-data:www-data /var/www/enterprise
sudo chmod -R 755 /var/www/enterprise
```

### 3. 数据库连接失败
```bash
# 检查MySQL服务
sudo systemctl status mysql

# 检查数据库连接
mysql -u enterprise_user -p enterprise_db
```

### 4. SSL证书问题
```bash
# 重新获取证书
sudo certbot --nginx -d yourdomain.com

# 检查证书状态
sudo certbot certificates
```

## 维护和更新

### 代码更新
```bash
# 拉取最新代码
git pull origin main

# 重新部署
./deploy.sh production
```

### 数据库备份
```bash
# 创建备份脚本
nano backup.sh
```

备份脚本内容：
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u enterprise_user -p enterprise_db > backup_$DATE.sql
```

### 监控告警
- 设置服务器监控（CPU、内存、磁盘）
- 配置日志监控
- 设置邮件告警

## 成本估算

### 云服务器费用（月）
- 阿里云ECS 2核4GB：约200-300元/月
- 域名费用：约50-100元/年
- SSL证书：免费（Let's Encrypt）

### 其他可选服务
- CDN加速：约50-100元/月
- 对象存储：约20-50元/月
- 监控服务：约50-100元/月

总计：约300-500元/月（基础配置）

---

按照这个指南，你可以选择最适合的部署方案。建议先使用方案一进行部署，熟悉后再考虑容器化部署。 