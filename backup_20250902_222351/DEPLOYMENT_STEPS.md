# 企业官网部署步骤指南

## 你的部署信息
- **域名**: catusfoto.top
- **服务器IP**: YOUR_SERVER_IP_HERE
- **项目名称**: enterprise

## 第一步：域名解析配置

### 1. 登录域名管理后台
访问你的域名服务商管理后台（如阿里云、腾讯云等）

### 2. 添加DNS解析记录
添加以下A记录：
```
类型: A
主机记录: @ (或留空)
记录值: YOUR_SERVER_IP_HERE
TTL: 600 (或默认)
```

```
类型: A
主机记录: www
记录值: YOUR_SERVER_IP_HERE
TTL: 600 (或默认)
```

### 3. 验证域名解析
等待几分钟后，在本地测试域名解析：
```bash
ping catusfoto.top
ping www.catusfoto.top
```

## 第二步：SSH连接配置

### 1. 生成SSH密钥（如果没有）
```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

### 2. 复制公钥到服务器
```bash
ssh-copy-id root@YOUR_SERVER_IP_HERE
```

### 3. 测试SSH连接
```bash
ssh root@YOUR_SERVER_IP_HERE
```

## 第三步：一键部署

### 1. 运行部署脚本
```bash
./deploy_to_server.sh
```

这个脚本会自动完成以下操作：
- 安装系统依赖（Python、Node.js、MySQL、Nginx）
- 配置数据库
- 上传项目文件
- 部署后端服务
- 部署前端服务
- 配置Nginx
- 申请SSL证书
- 配置防火墙

### 2. 如果遇到SSH连接问题
如果无法使用SSH密钥连接，可以修改脚本使用密码登录：

编辑 `deploy_to_server.sh`，在SSH命令中添加密码：
```bash
# 修改所有 ssh root@$SERVER_IP 为：
sshpass -p 'your_password' ssh root@$SERVER_IP
```

然后安装sshpass：
```bash
# macOS
brew install sshpass

# Ubuntu/Debian
sudo apt install sshpass
```

## 第四步：手动部署（如果自动部署失败）

### 1. 连接到服务器
```bash
ssh root@YOUR_SERVER_IP_HERE
```

### 2. 安装系统依赖
```bash
# 更新系统
apt update && apt upgrade -y

# 安装Python 3.11
apt install -y python3.11 python3.11-venv python3.11-dev

# 安装Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# 安装MySQL
apt install -y mysql-server

# 安装Nginx
apt install -y nginx

# 安装其他工具
apt install -y curl wget git unzip certbot python3-certbot-nginx

# 启动服务
systemctl start mysql
systemctl enable mysql
systemctl start nginx
systemctl enable nginx
```

### 3. 配置MySQL
```bash
# 创建数据库和用户
mysql -e "CREATE DATABASE IF NOT EXISTS enterprise_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS 'enterprise_user'@'localhost' IDENTIFIED BY 'YOUR_DATABASE_PASSWORD_HERE';"
mysql -e "GRANT ALL PRIVILEGES ON enterprise_db.* TO 'enterprise_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
```

### 4. 上传项目文件
在本地执行：
```bash
# 创建远程目录
ssh root@YOUR_SERVER_IP_HERE "mkdir -p /var/www/enterprise"

# 上传项目文件
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude 'venv' ./ root@YOUR_SERVER_IP_HERE:/var/www/enterprise/
```

### 5. 部署后端
在服务器上执行：
```bash
cd /var/www/enterprise/enterprise-backend

# 创建虚拟环境
python3.11 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 创建必要目录
mkdir -p uploads logs

# 创建生产环境配置
cat > production.env << 'EOF'
DATABASE_URL=mysql://enterprise_user:YOUR_DATABASE_PASSWORD_HERE@localhost:3306/enterprise_db
SECRET_KEY=catusfoto_enterprise_secret_key_2024
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
CORS_ORIGINS=["https://catusfoto.top", "http://catusfoto.top", "https://www.catusfoto.top", "http://www.catusfoto.top"]
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
UPLOAD_DIR=uploads
MAX_FILE_SIZE=2097152
LOG_LEVEL=INFO
LOG_FILE=logs/app.log
EOF

# 导入数据库结构
mysql enterprise_db < ../mysql/init.sql
```

### 6. 部署前端
在服务器上执行：
```bash
cd /var/www/enterprise/enterprise-frontend

# 安装依赖
npm install

# 构建项目
npm run build

