#!/bin/bash

# 专门修复前端构建问题
# 解决Vite版本和Node.js兼容性问题

set -e

# 配置信息
SERVER_IP="47.243.41.30"
PROJECT_NAME="enterprise"
SERVER_PASSWORD="Qing0325."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 修复前端构建
fix_frontend_build() {
    log_step "修复前端构建问题..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
cd /var/www/$PROJECT_NAME/enterprise-frontend

# 清理旧的构建文件
rm -rf node_modules package-lock.json dist

# 安装兼容的Vite版本
npm install vite@4.5.0 --save-dev

# 安装依赖
npm install

# 检查Vite是否安装成功
npx vite --version

# 构建前端
npm run build

# 检查构建结果
ls -la dist/

# 复制到Nginx目录
cp -r dist/* /usr/share/nginx/html/

# 设置权限
chown -R nginx:nginx /usr/share/nginx/html/
chmod -R 755 /usr/share/nginx/html/

echo "前端构建修复完成"
EOF
}

# 验证前端修复
verify_frontend() {
    log_step "验证前端修复..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
echo "=== 前端构建检查 ==="
ls -la /var/www/enterprise/enterprise-frontend/dist/

echo "=== Nginx静态文件检查 ==="
ls -la /usr/share/nginx/html/

echo "=== 网站访问测试 ==="
curl -I https://catusfoto.top | head -10

echo "=== 前端资源检查 ==="
curl -s https://catusfoto.top | grep -o 'src="[^"]*"' | head -5
EOF
}

# 主函数
main() {
    echo "🔧 开始修复前端构建问题..."
    echo ""
    
    fix_frontend_build
    verify_frontend
    
    echo "✅ 前端修复完成！"
}

# 执行主函数
main "$@" 