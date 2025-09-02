#!/bin/bash

# SSH连接测试脚本

SERVER_IP="YOUR_SERVER_IP_HERE"
SERVER_USERNAME="root"
SSH_PRIVATE_KEY="./enterprise_prod.pem"

echo "测试SSH连接到服务器: $SERVER_IP"

# 检查私钥文件
if [ ! -f "$SSH_PRIVATE_KEY" ]; then
    echo "错误: 私钥文件不存在: $SSH_PRIVATE_KEY"
    echo "请将从阿里云下载的.pem私钥文件放到项目目录中"
    exit 1
fi

# 设置私钥文件权限
chmod 600 "$SSH_PRIVATE_KEY"
echo "私钥文件权限设置完成"

# 测试连接
echo "正在测试SSH连接..."
if ssh -i "$SSH_PRIVATE_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -o ServerAliveCountMax=3 $SERVER_USERNAME@$SERVER_IP "echo 'SSH连接测试成功'; date; whoami; pwd"; then
    echo "✅ SSH连接成功！"
else
    echo "❌ SSH连接失败"
    exit 1
fi
