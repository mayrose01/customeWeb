#!/bin/bash

# Docker验证环境脚本
# 在本地创建与生产环境相同的Docker环境进行测试

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

# 启动Docker验证环境
start_test_env() {
    log_step "启动Docker验证环境..."
    
    # 检查Docker是否运行
    if ! docker info &> /dev/null; then
        log_error "Docker未运行，请启动Docker"
        exit 1
    fi
    
    # 停止并删除现有容器
    log_info "清理现有容器..."
    docker-compose down -v 2>/dev/null || true
    
    # 构建并启动服务
    log_info "构建并启动服务..."
    docker-compose up --build -d
    
    log_info "Docker验证环境启动完成"
    echo
    echo "=== 验证环境信息 ==="
    echo "前端: http://localhost:3000"
    echo "后端API: http://localhost:8000"
    echo "管理后台: http://localhost:3000/admin"
    echo "数据库: localhost:3306"
    echo
    echo "=== 查看日志 ==="
    echo "docker-compose logs -f"
    echo
    echo "=== 停止环境 ==="
    echo "docker-compose down"
}

# 停止Docker验证环境
stop_test_env() {
    log_step "停止Docker验证环境..."
    docker-compose down -v
    log_info "Docker验证环境已停止"
}

# 查看服务状态
check_status() {
    log_step "检查服务状态..."
    docker-compose ps
}

# 查看日志
view_logs() {
    log_step "查看服务日志..."
    docker-compose logs -f
}

# 主函数
main() {
    case "${1:-start}" in
        "start")
            start_test_env
            ;;
        "stop")
            stop_test_env
            ;;
        "status")
            check_status
            ;;
        "logs")
            view_logs
            ;;
        *)
            echo "用法: $0 [start|stop|status|logs]"
            echo "  start  - 启动验证环境"
            echo "  stop   - 停止验证环境"
            echo "  status - 查看服务状态"
            echo "  logs   - 查看服务日志"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 