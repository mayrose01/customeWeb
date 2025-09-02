#!/bin/bash

echo "=== 邮件功能配置脚本 ==="
echo ""

# 检查是否已经配置
if [ ! -z "$SENDER_EMAIL" ] && [ ! -z "$SENDER_PASSWORD" ]; then
    echo "✅ 邮件配置已存在:"
    echo "   邮箱: $SENDER_EMAIL"
    echo "   密码: ***"
    echo ""
    read -p "是否要重新配置? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "保持现有配置"
        exit 0
    fi
fi

echo "请按照以下步骤配置邮件功能："
echo ""
echo "1. 登录QQ邮箱网页版"
echo "2. 进入'设置' -> '账户'"
echo "3. 找到'POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务'"
echo "4. 开启'POP3/SMTP服务'"
echo "5. 获取授权码（不是QQ密码）"
echo ""

read -p "请输入您的QQ邮箱地址: " email
read -s -p "请输入您的QQ邮箱授权码: " password
echo ""

# 验证输入
if [ -z "$email" ] || [ -z "$password" ]; then
    echo "❌ 邮箱地址或授权码不能为空"
    exit 1
fi

# 设置环境变量
export SENDER_EMAIL="$email"
export SENDER_PASSWORD="$password"

echo ""
echo "✅ 环境变量已设置:"
echo "   SENDER_EMAIL=$email"
echo "   SENDER_PASSWORD=***"

# 测试配置
echo ""
echo "正在测试邮件配置..."

python3 -c "
import os
import smtplib
import ssl

sender_email = os.getenv('SENDER_EMAIL')
sender_password = os.getenv('SENDER_PASSWORD')

try:
    server = smtplib.SMTP('smtp.qq.com', 587)
    server.starttls()
    server.login(sender_email, sender_password)
    print('✅ 邮件配置测试通过！')
    server.quit()
except Exception as e:
    print(f'❌ 邮件配置测试失败: {e}')
    print('请检查邮箱地址和授权码是否正确')
"

# 保存到shell配置文件
shell_config=""
if [[ "$SHELL" == *"zsh"* ]]; then
    shell_config="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    shell_config="$HOME/.bashrc"
else
    shell_config="$HOME/.profile"
fi

echo "" >> "$shell_config"
echo "# 企业官网邮件配置" >> "$shell_config"
echo "export SENDER_EMAIL=\"$email\"" >> "$shell_config"
echo "export SENDER_PASSWORD=\"$password\"" >> "$shell_config"

echo ""
echo "✅ 配置已保存到 $shell_config"
echo "请重新加载配置文件或重启终端:"
echo "   source $shell_config"
echo ""
echo "现在您可以启动后端服务，邮件功能将正常工作！" 