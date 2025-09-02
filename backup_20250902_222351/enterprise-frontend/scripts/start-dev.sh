#!/bin/bash

# 开发环境启动脚本
# 同时启动前端和后端服务

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}启动开发环境...${NC}"

# 设置环境变量
export VITE_APP_ENV=development
export VITE_API_BASE_URL=http://localhost:8000/api
export VITE_APP_PORT=3000
export VITE_APP_HOST=localhost

# 启动后端服务
echo -e "${YELLOW}启动后端服务 (端口8000)...${NC}"
cd ../enterprise-backend
python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

# 等待后端启动
sleep 3

# 启动前端服务
echo -e "${YELLOW}启动前端服务 (端口3000)...${NC}"
cd ../enterprise-frontend
npm run vite &
FRONTEND_PID=$!

echo -e "${GREEN}开发环境启动完成!${NC}"
echo -e "${GREEN}前端地址: http://localhost:3000${NC}"
echo -e "${GREEN}后端地址: http://localhost:8000${NC}"
echo -e "${GREEN}API文档: http://localhost:8000/docs${NC}"
echo -e "${GREEN}环境测试: http://localhost:3000/env-test${NC}"

# 等待用户中断
trap "echo -e '${YELLOW}正在停止服务...${NC}'; kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait 