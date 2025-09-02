#!/bin/bash

# 企业官网项目 - GitHub安全上传准备脚本
# 此脚本会替换项目中的敏感信息，使其适合上传到GitHub

echo "🔒 开始安全化处理项目文件..."

# 备份原始文件
echo "📦 创建备份..."
mkdir -p backup_$(date +%Y%m%d_%H%M%S)
cp -r * backup_$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true

# 替换服务器密码
echo "🔑 替换服务器密码..."
find . -name "*.sh" -type f -exec sed -i '' 's/Qing0325\./YOUR_SERVER_PASSWORD_HERE/g' {} \;
find . -name "*.py" -type f -exec sed -i '' 's/Qing0325\./YOUR_SERVER_PASSWORD_HERE/g' {} \;
find . -name "*.md" -type f -exec sed -i '' 's/Qing0325\./YOUR_SERVER_PASSWORD_HERE/g' {} \;

# 替换数据库密码
echo "🗄️ 替换数据库密码..."
find . -name "*.sh" -type f -exec sed -i '' 's/YOUR_DATABASE_PASSWORD_HERE/YOUR_DATABASE_PASSWORD_HERE/g' {} \;
find . -name "*.py" -type f -exec sed -i '' 's/YOUR_DATABASE_PASSWORD_HERE/YOUR_DATABASE_PASSWORD_HERE/g' {} \;
find . -name "*.md" -type f -exec sed -i '' 's/YOUR_DATABASE_PASSWORD_HERE/YOUR_DATABASE_PASSWORD_HERE/g' {} \;
find . -name "*.env" -type f -exec sed -i '' 's/YOUR_DATABASE_PASSWORD_HERE/YOUR_DATABASE_PASSWORD_HERE/g' {} \;

# 替换服务器IP地址
echo "🌐 替换服务器IP地址..."
find . -name "*.sh" -type f -exec sed -i '' 's/47\.243\.41\.30/YOUR_SERVER_IP_HERE/g' {} \;
find . -name "*.py" -type f -exec sed -i '' 's/47\.243\.41\.30/YOUR_SERVER_IP_HERE/g' {} \;
find . -name "*.md" -type f -exec sed -i '' 's/47\.243\.41\.30/YOUR_SERVER_IP_HERE/g' {} \;

# 替换数据库连接字符串中的密码
echo "🔗 替换数据库连接字符串..."
find . -name "*.sh" -type f -exec sed -i '' 's/mysql:\/\/enterprise_user:YOUR_DATABASE_PASSWORD_HERE/mysql:\/\/YOUR_DB_USER:YOUR_DB_PASSWORD/g' {} \;
find . -name "*.py" -type f -exec sed -i '' 's/mysql:\/\/enterprise_user:YOUR_DATABASE_PASSWORD_HERE/mysql:\/\/YOUR_DB_USER:YOUR_DB_PASSWORD/g' {} \;
find . -name "*.md" -type f -exec sed -i '' 's/mysql:\/\/enterprise_user:YOUR_DATABASE_PASSWORD_HERE/mysql:\/\/YOUR_DB_USER:YOUR_DB_PASSWORD/g' {} \;
find . -name "*.env" -type f -exec sed -i '' 's/mysql:\/\/enterprise_user:YOUR_DATABASE_PASSWORD_HERE/mysql:\/\/YOUR_DB_USER:YOUR_DB_PASSWORD/g' {} \;

# 替换mysql+pymysql连接字符串中的密码
find . -name "*.sh" -type f -exec sed -i '' 's/mysql\+pymysql:\/\/enterprise_user:YOUR_DATABASE_PASSWORD_HERE/mysql+pymysql:\/\/YOUR_DB_USER:YOUR_DB_PASSWORD/g' {} \;
find . -name "*.py" -type f -exec sed -i '' 's/mysql\+pymysql:\/\/enterprise_user:YOUR_DATABASE_PASSWORD_HERE/mysql+pymysql:\/\/YOUR_DB_USER:YOUR_DB_PASSWORD/g' {} \;
find . -name "*.md" -type f -exec sed -i '' 's/mysql\+pymysql:\/\/enterprise_user:YOUR_DATABASE_PASSWORD_HERE/mysql+pymysql:\/\/YOUR_DB_USER:YOUR_DB_PASSWORD/g' {} \;
find . -name "*.env" -type f -exec sed -i '' 's/mysql\+pymysql:\/\/enterprise_user:YOUR_DATABASE_PASSWORD_HERE/mysql+pymysql:\/\/YOUR_DB_USER:YOUR_DB_PASSWORD/g' {} \;

# 替换SSH密码变量
echo "🔐 替换SSH密码变量..."
find . -name "*.sh" -type f -exec sed -i '' 's/SSH_PASSWORD="Qing0325\."/SSH_PASSWORD="YOUR_SSH_PASSWORD_HERE"/g' {} \;

# 创建README说明文件
echo "📝 创建安全说明文件..."
cat > SECURITY_NOTES.md << 'EOF'
# 🔒 安全注意事项

## 重要提醒
此项目已进行安全化处理，所有敏感信息已被替换为占位符。

## 部署前需要配置的环境变量
1. 复制 `env.example` 为 `.env`
2. 填入真实的服务器信息、数据库密码等
3. 确保 `.env` 文件已添加到 `.gitignore`

## 敏感信息占位符说明
- `YOUR_SERVER_PASSWORD_HERE` - 服务器SSH密码
- `YOUR_DATABASE_PASSWORD_HERE` - 数据库密码
- `YOUR_SERVER_IP_HERE` - 服务器IP地址
- `YOUR_DB_USER` - 数据库用户名
- `YOUR_DB_PASSWORD` - 数据库密码

## 恢复原始配置
如需恢复原始配置，请查看 `backup_YYYYMMDD_HHMMSS/` 目录中的备份文件。

## 安全建议
- 不要在代码中硬编码密码
- 使用环境变量管理敏感信息
- 定期更新密码和密钥
- 限制服务器访问权限
EOF

echo "✅ 安全化处理完成！"
echo ""
echo "📋 下一步操作："
echo "1. 检查替换结果: grep -r 'YOUR_.*_HERE' ."
echo "2. 复制 env.example 为 .env 并填入真实值"
echo "3. 提交代码到GitHub: git add . && git commit -m '安全化处理' && git push"
echo ""
echo "⚠️  注意：请确保 .env 文件已添加到 .gitignore 中！"
echo "📁 备份文件保存在: backup_$(date +%Y%m%d_%H%M%S)/"
