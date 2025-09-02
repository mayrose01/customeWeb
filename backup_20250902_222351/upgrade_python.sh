#!/bin/bash

# Python升级脚本
# 从Python 3.6升级到Python 3.8+

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
SERVER_IP="YOUR_SERVER_IP_HERE"
SERVER_USERNAME="root"
SSH_PRIVATE_KEY="./enterprise_prod.pem"

# 检查私钥文件
check_private_key() {
    log_step "检查私钥文件..."
    
    if [ ! -f "$SSH_PRIVATE_KEY" ]; then
        log_error "私钥文件不存在: $SSH_PRIVATE_KEY"
        return 1
    fi
    
    chmod 600 "$SSH_PRIVATE_KEY"
    log_info "私钥文件权限设置完成"
    return 0
}

# 测试SSH连接
test_ssh_connection() {
    log_step "测试SSH连接..."
    
    if ssh -i "$SSH_PRIVATE_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -o ServerAliveCountMax=3 $SERVER_USERNAME@$SERVER_IP "echo 'SSH连接测试成功'" 2>/dev/null; then
        log_info "SSH连接正常"
        return 0
    else
        log_error "SSH连接失败"
        return 1
    fi
}

# 升级Python
upgrade_python() {
    log_step "升级Python..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
# 备份当前Python
echo "备份当前Python环境..."
cp -r /var/www/enterprise/enterprise-backend/venv /var/www/enterprise/enterprise-backend/venv_backup

# 安装EPEL和IUS仓库
yum install -y epel-release
yum install -y https://repo.ius.io/ius-release-el8.rpm

# 安装Python 3.8
yum install -y python38 python38-pip python38-devel

# 检查安装
python3.8 --version
pip3.8 --version

# 创建新的虚拟环境
cd /var/www/enterprise/enterprise-backend
rm -rf venv
python3.8 -m venv venv

# 激活新虚拟环境
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装依赖
pip install -r requirements.txt

echo "Python升级完成"
EOF
    
    log_info "Python升级完成"
}

# 验证升级
verify_upgrade() {
    log_step "验证Python升级..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-backend

# 检查Python版本
echo "=== 检查Python版本 ==="
source venv/bin/activate
python --version

# 检查依赖
echo "=== 检查依赖 ==="
pip list | head -10

# 测试导入
echo "=== 测试导入 ==="
python -c "from pydantic import BaseModel; print('pydantic导入成功')"
python -c "from pydantic_settings import BaseSettings; print('pydantic-settings导入成功')"
EOF
    
    log_info "Python升级验证完成"
}

# 主函数
main() {
    log_info "开始升级Python..."
    
    # 检查私钥
    if ! check_private_key; then
        exit 1
    fi
    
    # 测试连接
    if ! test_ssh_connection; then
        exit 1
    fi
    
    # 升级Python
    upgrade_python
    
    # 验证升级
    verify_upgrade
    
    log_info "Python升级完成！"
}

# 执行主函数
main "$@"
