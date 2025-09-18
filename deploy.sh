#!/bin/bash

# 企业官网统一部署脚本
# 支持开发、测试、生产环境的部署

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}企业官网部署脚本${NC}"
    echo "================================================"
    echo "用法: $0 [环境] [操作]"
    echo ""
    echo "环境:"
    echo "  dev     开发环境"
    echo "  test    测试环境"
    echo "  prod    生产环境"
    echo ""
    echo "操作:"
    echo "  build   构建镜像"
    echo "  up      启动服务"
    echo "  down    停止服务"
    echo "  restart 重启服务"
    echo "  logs    查看日志"
    echo "  status  查看状态"
    echo "  migrate 运行数据库迁移"
    echo "  migrate-check 检查迁移状态"
    echo ""
    echo "示例:"
    echo "  $0 dev up        # 启动开发环境"
    echo "  $0 test build    # 构建测试环境镜像"
    echo "  $0 prod restart  # 重启生产环境"
    echo ""
}

# 加载环境变量
load_environment_variables() {
    local env=$1
    
    echo -e "${BLUE}🔧 加载 $env 环境变量...${NC}"
    
    # 根据环境加载对应的配置文件
    case $env in
        dev)
            if [ -f "enterprise-backend/dev.env" ]; then
                echo -e "${GREEN}✅ 加载开发环境配置: enterprise-backend/dev.env${NC}"
                set -a  # 自动导出变量
                source enterprise-backend/dev.env
                set +a  # 关闭自动导出
            else
                echo -e "${YELLOW}⚠️  开发环境配置文件不存在，使用默认值${NC}"
                # 设置默认的开发环境变量
                export DATABASE_URL="mysql+pymysql://root:root@localhost:3306/enterprise_dev"
                export SECRET_KEY="dev-secret-key-2024-not-for-production"
            fi
            ;;
        test)
            echo -e "${GREEN}✅ 测试环境使用Docker Compose环境变量注入，跳过.env文件加载${NC}"
            # 测试环境通过docker-compose.test.yml的environment字段注入环境变量
            # 不需要加载.env文件
            ;;
        prod)
            if [ -f "enterprise-backend/production.env" ]; then
                echo -e "${GREEN}✅ 加载生产环境配置: enterprise-backend/production.env${NC}"
                set -a
                source enterprise-backend/production.env
                set +a
            else
                echo -e "${RED}❌ 生产环境配置文件不存在: enterprise-backend/production.env${NC}"
                echo "请创建生产环境配置文件或设置环境变量"
                exit 1
            fi
            ;;
    esac
    
    # 设置环境标识
    export ENVIRONMENT="$env"
}

# 检查必要的环境变量
check_environment_variables() {
    local env=$1
    local missing_vars=()
    
    echo -e "${BLUE}🔍 检查环境变量...${NC}"
    
    # 测试环境跳过环境变量检查，因为环境变量通过Docker Compose注入
    if [ "$env" = "test" ]; then
        echo -e "${GREEN}✅ 测试环境跳过环境变量检查，使用Docker Compose环境变量注入${NC}"
        return 0
    fi
    
    # 基础必需变量
    if [ -z "$DATABASE_URL" ]; then
        missing_vars+=("DATABASE_URL")
    fi
    
    if [ -z "$SECRET_KEY" ]; then
        missing_vars+=("SECRET_KEY")
    fi
    
    # 生产环境额外检查
    if [ "$env" = "prod" ]; then
        if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
            missing_vars+=("MYSQL_ROOT_PASSWORD")
        fi
        if [ -z "$MYSQL_PASSWORD" ]; then
            missing_vars+=("MYSQL_PASSWORD")
        fi
        if [ -z "$VITE_API_BASE_URL" ]; then
            missing_vars+=("VITE_API_BASE_URL")
        fi
    fi
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo -e "${RED}❌ 缺少必需的环境变量:${NC}"
        for var in "${missing_vars[@]}"; do
            echo -e "${RED}   - $var${NC}"
        done
        echo ""
        echo -e "${YELLOW}请设置环境变量后重试:${NC}"
        echo "  export DATABASE_URL='mysql+pymysql://user:pass@host:port/db'"
        echo "  export SECRET_KEY='your-secret-key'"
        echo ""
        exit 1
    fi
    
    echo -e "${GREEN}✅ 环境变量检查通过${NC}"
}

# 构建镜像
build_images() {
    local env=$1
    echo -e "${BLUE}🔨 构建 $env 环境镜像...${NC}"
    
    # 构建后端镜像
    echo -e "${YELLOW}构建后端镜像...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml build backend
    
    # 构建前端镜像
    echo -e "${YELLOW}构建前端镜像...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml build frontend
    
    echo -e "${GREEN}✅ 镜像构建完成${NC}"
}

# 启动服务
start_services() {
    local env=$1
    echo -e "${BLUE}🚀 启动 $env 环境服务...${NC}"
    
    # 检查环境变量
    check_environment_variables $env
    
    # 启动数据库服务
    echo -e "${YELLOW}🗄️  启动数据库服务...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml up -d mysql
    
    # 等待数据库启动
    echo -e "${YELLOW}⏳ 等待数据库启动...${NC}"
    sleep 15
    
    # 运行数据库迁移
    echo -e "${YELLOW}📝 运行数据库迁移...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml -f docker-compose.migration.yml up migration
    
    # 启动所有服务
    echo -e "${YELLOW}🚀 启动所有服务...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml up -d
    
    # 等待服务启动
    echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
    sleep 10
    
    # 检查服务状态
    check_services_status $env
    
    echo -e "${GREEN}✅ 服务启动完成${NC}"
}

