#!/bin/bash

# 测试环境部署脚本
# 构建并部署到测试服务器

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}开始部署测试环境...${NC}"

# 检查测试域名
echo -e "${YELLOW}检查测试域名配置...${NC}"
if ! grep -q "test.catusfoto.top" /etc/hosts; then
    echo -e "${YELLOW}提示: 建议在hosts文件中添加测试域名映射${NC}"
    echo -e "${YELLOW}添加以下行到 /etc/hosts:${NC}"
    echo -e "${YELLOW}127.0.0.1 test.catusfoto.top${NC}"
    echo ""
fi

# 设置环境变量
export VITE_APP_ENV=test
export VITE_API_BASE_URL=http://test.catusfoto.top:8000/api
export VITE_APP_PORT=80
export VITE_APP_HOST=test.catusfoto.top

# 清理之前的构建
echo -e "${YELLOW}清理之前的构建...${NC}"
rm -rf dist

# 构建测试环境
echo -e "${YELLOW}构建测试环境...${NC}"
npm run build:test

# 检查构建结果
if [ ! -d "dist" ]; then
    echo -e "${RED}错误: 构建失败，dist目录不存在${NC}"
    exit 1
fi

echo -e "${GREEN}测试环境构建完成!${NC}"
echo -e "${GREEN}构建文件位置: ./dist${NC}"
echo -e "${GREEN}测试域名: http://test.catusfoto.top${NC}"
echo -e "${GREEN}测试API: http://test.catusfoto.top:8000/api${NC}"
echo ""
echo -e "${YELLOW}部署说明:${NC}"
echo -e "${YELLOW}1. 将 dist 目录内容复制到测试服务器的web根目录${NC}"
echo -e "${YELLOW}2. 确保测试服务器运行后端服务 (端口8000)${NC}"
echo -e "${YELLOW}3. 配置nginx或其他web服务器${NC}"
echo -e "${YELLOW}4. 访问 http://test.catusfoto.top${NC}"
echo ""
echo -e "${GREEN}部署完成!${NC}" 