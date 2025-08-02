#!/bin/bash

# Favicon更新脚本
# 用于更新生产环境的网站图标

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 服务器配置
SERVER_IP="47.243.41.30"
SERVER_PASSWORD="Qing0325."

# 更新favicon
update_favicon() {
    log_step "开始更新favicon..."
    
    # 检查本地favicon文件
    if [ ! -f "enterprise-frontend/dist/favicon.ico" ]; then
        log_error "本地favicon文件不存在，请先构建前端"
        exit 1
    fi
    
    # 创建临时文件
    log_info "准备favicon文件..."
    cp enterprise-frontend/dist/favicon.ico favicon_temp.ico
    
    # 上传到服务器
    log_info "上传favicon到服务器..."
    sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no favicon_temp.ico root@$SERVER_IP:/tmp/
    
    # 在服务器上更新
    log_info "在服务器上更新favicon..."
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
# 备份原文件
cp /var/www/enterprise-frontend/favicon.ico /var/www/enterprise-frontend/favicon.ico.backup

# 更新favicon文件
cp /tmp/favicon_temp.ico /var/www/enterprise-frontend/favicon.ico

# 更新HTML中的favicon引用（添加版本号强制刷新缓存）
sed -i 's|href="/favicon.ico"[^>]*|href="/favicon.ico?v='$(date +%s)'"|g' /var/www/enterprise-frontend/index.html

# 清理临时文件
rm -f /tmp/favicon_temp.ico

echo "Favicon更新完成"
EOF
    
    # 清理本地临时文件
    rm -f favicon_temp.ico
    
    log_info "Favicon更新完成"
}

# 清除浏览器缓存提示
clear_cache_info() {
    log_info "Favicon更新完成！"
    echo
    echo "=== 更新信息 ==="
    echo "服务器IP: $SERVER_IP"
    echo "域名: https://catusfoto.top"
    echo
    echo "=== 重要提醒 ==="
    echo "1. 如果浏览器仍然显示旧图标，请："
    echo "   - 强制刷新页面 (Ctrl+F5 或 Cmd+Shift+R)"
    echo "   - 清除浏览器缓存"
    echo "   - 或者等待几分钟让缓存自动过期"
    echo
    echo "2. 新的favicon文件已上传到服务器"
    echo "3. HTML文件已更新，添加了版本号参数"
}

# 主函数
main() {
    log_info "开始更新生产环境favicon..."
    update_favicon
    clear_cache_info
}

# 执行主函数
main "$@" 