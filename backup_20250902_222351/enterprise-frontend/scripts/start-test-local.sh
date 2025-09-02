#!/bin/bash

# 本地测试环境脚本
# 模拟test.catusfoto.top域名，用于本地开发调试

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== 本地测试环境 ===${NC}"

# 检查是否有测试域名配置
if ! grep -q "test.catusfoto.top" /etc/hosts; then
    echo -e "${YELLOW}建议添加hosts配置来模拟测试域名:${NC}"
    echo -e "${BLUE}sudo echo '127.0.0.1 test.catusfoto.top' >> /etc/hosts${NC}"
    echo ""
fi

# 设置环境变量
export VITE_APP_ENV=test
export VITE_API_BASE_URL=http://test.catusfoto.top/api

echo -e "${YELLOW}启动本地测试环境...${NC}"
echo -e "${GREEN}环境变量: VITE_APP_ENV=test${NC}"
echo -e "${GREEN}API地址: http://test.catusfoto.top/api${NC}"
echo ""

# 启动前端开发服务器
echo -e "${YELLOW}启动前端开发服务器...${NC}"
npm run vite &
FRONTEND_PID=$!

echo -e "${GREEN}本地测试环境启动完成!${NC}"
echo -e "${GREEN}前端地址: http://localhost:3000${NC}"
echo -e "${GREEN}测试API: http://test.catusfoto.top/api${NC}"
echo -e "${GREEN}环境测试: http://localhost:3000/env-test${NC}"
echo ""
echo -e "${YELLOW}注意:${NC}"
echo -e "${YELLOW}1. 确保测试服务器运行在 test.catusfoto.top${NC}"
echo -e "${YELLOW}2. 或者添加hosts配置模拟域名${NC}"
echo -e "${YELLOW}3. 此模式用于本地开发调试${NC}"

# 等待用户中断
trap "echo -e '${YELLOW}正在停止服务...${NC}'; kill $FRONTEND_PID; exit" INT
wait 