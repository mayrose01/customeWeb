#!/bin/bash

# 完整的测试环境启动脚本
# 后端使用Docker，前端使用本地3001端口

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🚀 启动完整测试环境...${NC}"

# 1. 启动Docker后端和数据库
echo -e "${BLUE}📦 启动Docker后端和数据库...${NC}"
docker-compose -f docker-compose.test-simple.yml up -d

# 等待服务启动
echo -e "${YELLOW}⏳ 等待Docker服务启动...${NC}"
sleep 10

# 检查后端健康状态
echo -e "${BLUE}🔍 检查后端服务...${NC}"
if curl -s http://localhost:8001/health > /dev/null; then
    echo -e "${GREEN}✅ 后端服务正常${NC}"
else
    echo -e "${RED}❌ 后端服务异常${NC}"
    exit 1
fi

# 2. 启动前端（3001端口）
echo -e "${BLUE}🌐 启动前端服务（3001端口）...${NC}"
cd enterprise-frontend

# 设置测试环境变量
export VITE_APP_ENV=test
export VITE_API_BASE_URL=http://localhost:8001/api

# 启动前端，明确指定端口
npx vite --port 3001 --host 0.0.0.0 &

# 等待前端启动
sleep 5

# 检查前端状态
echo -e "${BLUE}🔍 检查前端服务...${NC}"
if curl -s http://localhost:3001 > /dev/null; then
    echo -e "${GREEN}✅ 前端服务正常${NC}"
else
    echo -e "${RED}❌ 前端服务异常${NC}"
fi

echo ""
echo -e "${GREEN}🎉 测试环境启动完成！${NC}"
echo ""
echo -e "${BLUE}📋 访问信息：${NC}"
echo -e "   🌐 前端应用: ${GREEN}http://localhost:3001${NC}"
echo -e "   🔧 后端API: ${GREEN}http://localhost:8001${NC}"
echo -e "   📚 API文档: ${GREEN}http://localhost:8001/docs${NC}"
echo -e "   🗄️  数据库: ${GREEN}localhost:3307${NC}"
echo ""
echo -e "${BLUE}🔧 管理命令：${NC}"
echo -e "   停止Docker: ${YELLOW}docker-compose -f docker-compose.test-simple.yml down${NC}"
echo -e "   停止前端: ${YELLOW}pkill -f vite${NC}"
echo ""
