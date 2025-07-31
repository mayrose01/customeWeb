#!/bin/bash

# 测试环境启动脚本（修复版）
# 解决403错误问题

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}启动测试环境（修复版）...${NC}"

# 检查hosts配置
if ! grep -q "test.catusfoto.top" /etc/hosts; then
    echo -e "${RED}错误: hosts文件缺少test.catusfoto.top配置${NC}"
    echo -e "${YELLOW}请在/etc/hosts中添加: 127.0.0.1 test.catusfoto.top${NC}"
    exit 1
fi

# 清理之前的进程
echo -e "${YELLOW}清理之前的进程...${NC}"
pkill -f "vite" || true
pkill -f "uvicorn" || true
sleep 2

# 设置环境变量
export VITE_APP_ENV=test
export VITE_API_BASE_URL=http://test.catusfoto.top:8000/api
export VITE_APP_PORT=3001
export VITE_APP_HOST=0.0.0.0

echo -e "${YELLOW}启动前端服务 (端口3001)...${NC}"

# 启动前端服务（使用固定配置）
npx vite --host 0.0.0.0 --port 3001 --mode test &

# 等待服务启动
sleep 5

# 测试服务
echo -e "${YELLOW}测试服务状态...${NC}"
if curl -s -o /dev/null -w "状态码: %{http_code}\n" http://127.0.0.1:3001 | grep -q "200"; then
    echo -e "${GREEN}✓ 前端服务启动成功${NC}"
else
    echo -e "${RED}✗ 前端服务启动失败${NC}"
fi

echo -e "${GREEN}测试环境启动完成!${NC}"
echo -e "${GREEN}前端地址: http://test.catusfoto.top:3001${NC}"
echo -e "${GREEN}API地址: http://test.catusfoto.top:8000/api${NC}"
echo -e "${GREEN}环境测试: http://test.catusfoto.top:3001/env-test${NC}"
echo -e "${YELLOW}注意: 如果浏览器显示403，请尝试清除浏览器缓存或使用无痕模式${NC}" 