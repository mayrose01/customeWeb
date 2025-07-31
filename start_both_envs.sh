#!/bin/bash

# 同时启动开发环境和测试环境
echo "🚀 同时启动开发环境和测试环境..."

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查端口是否被占用
echo -e "${YELLOW}检查端口占用情况...${NC}"

# 检查开发环境端口
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${YELLOW}⚠️  端口8000已被占用，正在停止现有服务...${NC}"
    pkill -f "uvicorn.*8000"
    sleep 2
fi

if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${YELLOW}⚠️  端口3000已被占用，正在停止现有服务...${NC}"
    pkill -f "vite.*3000"
    sleep 2
fi

# 检查测试环境端口
if lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${YELLOW}⚠️  端口8001已被占用，正在停止现有服务...${NC}"
    pkill -f "uvicorn.*8001"
    sleep 2
fi

if lsof -Pi :3001 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${YELLOW}⚠️  端口3001已被占用，正在停止现有服务...${NC}"
    pkill -f "vite.*3001"
    sleep 2
fi

# 启动MySQL测试数据库
echo -e "${BLUE}🗄️  启动测试环境MySQL数据库...${NC}"
docker-compose -f docker-compose.test.yml up mysql_test -d

# 等待数据库启动
sleep 5

# 启动开发环境后端
echo -e "${GREEN}📡 启动开发环境后端 (端口8000)...${NC}"
cd enterprise-backend
ENV=development python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --env-file dev.env &
DEV_BACKEND_PID=$!

# 启动测试环境后端
echo -e "${GREEN}📡 启动测试环境后端 (端口8001)...${NC}"
ENV=test python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload --env-file test.env &
TEST_BACKEND_PID=$!

# 等待后端启动
sleep 5

# 检查后端是否启动成功
if curl -s http://localhost:8000/api/company/ > /dev/null; then
    echo -e "${GREEN}✅ 开发环境后端启动成功${NC}"
else
    echo -e "${RED}❌ 开发环境后端启动失败${NC}"
fi

if curl -s http://localhost:8001/api/company/ > /dev/null; then
    echo -e "${GREEN}✅ 测试环境后端启动成功${NC}"
else
    echo -e "${RED}❌ 测试环境后端启动失败${NC}"
fi

# 启动开发环境前端
echo -e "${GREEN}🌐 启动开发环境前端 (端口3000)...${NC}"
cd ../enterprise-frontend
npm run dev:test-only -- --mode development &
DEV_FRONTEND_PID=$!

# 启动测试环境前端
echo -e "${GREEN}🌐 启动测试环境前端 (端口3001)...${NC}"
VITE_APP_PORT=3001 VITE_API_BASE_URL=http://localhost:8001/api VITE_APP_ENV=test npm run vite -- --mode test &
TEST_FRONTEND_PID=$!

# 等待前端启动
sleep 8

# 检查前端是否启动成功
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✅ 开发环境前端启动成功${NC}"
else
    echo -e "${RED}❌ 开发环境前端启动失败${NC}"
fi

if curl -s http://localhost:3001 > /dev/null; then
    echo -e "${GREEN}✅ 测试环境前端启动成功${NC}"
else
    echo -e "${RED}❌ 测试环境前端启动失败${NC}"
fi

echo ""
echo -e "${GREEN}🎯 所有环境启动完成！${NC}"
echo ""
echo -e "${BLUE}📋 访问信息：${NC}"
echo -e "${GREEN}   开发环境：${NC}"
echo -e "   🔧 后端API: http://localhost:8000"
echo -e "   🌐 前端应用: http://localhost:3000"
echo -e "   🗄️ 数据库: enterprise_dev (端口3306)"
echo ""
echo -e "${GREEN}   测试环境：${NC}"
echo -e "   🔧 后端API: http://localhost:8001"
echo -e "   🌐 前端应用: http://localhost:3001"
echo -e "   🗄️ 数据库: enterprise_test (端口3307)"
echo ""
echo -e "${YELLOW}💡 管理命令：${NC}"
echo -e "   停止开发环境后端: pkill -f 'uvicorn.*8000'"
echo -e "   停止开发环境前端: pkill -f 'vite.*3000'"
echo -e "   停止测试环境后端: pkill -f 'uvicorn.*8001'"
echo -e "   停止测试环境前端: pkill -f 'vite.*3001'"
echo -e "   停止所有服务: pkill -f 'uvicorn\|vite'"
echo -e "   查看开发环境日志: tail -f enterprise-backend/logs/app_$(date +%Y%m%d).log"
echo -e "   查看测试环境日志: tail -f enterprise-backend/logs/app_test.log"
echo ""
echo -e "${YELLOW}🔧 数据库连接：${NC}"
echo -e "   开发环境: mysql -u root -proot -D enterprise_dev"
echo -e "   测试环境: mysql -u test_user -ptest_password -h localhost -P 3307 -D enterprise_test"
echo ""

# 保存进程ID到文件，方便后续管理
echo $DEV_BACKEND_PID > /tmp/dev_backend.pid
echo $TEST_BACKEND_PID > /tmp/test_backend.pid
echo $DEV_FRONTEND_PID > /tmp/dev_frontend.pid
echo $TEST_FRONTEND_PID > /tmp/test_frontend.pid

echo -e "${GREEN}✅ 进程ID已保存到 /tmp/ 目录${NC}"
echo -e "${YELLOW}💡 提示：两个环境完全独立，可以同时使用！${NC}" 