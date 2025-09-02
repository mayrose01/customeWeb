#!/bin/bash

# 启动后端服务脚本
# 解决Python 3.6兼容性问题

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

# 启动后端服务
start_backend_service() {
    log_step "启动后端服务..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no $SERVER_USERNAME@$SERVER_IP << 'EOF'
cd /var/www/enterprise/enterprise-backend

# 停止现有的服务
pkill -f uvicorn || true

# 激活虚拟环境
source venv/bin/activate

# 设置环境变量
export ENV_FILE=production.env

# 启动服务（使用兼容模式）
nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --log-level info > nohup.out 2>&1 &

echo "后端服务启动中..."
sleep 5

# 检查进程
echo "=== 检查进程 ==="
ps aux | grep uvicorn | grep -v grep

# 检查端口
echo "=== 检查端口 ==="
netstat -tlnp | grep :8000

# 检查日志
echo "=== 检查启动日志 ==="
tail -10 nohup.out
EOF
    
    log_info "后端服务启动完成"
}

# 验证服务
verify_service() {
    log_step "验证后端服务..."
    
    # 等待服务启动
    sleep 10
    
    # 测试API
    if curl -s http://YOUR_SERVER_IP_HERE:8000/docs > /dev/null; then
        log_info "✅ 后端服务启动成功！"
        echo "API文档地址: http://YOUR_SERVER_IP_HERE:8000/docs"
        echo "管理后台登录: https://catusfoto.top/admin"
    else
        log_warn "⚠️ 后端服务可能还在启动中，请稍等片刻再试"
    fi
}

# 主函数
main() {
    log_info "开始启动后端服务..."
    
    # 检查私钥
    if ! check_private_key; then
        exit 1
    fi
    
    # 测试连接
    if ! test_ssh_connection; then
        exit 1
    fi
    
    # 启动服务
    start_backend_service
    
    # 验证服务
    verify_service
    
    log_info "后端服务启动完成！"
}

# 执行主函数
main "$@"
