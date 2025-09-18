#!/bin/bash

# 升级生产环境Python版本到3.9.6

set -e

# 配置
SERVER_IP="catusfoto.top"
SSH_KEY="/Users/huangqing/enterprise/enterprise_prod.pem"
BACKEND_PATH="/var/www/enterprise/enterprise-backend"

echo "🐍 升级生产环境Python版本到3.9.6"
echo "================================================"

# 1. 检查当前Python版本
echo "📋 检查当前Python版本..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "python3 --version"

# 2. 安装Python 3.9依赖
echo "🔄 安装Python 3.9依赖..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "yum update -y"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "yum groupinstall -y 'Development Tools'"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "yum install -y openssl-devel bzip2-devel libffi-devel zlib-devel readline-devel sqlite-devel wget curl"

# 3. 下载并编译Python 3.9.6
echo "🔄 下载并编译Python 3.9.6..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd /tmp && wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd /tmp && tar xzf Python-3.9.6.tgz"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd /tmp/Python-3.9.6 && ./configure --enable-optimizations --prefix=/usr/local"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd /tmp/Python-3.9.6 && make -j 4"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd /tmp/Python-3.9.6 && make altinstall"

# 4. 创建软链接
echo "🔄 创建Python 3.9软链接..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "ln -sf /usr/local/bin/python3.9 /usr/local/bin/python3"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "ln -sf /usr/local/bin/python3.9 /usr/local/bin/python"

# 5. 更新PATH
echo "🔄 更新PATH环境变量..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "echo 'export PATH=/usr/local/bin:\$PATH' >> /etc/profile"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "source /etc/profile"

# 6. 验证Python版本
echo "📋 验证Python版本..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "/usr/local/bin/python3 --version"

# 7. 重新创建虚拟环境
echo "🔄 重新创建虚拟环境..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && rm -rf venv"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && /usr/local/bin/python3 -m venv venv"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && source venv/bin/activate && pip install --upgrade pip"

# 8. 重新安装依赖
echo "🔄 重新安装Python依赖..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && source venv/bin/activate && pip install -r requirements.txt"

# 9. 验证虚拟环境Python版本
echo "📋 验证虚拟环境Python版本..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@$SERVER_IP "cd $BACKEND_PATH && source venv/bin/activate && python --version"

echo "✅ Python升级完成！"
echo "================================================"
echo "现在可以重启后端服务了"
