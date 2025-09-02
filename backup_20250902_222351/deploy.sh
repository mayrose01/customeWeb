#!/bin/bash

# 企业官网部署脚本
# 使用方法: ./deploy.sh [production|development]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# 检查环境
check_environment() {
    log_info "检查部署环境..."
    
    # 检查Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 未安装"
        exit 1
    fi
    
    # 检查Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js 未安装"
        exit 1
    fi
    
    # 检查npm
    if ! command -v npm &> /dev/null; then
        log_error "npm 未安装"
        exit 1
    fi
    
    log_info "环境检查完成"
}

# 安装后端依赖
install_backend_deps() {
    log_info "安装后端依赖..."
    cd enterprise-backend
    
    # 创建虚拟环境
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    # 激活虚拟环境
    source venv/bin/activate
    
    # 安装依赖
    pip install -r requirements.txt
    
    # 创建必要的目录
    mkdir -p uploads logs
    
    cd ..
    log_info "后端依赖安装完成"
}

# 安装前端依赖
install_frontend_deps() {
    log_info "安装前端依赖..."
    cd enterprise-frontend
    
    # 安装依赖
    npm install
    
    cd ..
    log_info "前端依赖安装完成"
}

# 构建前端
build_frontend() {
    log_info "构建前端项目..."
    cd enterprise-frontend
    
    # 设置生产环境变量
    export NODE_ENV=production
    
    # 构建项目
    npm run build
    
    cd ..
    log_info "前端构建完成"
}

# 配置生产环境
setup_production() {
    log_info "配置生产环境..."
    
    # 创建生产环境配置文件
    cat > enterprise-backend/production.env << EOF
# 生产环境配置
DATABASE_URL=mysql://username:password@localhost:3306/enterprise_db
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
CORS_ORIGINS=["https://yourdomain.com", "http://yourdomain.com"]
EOF
    
    log_warn "请修改 production.env 文件中的配置信息"
}

# 启动服务
start_services() {
    log_info "启动服务..."
    
    # 启动后端服务
    cd enterprise-backend
    source venv/bin/activate
    
    # 使用生产环境配置启动
    if [ "$1" = "production" ]; then
        nohup python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4 > logs/uvicorn.log 2>&1 &
        log_info "后端服务已启动 (生产模式)"
    else
        python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    fi
    
    cd ..
}

# 主函数
main() {
    local mode=${1:-development}
    
    log_info "开始部署企业官网..."
    log_info "部署模式: $mode"
    
    check_environment
    install_backend_deps
    install_frontend_deps
    
    if [ "$mode" = "production" ]; then
        build_frontend
        setup_production
        start_services production
    else
        start_services development
    fi
    
    log_info "部署完成！"
    log_info "后端API地址: http://localhost:8000"
    log_info "前端地址: http://localhost:5173 (开发模式)"
    log_info "管理后台: http://localhost:5173/admin"
}

# 执行主函数
main "$@" 