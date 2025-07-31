#!/bin/bash

# 测试环境开发启动脚本
# 在本地启动测试环境配置的前端服务

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}启动测试环境开发模式...${NC}"

# 设置环境变量
export VITE_APP_ENV=test
export VITE_API_BASE_URL=http://localhost:8001/api
export VITE_APP_PORT=3001
export VITE_APP_HOST=test.catusfoto.top

# 检查hosts配置
echo -e "${YELLOW}检查hosts配置...${NC}"
if ! grep -q "test.catusfoto.top" /etc/hosts; then
    echo -e "${YELLOW}警告: 未在hosts文件中找到 test.catusfoto.top 配置${NC}"
    echo -e "${YELLOW}请添加以下配置到 /etc/hosts:${NC}"
    echo -e "${YELLOW}127.0.0.1 test.catusfoto.top${NC}"
    echo ""
fi

# 启动前端服务
echo -e "${YELLOW}启动前端服务 (测试环境配置)...${NC}"
npm run vite -- --mode test &
FRONTEND_PID=$!

echo -e "${GREEN}测试环境开发模式启动完成!${NC}"
echo -e "${GREEN}前端地址: http://test.catusfoto.top:3001${NC}"
echo -e "${GREEN}API地址: http://localhost:8001/api${NC}"
echo -e "${GREEN}环境测试: http://test.catusfoto.top:3001/env-test${NC}"
echo ""
echo -e "${YELLOW}注意: 确保后端服务在 localhost:8001 运行${NC}"

# 等待用户中断
trap "echo -e '${YELLOW}正在停止服务...${NC}'; kill $FRONTEND_PID; exit" INT
wait 