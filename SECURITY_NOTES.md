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