# 复制到Nginx目录
mkdir -p /var/www/enterprise-frontend
cp -r dist/* /var/www/enterprise-frontend/
chown -R www-data:www-data /var/www/enterprise-frontend
```

### 7. 配置Nginx
在服务器上执行：
```bash
# 创建Nginx配置
cat > /etc/nginx/sites-available/catusfoto.top << 'EOF'
server {
    listen 80;
    server_name catusfoto.top www.catusfoto.top;
    
    # 前端静态文件
    location / {
        root /var/www/enterprise-frontend;
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
EOF

# 启用站点
ln -sf /etc/nginx/sites-available/catusfoto.top /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 测试配置
nginx -t

# 重启Nginx
systemctl restart nginx
```

### 8. 创建系统服务
在服务器上执行：
```bash
# 创建后端服务文件
cat > /etc/systemd/system/enterprise-backend.service << 'EOF'
[Unit]
Description=Enterprise Backend API
After=network.target mysql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/enterprise/enterprise-backend
Environment=PATH=/var/www/enterprise/enterprise-backend/venv/bin
ExecStart=/var/www/enterprise/enterprise-backend/venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd
systemctl daemon-reload

# 启动服务
systemctl enable enterprise-backend
systemctl start enterprise-backend
```

### 9. 配置防火墙
在服务器上执行：
```bash
# 允许SSH、HTTP、HTTPS
ufw allow ssh
ufw allow 80
ufw allow 443
ufw --force enable
```

### 10. 申请SSL证书
在服务器上执行：
```bash
# 申请SSL证书
certbot --nginx -d catusfoto.top -d www.catusfoto.top --non-interactive --agree-tos --email admin@catusfoto.top

# 设置自动续期
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
```

## 第五步：验证部署

### 1. 检查服务状态
```bash
ssh root@YOUR_SERVER_IP_HERE "systemctl status enterprise-backend"
ssh root@YOUR_SERVER_IP_HERE "systemctl status nginx"
ssh root@YOUR_SERVER_IP_HERE "systemctl status mysql"
```

### 2. 访问网站
- **前端地址**: https://catusfoto.top
- **管理后台**: https://catusfoto.top/admin
- **默认账户**: admin / admin123

### 3. 检查SSL证书
```bash
ssh root@YOUR_SERVER_IP_HERE "certbot certificates"
```

## 第六步：安全配置

### 1. 修改默认密码
登录管理后台，修改默认管理员密码

### 2. 配置邮件服务
编辑 `/var/www/enterprise/enterprise-backend/production.env`：
```env
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### 3. 修改数据库密码
```bash
ssh root@YOUR_SERVER_IP_HERE
mysql -e "ALTER USER 'enterprise_user'@'localhost' IDENTIFIED BY 'new_strong_password';"
```

## 第七步：维护和监控

### 1. 查看日志
```bash
# 后端日志
ssh root@YOUR_SERVER_IP_HERE "journalctl -u enterprise-backend -f"

# Nginx日志
ssh root@YOUR_SERVER_IP_HERE "tail -f /var/log/nginx/access.log"
```

### 2. 重启服务
```bash
ssh root@YOUR_SERVER_IP_HERE "systemctl restart enterprise-backend"
ssh root@YOUR_SERVER_IP_HERE "systemctl restart nginx"
```

### 3. 更新代码
```bash
# 上传新代码
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude 'venv' ./ root@YOUR_SERVER_IP_HERE:/var/www/enterprise/

# 重新部署
ssh root@YOUR_SERVER_IP_HERE "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && pip install -r requirements.txt"
ssh root@YOUR_SERVER_IP_HERE "cd /var/www/enterprise/enterprise-frontend && npm install && npm run build && cp -r dist/* /var/www/enterprise-frontend/"
ssh root@YOUR_SERVER_IP_HERE "systemctl restart enterprise-backend"
```

## 常见问题解决

### 1. SSH连接失败
- 检查服务器IP是否正确
- 确认SSH服务已启动
- 检查防火墙设置

### 2. 域名无法访问
- 检查域名解析是否生效
- 确认Nginx配置正确
- 检查防火墙端口开放

### 3. SSL证书申请失败
- 确认域名解析已生效
- 检查80端口是否开放
- 确认域名可以正常访问

### 4. 数据库连接失败
- 检查MySQL服务状态
- 确认数据库用户权限
- 检查数据库密码配置

---

按照这个指南，你可以成功将企业官网部署到你的服务器上。建议先运行一键部署脚本，如果遇到问题再参考手动部署步骤。 