# 停止服务
stop_services() {
    local env=$1
    echo -e "${BLUE}🛑 停止 $env 环境服务...${NC}"
    
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml down
    
    echo -e "${GREEN}✅ 服务已停止${NC}"
}

# 重启服务
restart_services() {
    local env=$1
    echo -e "${BLUE}🔄 重启 $env 环境服务...${NC}"
    
    stop_services $env
    start_services $env
    
    echo -e "${GREEN}✅ 服务重启完成${NC}"
}

# 运行数据库迁移
run_migration() {
    local env=$1
    echo -e "${BLUE}📝 运行数据库迁移...${NC}"
    
    # 检查环境变量
    check_environment_variables $env
    
    # 确保数据库服务运行
    echo -e "${YELLOW}🗄️  确保数据库服务运行...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml up -d mysql
    
    # 等待数据库启动
    sleep 10
    
    # 运行迁移
    echo -e "${YELLOW}🔄 执行数据库迁移...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml -f docker-compose.migration.yml up migration
    
    echo -e "${GREEN}✅ 数据库迁移完成${NC}"
}

# 检查迁移状态
check_migration_status() {
    local env=$1
    echo -e "${BLUE}🔍 检查数据库迁移状态...${NC}"
    
    # 检查环境变量
    check_environment_variables $env
    
    # 确保数据库服务运行
    echo -e "${YELLOW}🗄️  确保数据库服务运行...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml up -d mysql
    
    # 等待数据库启动
    sleep 10
    
    # 检查迁移状态
    echo -e "${YELLOW}📋 检查迁移状态...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml -f docker-compose.migration.yml up migration-check
    
    echo -e "${GREEN}✅ 迁移状态检查完成${NC}"
}

# 查看日志
show_logs() {
    local env=$1
    echo -e "${BLUE}📋 查看 $env 环境日志...${NC}"
    
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml logs -f
}

# 查看服务状态
check_services_status() {
    local env=$1
    echo -e "${BLUE}📊 检查 $env 环境服务状态...${NC}"
    
    docker-compose -f docker-compose.yml -f docker-compose.$env.yml ps
    
    echo ""
    echo -e "${YELLOW}健康检查:${NC}"
    
    # 检查后端服务
    if docker-compose -f docker-compose.yml -f docker-compose.$env.yml ps backend | grep -q "Up"; then
        echo -e "${GREEN}✅ 后端服务运行正常${NC}"
    else
        echo -e "${RED}❌ 后端服务异常${NC}"
    fi
    
    # 检查前端服务
    if docker-compose -f docker-compose.yml -f docker-compose.$env.yml ps frontend | grep -q "Up"; then
        echo -e "${GREEN}✅ 前端服务运行正常${NC}"
    else
        echo -e "${RED}❌ 前端服务异常${NC}"
    fi
    
    # 检查数据库服务
    if docker-compose -f docker-compose.yml -f docker-compose.$env.yml ps mysql | grep -q "Up"; then
        echo -e "${GREEN}✅ 数据库服务运行正常${NC}"
    else
        echo -e "${RED}❌ 数据库服务异常${NC}"
    fi
}

# 主函数
main() {
    local env=$1
    local action=$2
    
    # 检查参数
    if [ -z "$env" ] || [ -z "$action" ]; then
        show_help
        exit 1
    fi
    
    # 验证环境参数
    if [[ ! "$env" =~ ^(dev|test|prod)$ ]]; then
        echo -e "${RED}❌ 无效的环境参数: $env${NC}"
        echo "支持的环境: dev, test, prod"
        exit 1
    fi
    
    # 验证操作参数
    if [[ ! "$action" =~ ^(build|up|down|restart|logs|status|migrate|migrate-check)$ ]]; then
        echo -e "${RED}❌ 无效的操作参数: $action${NC}"
        echo "支持的操作: build, up, down, restart, logs, status, migrate, migrate-check"
        exit 1
    fi
    
    # 检查Docker Compose文件是否存在
    if [ ! -f "docker-compose.$env.yml" ]; then
        echo -e "${RED}❌ 找不到环境配置文件: docker-compose.$env.yml${NC}"
        exit 1
    fi
    
    # 加载环境变量
    load_environment_variables "$env"
    
    echo -e "${BLUE}🎯 执行操作: $action (环境: $env)${NC}"
    echo "================================================"
    
    # 执行对应操作
    case $action in
        build)
            build_images $env
            ;;
        up)
            start_services $env
            ;;
        down)
            stop_services $env
            ;;
        restart)
            restart_services $env
            ;;
        logs)
            show_logs $env
            ;;
        status)
            check_services_status $env
            ;;
        migrate)
            run_migration $env
            ;;
        migrate-check)
            check_migration_status $env
            ;;
    esac
}

# 运行主函数
main "$@"