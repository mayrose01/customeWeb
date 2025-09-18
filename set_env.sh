#!/bin/bash

# 环境变量设置脚本
# 用于设置不同环境的环境变量

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}环境变量设置脚本${NC}"
    echo "================================================"
    echo "用法: $0 [环境]"
    echo ""
    echo "环境:"
    echo "  dev     开发环境"
    echo "  test    测试环境"
    echo "  prod    生产环境"
    echo ""
    echo "示例:"
    echo "  $0 dev     # 设置开发环境变量"
    echo "  $0 test    # 设置测试环境变量"
    echo "  $0 prod    # 设置生产环境变量"
    echo ""
    echo "注意: 此脚本会设置环境变量到当前shell会话中"
    echo "     要永久设置，请将输出添加到 ~/.bashrc 或 ~/.zshrc"
    echo ""
}

# 设置开发环境变量
set_dev_env() {
    echo -e "${GREEN}🔧 设置开发环境变量${NC}"
    echo "================================================"
    
    export ENVIRONMENT=development
    export DATABASE_URL="mysql+pymysql://dev_user:dev_password@localhost:3308/enterprise_dev"
    export SECRET_KEY="dev-secret-key-2024-not-for-production"
    export ALGORITHM="HS256"
    export ACCESS_TOKEN_EXPIRE_MINUTES="1440"
    export CORS_ORIGINS='["http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://dev.yourdomain.com:8080"]'
    export SMTP_SERVER="smtp.gmail.com"
    export SMTP_PORT="587"
    export SMTP_USERNAME="your-dev-email@gmail.com"
    export SMTP_PASSWORD="your-dev-app-password"
    export SMTP_USE_TLS="true"
    export UPLOAD_DIR="uploads_dev"
    export MAX_FILE_SIZE="2097152"
    export ALLOWED_EXTENSIONS="jpg,jpeg,png,gif,pdf,doc,docx"
    export LOG_LEVEL="DEBUG"
    export LOG_FILE="logs/app_dev.log"
    export WORKERS="1"
    export VITE_API_BASE_URL="http://localhost:8002/api"
    export VITE_APP_TITLE="企业官网-开发环境"
    
    # 数据库配置
    export MYSQL_ROOT_PASSWORD="devpassword"
    export MYSQL_DATABASE="enterprise_dev"
    export MYSQL_USER="dev_user"
    export MYSQL_PASSWORD="dev_password"
    
    echo -e "${GREEN}✅ 开发环境变量设置完成${NC}"
}

# 设置测试环境变量
set_test_env() {
    echo -e "${GREEN}🔧 设置测试环境变量${NC}"
    echo "================================================"
    
    export ENVIRONMENT=testing
    export DATABASE_URL="mysql+pymysql://test_user:test_password@localhost:3307/enterprise_test"
    export SECRET_KEY="test-secret-key-2024-not-for-production"
    export ALGORITHM="HS256"
    export ACCESS_TOKEN_EXPIRE_MINUTES="1440"
    export CORS_ORIGINS='["http://localhost:3001", "http://test.yourdomain.com:8080"]'
    export SMTP_SERVER="smtp.gmail.com"
    export SMTP_PORT="587"
    export SMTP_USERNAME="your-test-email@gmail.com"
    export SMTP_PASSWORD="your-test-app-password"
    export SMTP_USE_TLS="true"
    export UPLOAD_DIR="uploads_test"
    export MAX_FILE_SIZE="2097152"
    export ALLOWED_EXTENSIONS="jpg,jpeg,png,gif,pdf,doc,docx"
    export LOG_LEVEL="INFO"
    export LOG_FILE="logs/app_test.log"
    export WORKERS="2"
    export VITE_API_BASE_URL="http://localhost:8001/api"
    export VITE_APP_TITLE="企业官网-测试环境"
    
    # 数据库配置
    export MYSQL_ROOT_PASSWORD="test_root_password"
    export MYSQL_DATABASE="enterprise_test"
    export MYSQL_USER="test_user"
    export MYSQL_PASSWORD="test_password"
    
    echo -e "${GREEN}✅ 测试环境变量设置完成${NC}"
}

