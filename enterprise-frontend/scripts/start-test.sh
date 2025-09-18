#!/bin/bash

# 测试环境启动脚本
# 只启动前端服务，连接到Docker后端

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}启动测试环境...${NC}"

# 设置测试环境变量
export VITE_APP_ENV=test
export VITE_API_BASE_URL=http://localhost:8001/api
export VITE_APP_PORT=3000
export VITE_APP_HOST=localhost

echo -e "${BLUE}环境配置:${NC}"
echo -e "${BLUE}  VITE_APP_ENV: $VITE_APP_ENV${NC}"
echo -e "${BLUE}  VITE_API_BASE_URL: $VITE_API_BASE_URL${NC}"
echo -e "${BLUE}  VITE_APP_PORT: $VITE_APP_PORT${NC}"

# 检查Docker后端是否运行
echo -e "${YELLOW}检查Docker后端服务...${NC}"
if curl -s http://localhost:8001/health > /dev/null; then
    echo -e "${GREEN}✅ Docker后端服务正常运行${NC}"
else
    echo -e "${YELLOW}⚠️  Docker后端服务未运行，请先启动Docker测试环境${NC}"
    echo -e "${YELLOW}   运行: ./deploy.sh test up${NC}"
    exit 1
fi

# 启动前端服务
echo -e "${YELLOW}启动前端服务 (端口3000)...${NC}"
npm run vite

echo -e "${GREEN}测试环境启动完成!${NC}"
echo -e "${GREEN}前端地址: http://localhost:3000${NC}"
echo -e "${GREEN}后端地址: http://localhost:8001${NC}"
echo -e "${GREEN}API文档: http://localhost:8001/docs${NC}"