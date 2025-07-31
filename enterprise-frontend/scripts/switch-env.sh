#!/bin/bash

# 环境切换脚本
# 用于在不同环境间切换配置

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 检查参数
if [ $# -eq 0 ]; then
    echo -e "${RED}错误: 请指定环境${NC}"
    echo -e "${YELLOW}用法: $0 [development|test|production]${NC}"
    echo -e "${YELLOW}可用环境:${NC}"
    echo -e "${YELLOW}  development - 本地开发环境 (http://localhost)${NC}"
    echo -e "${YELLOW}  test        - 测试环境 (http://test.catusfoto.top)${NC}"
    echo -e "${YELLOW}  production  - 生产环境 (https://catusfoto.top)${NC}"
    exit 1
fi

ENV=$1

# 验证环境参数
if [[ ! "$ENV" =~ ^(development|test|production)$ ]]; then
    echo -e "${RED}错误: 无效的环境参数 '${ENV}'${NC}"
    echo -e "${YELLOW}可用环境: development, test, production${NC}"
    exit 1
fi

echo -e "${GREEN}切换到 ${ENV} 环境...${NC}"

# 根据环境设置配置
case $ENV in
    "development")
        echo -e "${YELLOW}配置开发环境...${NC}"
        export VITE_APP_ENV=development
        export VITE_API_BASE_URL=http://localhost:8000/api
        export VITE_APP_PORT=80
        export VITE_APP_HOST=localhost
        echo -e "${GREEN}开发环境配置完成!${NC}"
        echo -e "${GREEN}访问地址: http://localhost${NC}"
        echo -e "${GREEN}API地址: http://localhost:8000/api${NC}"
        ;;
    "test")
        echo -e "${YELLOW}配置测试环境...${NC}"
        export VITE_APP_ENV=test
        export VITE_API_BASE_URL=http://test.catusfoto.top:8000/api
        export VITE_APP_PORT=80
        export VITE_APP_HOST=test.catusfoto.top
        echo -e "${GREEN}测试环境配置完成!${NC}"
        echo -e "${GREEN}访问地址: http://test.catusfoto.top${NC}"
        echo -e "${GREEN}API地址: http://test.catusfoto.top:8000/api${NC}"
        echo -e "${YELLOW}注意: 确保hosts文件包含 test.catusfoto.top 映射${NC}"
        ;;
    "production")
        echo -e "${YELLOW}配置生产环境...${NC}"
        export VITE_APP_ENV=production
        export VITE_API_BASE_URL=https://catusfoto.top/api
        export VITE_APP_PORT=443
        export VITE_APP_HOST=catusfoto.top
        echo -e "${GREEN}生产环境配置完成!${NC}"
        echo -e "${GREEN}访问地址: https://catusfoto.top${NC}"
        echo -e "${GREEN}API地址: https://catusfoto.top/api${NC}"
        ;;
esac

echo -e "${GREEN}环境切换完成!${NC}"
echo -e "${YELLOW}当前环境变量:${NC}"
echo -e "${YELLOW}  VITE_APP_ENV=${VITE_APP_ENV}${NC}"
echo -e "${YELLOW}  VITE_API_BASE_URL=${VITE_API_BASE_URL}${NC}"
echo -e "${YELLOW}  VITE_APP_PORT=${VITE_APP_PORT}${NC}"
echo -e "${YELLOW}  VITE_APP_HOST=${VITE_APP_HOST}${NC}" 