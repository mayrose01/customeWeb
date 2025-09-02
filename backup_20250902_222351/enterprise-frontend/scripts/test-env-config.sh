#!/bin/bash

# 环境配置测试脚本
# 用于验证环境配置是否正确

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== 环境配置测试 ===${NC}"

# 检查配置文件
echo -e "${YELLOW}1. 检查配置文件...${NC}"
if [ -f "env.development" ]; then
    echo -e "${GREEN}✓ env.development 存在${NC}"
else
    echo -e "${RED}✗ env.development 不存在${NC}"
fi

if [ -f "env.test" ]; then
    echo -e "${GREEN}✓ env.test 存在${NC}"
else
    echo -e "${RED}✗ env.test 不存在${NC}"
fi

if [ -f "env.production" ]; then
    echo -e "${GREEN}✓ env.production 存在${NC}"
else
    echo -e "${RED}✗ env.production 不存在${NC}"
fi

if [ -f "env.config.js" ]; then
    echo -e "${GREEN}✓ env.config.js 存在${NC}"
else
    echo -e "${RED}✗ env.config.js 不存在${NC}"
fi

# 检查hosts配置
echo -e "${YELLOW}2. 检查hosts配置...${NC}"
if grep -q "test.catusfoto.top" /etc/hosts; then
    echo -e "${GREEN}✓ test.catusfoto.top 已配置在hosts中${NC}"
    grep "test.catusfoto.top" /etc/hosts
else
    echo -e "${YELLOW}⚠ test.catusfoto.top 未在hosts中配置${NC}"
    echo -e "${YELLOW}建议添加: 127.0.0.1 test.catusfoto.top${NC}"
fi

# 检查端口占用
echo -e "${YELLOW}3. 检查端口占用...${NC}"
if lsof -i :3000 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ 端口3000被占用:${NC}"
    lsof -i :3000
else
    echo -e "${GREEN}✓ 端口3000可用${NC}"
fi

if lsof -i :3001 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ 端口3001被占用:${NC}"
    lsof -i :3001
else
    echo -e "${GREEN}✓ 端口3001可用${NC}"
fi

if lsof -i :8000 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ 端口8000被占用:${NC}"
    lsof -i :8000
else
    echo -e "${GREEN}✓ 端口8000可用${NC}"
fi

# 检查环境变量
echo -e "${YELLOW}4. 检查环境变量...${NC}"
if [ -n "$VITE_APP_ENV" ]; then
    echo -e "${GREEN}✓ VITE_APP_ENV: $VITE_APP_ENV${NC}"
else
    echo -e "${YELLOW}⚠ VITE_APP_ENV 未设置${NC}"
fi

if [ -n "$VITE_API_BASE_URL" ]; then
    echo -e "${GREEN}✓ VITE_API_BASE_URL: $VITE_API_BASE_URL${NC}"
else
    echo -e "${YELLOW}⚠ VITE_API_BASE_URL 未设置${NC}"
fi

# 测试域名解析
echo -e "${YELLOW}5. 测试域名解析...${NC}"
if ping -c 1 test.catusfoto.top > /dev/null 2>&1; then
    echo -e "${GREEN}✓ test.catusfoto.top 可以解析${NC}"
else
    echo -e "${YELLOW}⚠ test.catusfoto.top 无法解析${NC}"
fi

if ping -c 1 localhost > /dev/null 2>&1; then
    echo -e "${GREEN}✓ localhost 可以解析${NC}"
else
    echo -e "${RED}✗ localhost 无法解析${NC}"
fi

# 检查脚本权限
echo -e "${YELLOW}6. 检查脚本权限...${NC}"
for script in scripts/*.sh; do
    if [ -x "$script" ]; then
        echo -e "${GREEN}✓ $script 可执行${NC}"
    else
        echo -e "${RED}✗ $script 不可执行${NC}"
    fi
done

# 显示配置摘要
echo -e "${YELLOW}7. 配置摘要...${NC}"
echo -e "${GREEN}开发环境: http://localhost:3000${NC}"
echo -e "${GREEN}测试环境: http://test.catusfoto.top:3001${NC}"
echo -e "${GREEN}生产环境: https://catusfoto.top${NC}"
echo ""
echo -e "${YELLOW}启动命令:${NC}"
echo -e "${GREEN}开发环境: npm run dev${NC}"
echo -e "${GREEN}测试环境: npm run dev:test-local${NC}"
echo -e "${GREEN}生产环境: npm run build:prod${NC}"

echo -e "${GREEN}=== 测试完成 ===${NC}" 