# 设置生产环境变量
set_prod_env() {
    echo -e "${RED}🔧 设置生产环境变量${NC}"
    echo "================================================"
    echo -e "${YELLOW}⚠️  警告: 生产环境配置包含敏感信息${NC}"
    echo ""
    
    # 检查是否已设置生产环境变量
    if [ -z "$PROD_DATABASE_URL" ] || [ -z "$PROD_SECRET_KEY" ]; then
        echo -e "${RED}❌ 生产环境变量未设置${NC}"
        echo ""
        echo "请先设置以下环境变量:"
        echo "  export PROD_DATABASE_URL='mysql+pymysql://user:password@host:port/database'"
        echo "  export PROD_SECRET_KEY='your-production-secret-key'"
        echo "  export PROD_MYSQL_ROOT_PASSWORD='your-mysql-root-password'"
        echo "  export PROD_MYSQL_PASSWORD='your-mysql-password'"
        echo "  export PROD_VITE_API_BASE_URL='https://yourdomain.com/api'"
        echo ""
        exit 1
    fi
    
    export ENVIRONMENT=production
    export DATABASE_URL="$PROD_DATABASE_URL"
    export SECRET_KEY="$PROD_SECRET_KEY"
    export ALGORITHM="HS256"
    export ACCESS_TOKEN_EXPIRE_MINUTES="1440"
    export CORS_ORIGINS='["https://yourdomain.com", "https://www.yourdomain.com"]'
    export SMTP_SERVER="smtp.gmail.com"
    export SMTP_PORT="587"
    export SMTP_USERNAME="$PROD_SMTP_USERNAME"
    export SMTP_PASSWORD="$PROD_SMTP_PASSWORD"
    export SMTP_USE_TLS="true"
    export UPLOAD_DIR="uploads_prod"
    export MAX_FILE_SIZE="2097152"
    export ALLOWED_EXTENSIONS="jpg,jpeg,png,gif,pdf,doc,docx"
    export LOG_LEVEL="INFO"
    export LOG_FILE="logs/app_prod.log"
    export WORKERS="8"
    export VITE_API_BASE_URL="$PROD_VITE_API_BASE_URL"
    export VITE_APP_TITLE="企业官网"
    
    # 数据库配置
    export MYSQL_ROOT_PASSWORD="$PROD_MYSQL_ROOT_PASSWORD"
    export MYSQL_DATABASE="enterprise_prod"
    export MYSQL_USER="enterprise_user"
    export MYSQL_PASSWORD="$PROD_MYSQL_PASSWORD"
    
    echo -e "${GREEN}✅ 生产环境变量设置完成${NC}"
}

# 显示当前环境变量
show_current_env() {
    echo -e "${BLUE}📋 当前环境变量${NC}"
    echo "================================================"
    
    echo "ENVIRONMENT: ${ENVIRONMENT:-未设置}"
    echo "DATABASE_URL: ${DATABASE_URL:-未设置}"
    echo "SECRET_KEY: ${SECRET_KEY:-未设置}"
    echo "LOG_LEVEL: ${LOG_LEVEL:-未设置}"
    echo "VITE_API_BASE_URL: ${VITE_API_BASE_URL:-未设置}"
    echo "MYSQL_DATABASE: ${MYSQL_DATABASE:-未设置}"
    echo "MYSQL_USER: ${MYSQL_USER:-未设置}"
}

# 主函数
main() {
    local env=$1
    
    # 检查参数
    if [ -z "$env" ]; then
        show_help
        exit 1
    fi
    
    # 验证环境参数
    if [[ ! "$env" =~ ^(dev|test|prod)$ ]]; then
        echo -e "${RED}❌ 无效的环境参数: $env${NC}"
        echo "支持的环境: dev, test, prod"
        exit 1
    fi
    
    # 执行对应操作
    case $env in
        dev)
            set_dev_env
            ;;
        test)
            set_test_env
            ;;
        prod)
            set_prod_env
            ;;
    esac
    
    echo ""
    show_current_env
    echo ""
    echo -e "${YELLOW}💡 提示: 要永久设置这些变量，请将以下命令添加到 ~/.bashrc 或 ~/.zshrc:${NC}"
    echo "  source $0 $env"
}

# 运行主函数
main "$@"
