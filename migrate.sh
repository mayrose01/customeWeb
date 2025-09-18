#!/bin/bash

# 数据库迁移管理脚本
# 用于管理企业官网项目的数据库变更

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}数据库迁移管理工具${NC}"
    echo "================================================"
    echo "用法: $0 [环境] [命令] [参数]"
    echo ""
    echo "环境:"
    echo "  dev     开发环境"
    echo "  test    测试环境"
    echo "  prod    生产环境"
    echo ""
    echo "命令:"
    echo "  init                   初始化迁移环境"
    echo "  create <message>       创建新的迁移文件"
    echo "  upgrade [revision]     升级数据库 (默认到最新版本)"
    echo "  downgrade <revision>   降级数据库到指定版本"
    echo "  history                显示迁移历史"
    echo "  current                显示当前数据库版本"
    echo "  pending                显示待执行的迁移"
    echo "  reset                  重置数据库 (危险操作)"
    echo ""
    echo "示例:"
    echo "  $0 dev init                           # 初始化开发环境迁移"
    echo "  $0 dev create \"添加用户表\"            # 创建迁移文件"
    echo "  $0 test upgrade                       # 升级测试环境数据库"
    echo "  $0 prod upgrade head                  # 升级生产环境到最新版本"
    echo "  $0 dev downgrade -1                   # 降级一个版本"
    echo "  $0 test history                       # 查看测试环境迁移历史"
    echo ""
}

# 检查环境变量
check_environment() {
    local env=$1
    
    echo -e "${BLUE}🔍 检查环境配置...${NC}"
    
    # 设置环境变量
    case $env in
        dev)
            export ENVIRONMENT=development
            export DATABASE_URL="mysql+pymysql://dev_user:dev_password@localhost:3308/enterprise_dev"
            ;;
        test)
            export ENVIRONMENT=testing
            export DATABASE_URL="mysql+pymysql://test_user:test_password@localhost:3307/enterprise_test"
            ;;
        prod)
            export ENVIRONMENT=production
            if [ -z "$DATABASE_URL" ]; then
                echo -e "${RED}❌ 生产环境需要设置DATABASE_URL环境变量${NC}"
                echo "例如: export DATABASE_URL='mysql+pymysql://user:password@host:port/database'"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}❌ 无效的环境: $env${NC}"
            echo "支持的环境: dev, test, prod"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ 环境配置检查通过${NC}"
    echo -e "${YELLOW}环境: $ENVIRONMENT${NC}"
    echo -e "${YELLOW}数据库: $DATABASE_URL${NC}"
}

# 执行迁移命令
run_migration() {
    local env=$1
    local command=$2
    shift 2
    local args="$@"
    
    echo -e "${BLUE}🚀 执行数据库迁移操作${NC}"
    echo "================================================"
    
    # 检查环境
    check_environment $env
    
    # 进入后端目录
    cd enterprise-backend
    
    # 执行迁移命令
    case $command in
        init)
            echo -e "${GREEN}🔧 初始化迁移环境...${NC}"
            python migrate.py init
            ;;
        create)
            if [ -z "$args" ]; then
                echo -e "${RED}❌ 请提供迁移描述信息${NC}"
                exit 1
            fi
            echo -e "${GREEN}📝 创建迁移文件: $args${NC}"
            python migrate.py create "$args"
            ;;
        upgrade)
            echo -e "${GREEN}⬆️  升级数据库...${NC}"
            python migrate.py upgrade ${args:-head}
            ;;
        downgrade)
            if [ -z "$args" ]; then
                echo -e "${RED}❌ 请提供目标版本${NC}"
                exit 1
            fi
            echo -e "${GREEN}⬇️  降级数据库到: $args${NC}"
            python migrate.py downgrade "$args"
            ;;
        history)
            echo -e "${GREEN}📋 显示迁移历史...${NC}"
            python migrate.py history
            ;;
        current)
            echo -e "${GREEN}📍 显示当前版本...${NC}"
            python migrate.py current
            ;;
        pending)
            echo -e "${GREEN}⏳ 显示待执行迁移...${NC}"
            python migrate.py pending
            ;;
        reset)
            echo -e "${RED}⚠️  重置数据库...${NC}"
            python migrate.py reset
            ;;
        *)
            echo -e "${RED}❌ 无效的命令: $command${NC}"
            show_help
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ 迁移操作完成${NC}"
}

# 主函数
main() {
    local env=$1
    local command=$2
    shift 2
    local args="$@"
    
    # 检查参数
    if [ -z "$env" ] || [ -z "$command" ]; then
        show_help
        exit 1
    fi
    
    # 验证环境参数
    if [[ ! "$env" =~ ^(dev|test|prod)$ ]]; then
        echo -e "${RED}❌ 无效的环境参数: $env${NC}"
        echo "支持的环境: dev, test, prod"
        exit 1
    fi
    
    # 执行迁移操作
    run_migration $env $command $args
}

# 运行主函数
main "$@"
