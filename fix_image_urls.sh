#!/bin/bash

# 修复图片URL脚本 - 根据环境自动更新图片URL
# 使用方法: ./fix_image_urls.sh [environment]

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 默认环境
ENVIRONMENT=${1:-"test"}

echo -e "${BLUE}🔧 修复图片URL配置 - 环境: $ENVIRONMENT${NC}"

# 根据环境确定目标URL
case $ENVIRONMENT in
    "dev"|"development")
        TARGET_URL="http://localhost:8000"
        DB_NAME="enterprise_dev"
        DB_USER="root"
        DB_PASS="root"
        DB_HOST="localhost"
        DB_PORT="3306"
        ;;
    "test"|"testing")
        TARGET_URL="http://localhost:8001"
        DB_NAME="enterprise_test"
        DB_USER="test_user"
        DB_PASS="test_password"
        DB_HOST="localhost"
        DB_PORT="3307"
        ;;
    "prod"|"production")
        TARGET_URL="https://catusfoto.top"
        DB_NAME="enterprise_prod"
        DB_USER="prod_user"
        DB_PASS="prod_password"
        DB_HOST="mysql_prod"
        DB_PORT="3306"
        ;;
    *)
        echo -e "${RED}❌ 未知环境: $ENVIRONMENT${NC}"
        echo -e "${YELLOW}支持的环境: dev, test, prod${NC}"
        exit 1
        ;;
esac

echo -e "${BLUE}目标URL: $TARGET_URL${NC}"

# 检查Docker容器是否运行
if [ "$ENVIRONMENT" = "test" ] || [ "$ENVIRONMENT" = "testing" ]; then
    if ! docker ps | grep -q enterprise_mysql_test; then
        echo -e "${RED}❌ 测试环境MySQL容器未运行${NC}"
        echo -e "${YELLOW}请先启动测试环境: ./deploy.sh test up${NC}"
        exit 1
    fi
    
    # 使用Docker执行更新
    echo -e "${YELLOW}🔄 更新测试环境数据库图片URL...${NC}"
    docker exec -it enterprise_mysql_test mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
        UPDATE carousel_images SET image_url = REPLACE(image_url, 'http://localhost:8000', '$TARGET_URL');
        UPDATE carousel_images SET image_url = REPLACE(image_url, 'http://localhost:8001', '$TARGET_URL');
        UPDATE company_info SET logo_url = REPLACE(logo_url, 'http://localhost:8000', '$TARGET_URL');
        UPDATE company_info SET company_image = REPLACE(company_image, 'http://localhost:8000', '$TARGET_URL');
        UPDATE company_info SET main_pic_url = REPLACE(main_pic_url, 'http://localhost:8000', '$TARGET_URL');
        UPDATE company_info SET logo_url = REPLACE(logo_url, 'http://localhost:8001', '$TARGET_URL');
        UPDATE company_info SET company_image = REPLACE(company_image, 'http://localhost:8001', '$TARGET_URL');
        UPDATE company_info SET main_pic_url = REPLACE(main_pic_url, 'http://localhost:8001', '$TARGET_URL');
    "
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 测试环境图片URL更新成功${NC}"
    else
        echo -e "${RED}❌ 测试环境图片URL更新失败${NC}"
        exit 1
    fi
    
elif [ "$ENVIRONMENT" = "dev" ] || [ "$ENVIRONMENT" = "development" ]; then
    # 本地开发环境
    echo -e "${YELLOW}🔄 更新开发环境数据库图片URL...${NC}"
    mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -P $DB_PORT $DB_NAME -e "
        UPDATE carousel_images SET image_url = REPLACE(image_url, 'http://localhost:8001', '$TARGET_URL');
        UPDATE company_info SET logo_url = REPLACE(logo_url, 'http://localhost:8001', '$TARGET_URL');
        UPDATE company_info SET company_image = REPLACE(company_image, 'http://localhost:8001', '$TARGET_URL');
        UPDATE company_info SET main_pic_url = REPLACE(main_pic_url, 'http://localhost:8001', '$TARGET_URL');
    "
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 开发环境图片URL更新成功${NC}"
    else
        echo -e "${RED}❌ 开发环境图片URL更新失败${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}🎉 图片URL修复完成！${NC}"
echo -e "${BLUE}现在所有图片URL都指向: $TARGET_URL${NC}"
