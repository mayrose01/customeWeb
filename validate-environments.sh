#!/bin/bash

# 环境验证脚本
# 快速验证所有环境的运行状态

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}环境验证脚本${NC}"
    echo "================================================"
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --dev                验证开发环境"
    echo "  --test               验证测试环境"
    echo "  --prod               验证生产环境"
    echo "  --all                验证所有环境"
    echo "  --quick              快速验证（只检查服务状态）"
    echo "  --help               显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --dev             验证开发环境"
    echo "  $0 --all             验证所有环境"
    echo "  $0 --quick --all     快速验证所有环境"
    echo ""
}

# 默认参数
VALIDATE_DEV=false
VALIDATE_TEST=false
VALIDATE_PROD=false
QUICK_MODE=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --dev)
            VALIDATE_DEV=true
            shift
            ;;
        --test)
            VALIDATE_TEST=true
            shift
            ;;
        --prod)
            VALIDATE_PROD=true
            shift
            ;;
        --all)
            VALIDATE_DEV=true
            VALIDATE_TEST=true
            VALIDATE_PROD=true
            shift
            ;;
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}❌ 未知参数: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 如果没有指定环境，默认验证所有环境
if [ "$VALIDATE_DEV" = false ] && [ "$VALIDATE_TEST" = false ] && [ "$VALIDATE_PROD" = false ]; then
    VALIDATE_DEV=true
    VALIDATE_TEST=true
    VALIDATE_PROD=true
fi

echo -e "${BLUE}🔍 环境验证脚本${NC}"
echo "================================================"
echo -e "${YELLOW}验证模式: $([ "$QUICK_MODE" = true ] && echo "快速验证" || echo "完整验证")${NC}"
echo ""

# 检查Docker是否运行
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker未运行，请启动Docker${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker运行正常${NC}"
}

# 检查端口占用
check_port() {
    local port=$1
    local service=$2
    
    if lsof -i :$port > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  端口 $port 被占用 ($service)${NC}"
        return 1
    else
        echo -e "${GREEN}✅ 端口 $port 可用${NC}"
        return 0
    fi
}

# 验证服务健康状态
check_health() {
    local url=$1
    local service=$2
    
    if curl -f -s "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $service 健康检查通过${NC}"
        return 0
    else
        echo -e "${RED}❌ $service 健康检查失败${NC}"
        return 1
    fi
}

# 验证开发环境
validate_dev() {
    echo -e "${BLUE}🔍 验证开发环境${NC}"
    echo "----------------------------------------"
    
    # 检查端口
    check_port 8000 "开发环境后端"
    check_port 3000 "开发环境前端"
    
    # 检查服务状态
    if [ "$QUICK_MODE" = false ]; then
        echo -e "${YELLOW}📋 检查开发环境服务状态...${NC}"
        if ./deploy.sh dev status > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 开发环境服务运行正常${NC}"
        else
            echo -e "${RED}❌ 开发环境服务未运行${NC}"
            return 1
        fi
    fi
    
    # 健康检查
    echo -e "${YELLOW}🔍 执行健康检查...${NC}"
    check_health "http://localhost:8000/health" "开发环境后端"
    check_health "http://localhost:8000/api/health" "开发环境API"
    
    echo -e "${GREEN}✅ 开发环境验证完成${NC}"
    echo ""
}

# 验证测试环境
validate_test() {
    echo -e "${BLUE}🔍 验证测试环境${NC}"
    echo "----------------------------------------"
    
    # 检查端口
    check_port 8001 "测试环境后端"
    check_port 3001 "测试环境前端"
    
    # 检查服务状态
    if [ "$QUICK_MODE" = false ]; then
        echo -e "${YELLOW}📋 检查测试环境服务状态...${NC}"
        if ./deploy.sh test status > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 测试环境服务运行正常${NC}"
        else
            echo -e "${RED}❌ 测试环境服务未运行${NC}"
            return 1
        fi
    fi
    
    # 健康检查
    echo -e "${YELLOW}🔍 执行健康检查...${NC}"
    check_health "http://localhost:8001/health" "测试环境后端"
    check_health "http://localhost:8001/api/health" "测试环境API"
    
    echo -e "${GREEN}✅ 测试环境验证完成${NC}"
    echo ""
}

# 验证生产环境
validate_prod() {
    echo -e "${BLUE}🔍 验证生产环境${NC}"
    echo "----------------------------------------"
    
    # 检查端口
    check_port 8002 "生产环境后端"
    check_port 3002 "生产环境前端"
    
    # 检查服务状态
    if [ "$QUICK_MODE" = false ]; then
        echo -e "${YELLOW}📋 检查生产环境服务状态...${NC}"
        if ./deploy.sh prod status > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 生产环境服务运行正常${NC}"
        else
            echo -e "${RED}❌ 生产环境服务未运行${NC}"
            return 1
        fi
    fi
    
    # 健康检查
    echo -e "${YELLOW}🔍 执行健康检查...${NC}"
    check_health "http://localhost:8002/health" "生产环境后端"
    check_health "http://localhost:8002/api/health" "生产环境API"
    
    echo -e "${GREEN}✅ 生产环境验证完成${NC}"
    echo ""
}

# 显示验证结果
show_results() {
    echo -e "${BLUE}📊 验证结果总结${NC}"
    echo "================================================"
    
    if [ "$VALIDATE_DEV" = true ]; then
        echo -e "${YELLOW}开发环境:${NC}"
        echo "  后端: http://localhost:8000"
        echo "  前端: http://localhost:3000"
        echo "  健康检查: http://localhost:8000/health"
        echo ""
    fi
    
    if [ "$VALIDATE_TEST" = true ]; then
        echo -e "${YELLOW}测试环境:${NC}"
        echo "  后端: http://localhost:8001"
        echo "  前端: http://localhost:3001"
        echo "  健康检查: http://localhost:8001/health"
        echo ""
    fi
    
    if [ "$VALIDATE_PROD" = true ]; then
        echo -e "${YELLOW}生产环境:${NC}"
        echo "  后端: http://localhost:8002"
        echo "  前端: http://localhost:3002"
        echo "  健康检查: http://localhost:8002/health"
        echo ""
    fi
    
    echo -e "${GREEN}🎉 环境验证完成！${NC}"
    echo ""
    echo -e "${YELLOW}💡 下一步操作:${NC}"
    echo "1. 访问前端页面验证功能"
    echo "2. 测试API接口"
    echo "3. 检查数据库连接"
    echo "4. 配置CI/CD部署"
}

# 主函数
main() {
    # 检查Docker
    check_docker
    
    # 验证指定环境
    if [ "$VALIDATE_DEV" = true ]; then
        validate_dev
    fi
    
    if [ "$VALIDATE_TEST" = true ]; then
        validate_test
    fi
    
    if [ "$VALIDATE_PROD" = true ]; then
        validate_prod
    fi
    
    # 显示结果
    show_results
}

# 运行主函数
main
