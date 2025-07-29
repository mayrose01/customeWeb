#!/bin/bash

# 环境切换脚本
# 用法: ./scripts/switch-env.sh [development|test|production]

set -e

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

# 获取环境配置
get_env_config() {
    local env_name=$1
    
    case "$env_name" in
        "development")
            echo "http://localhost:8000/api"
            ;;
        "test")
            echo "http://test.catusfoto.top/api"
            ;;
        "production")
            echo "https://catusfoto.top/api"
            ;;
        *)
            echo ""
            ;;
    esac
}

# 显示帮助信息
show_help() {
    echo "环境切换脚本"
    echo ""
    echo "用法: $0 [environment]"
    echo ""
    echo "可用环境:"
    echo "  development - http://localhost:8000/api"
    echo "  test - http://test.catusfoto.top/api"
    echo "  production - https://catusfoto.top/api"
    echo ""
    echo "示例:"
    echo "  $0 development"
    echo "  $0 production"
}

# 切换环境
switch_environment() {
    local env_name=$1
    
    log_step "切换到 $env_name 环境..."
    
    # 获取API URL
    local api_url=$(get_env_config "$env_name")
    if [[ -z "$api_url" ]]; then
        log_error "未知环境: $env_name"
        show_help
        exit 1
    fi
    
    # 创建 .env.local 文件
    cat > .env.local << EOF
# 环境变量配置 - $env_name
VITE_APP_ENV=$env_name
VITE_API_BASE_URL=$api_url
VITE_APP_TITLE=企业网站管理系统
EOF
    
    log_info "环境配置已更新:"
    echo "  环境: $env_name"
    echo "  API URL: $api_url"
    echo "  配置文件: .env.local"
    
    # 如果是开发环境，启动开发服务器
    if [[ "$env_name" == "development" ]]; then
        log_info "启动开发服务器..."
        npm run dev
    else
        log_info "请运行以下命令构建项目:"
        echo "  npm run build"
    fi
}

# 主函数
main() {
    if [[ $# -eq 0 ]]; then
        log_error "请指定环境名称"
        show_help
        exit 1
    fi
    
    local env_name=$1
    
    case "$env_name" in
        -h|--help)
            show_help
            ;;
        development|test|production)
            switch_environment "$env_name"
            ;;
        *)
            log_error "无效的环境名称: $env_name"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 