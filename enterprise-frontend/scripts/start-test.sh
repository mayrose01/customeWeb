#!/bin/bash

# 测试环境启动脚本
# 构建并部署到测试域名

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}启动测试环境...${NC}"

# 检查测试域名是否可访问
echo -e "${YELLOW}检查测试域名...${NC}"
if ! curl -s http://test.catusfoto.top:8000/api/company/ > /dev/null; then
    echo -e "${RED}警告: 测试域名 test.catusfoto.top:8000 无法访问${NC}"
    echo -e "${YELLOW}请确保:${NC}"
    echo -e "${YELLOW}1. 测试域名已正确配置DNS或hosts映射${NC}"
    echo -e "${YELLOW}2. 测试服务器已启动后端服务 (端口8000)${NC}"
    echo -e "${YELLOW}3. 防火墙允许访问${NC}"
    echo ""
fi

# 设置环境变量
export VITE_APP_ENV=test
export VITE_API_BASE_URL=http://test.catusfoto.top:8000/api
export VITE_APP_PORT=3001
export VITE_APP_HOST=test.catusfoto.top

# 构建测试环境
echo -e "${YELLOW}构建测试环境...${NC}"
npm run build:test

echo -e "${GREEN}测试环境构建完成!${NC}"
echo -e "${GREEN}测试域名: http://test.catusfoto.top:3001${NC}"
echo -e "${GREEN}测试API: http://test.catusfoto.top:8000/api${NC}"
echo ""
echo -e "${YELLOW}下一步操作:${NC}"
echo -e "${YELLOW}1. 将 dist 目录部署到测试服务器${NC}"
echo -e "${YELLOW}2. 确保测试服务器运行后端服务 (端口8000)${NC}"
echo -e "${YELLOW}3. 访问 http://test.catusfoto.top:3001${NC}"
echo ""
echo -e "${GREEN}构建文件位置: ./dist${NC}" 