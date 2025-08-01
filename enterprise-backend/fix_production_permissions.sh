#!/bin/bash

# 生产环境权限修复脚本
# 解决nginx用户无法写入uploads和logs目录的问题

echo "🔧 修复生产环境权限..."

# 检查是否在服务器上运行
if [ ! -d "/var/www/enterprise" ]; then
    echo "❌ 此脚本需要在生产服务器上运行"
    exit 1
fi

# 修复uploads目录权限
echo "📁 修复uploads目录权限..."
chown -R nginx:nginx /var/www/enterprise/enterprise-backend/uploads/
chmod -R 755 /var/www/enterprise/enterprise-backend/uploads/

# 修复logs目录权限
echo "📝 修复logs目录权限..."
chown -R nginx:nginx /var/www/enterprise/enterprise-backend/logs/
chmod -R 755 /var/www/enterprise/enterprise-backend/logs/

# 验证权限
echo "✅ 验证权限..."
if sudo -u nginx touch /var/www/enterprise/enterprise-backend/uploads/test_permission.txt 2>/dev/null; then
    echo "✅ uploads目录权限正常"
    rm /var/www/enterprise/enterprise-backend/uploads/test_permission.txt
else
    echo "❌ uploads目录权限仍有问题"
fi

if sudo -u nginx touch /var/www/enterprise/enterprise-backend/logs/test_permission.txt 2>/dev/null; then
    echo "✅ logs目录权限正常"
    rm /var/www/enterprise/enterprise-backend/logs/test_permission.txt
else
    echo "❌ logs目录权限仍有问题"
fi

echo ""
echo "🎯 权限修复完成！"
echo "📋 修复内容："
echo "   - uploads目录: nginx用户可读写"
echo "   - logs目录: nginx用户可读写"
echo "   - 权限设置: 755 (所有者可读写执行，组和其他用户可读执行)"
echo ""
echo "💡 建议："
echo "   - 定期检查权限设置"
echo "   - 在部署新版本时运行此脚本"
echo "   - 监控nginx用户对关键目录的访问权限" 