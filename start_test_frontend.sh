#!/bin/bash

# 测试环境前端启动脚本
# 使用3001端口，连接Docker后端

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}启动测试环境前端服务...${NC}"

# 检查Docker后端是否运行
echo -e "${YELLOW}检查Docker后端服务...${NC}"
if curl -s http://localhost:8001/health > /dev/null; then
    echo -e "${GREEN}✅ Docker后端服务正常运行${NC}"
else
    echo -e "${YELLOW}⚠️  Docker后端服务未运行，请先启动Docker测试环境${NC}"
    echo -e "${YELLOW}   运行: docker-compose -f docker-compose.test-simple.yml up -d${NC}"
    exit 1
fi

# 进入前端目录
cd enterprise-frontend

# 设置测试环境变量
export VITE_APP_ENV=test
export VITE_API_BASE_URL=http://localhost:8001/api
export VITE_APP_PORT=3001
export VITE_APP_HOST=0.0.0.0

echo -e "${BLUE}环境配置:${NC}"
echo -e "${BLUE}  VITE_APP_ENV: $VITE_APP_ENV${NC}"
echo -e "${BLUE}  VITE_API_BASE_URL: $VITE_API_BASE_URL${NC}"
echo -e "${BLUE}  VITE_APP_PORT: $VITE_APP_PORT${NC}"

# 启动前端服务
echo -e "${YELLOW}启动前端服务 (端口3001)...${NC}"
npm run dev

echo -e "${GREEN}测试环境前端启动完成!${NC}"
echo -e "${GREEN}前端地址: http://localhost:3001${NC}"
echo -e "${GREEN}后端地址: http://localhost:8001${NC}"
echo -e "${GREEN}API文档: http://localhost:8001/docs${NC}"
