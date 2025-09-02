#!/bin/bash

# 测试环境后端启动脚本
# 启动测试环境的后端服务

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}启动测试环境后端...${NC}"

# 切换到后端目录
cd ../enterprise-backend

# 激活虚拟环境
source .venv/bin/activate

# 设置测试环境变量
export ENVIRONMENT=test
export DATABASE_URL=mysql+pymysql://root:123456@localhost:3306/enterprise_test

echo -e "${YELLOW}启动测试环境后端服务 (端口8001)...${NC}"
python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001 &
BACKEND_PID=$!

echo -e "${GREEN}测试环境后端启动完成!${NC}"
echo -e "${GREEN}测试API地址: http://localhost:8001/api${NC}"
echo -e "${GREEN}API文档: http://localhost:8001/docs${NC}"

# 等待用户中断
trap "echo -e '${YELLOW}正在停止测试环境后端...${NC}'; kill $BACKEND_PID; exit" INT
wait 