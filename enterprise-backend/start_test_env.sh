#!/bin/bash

# 设置测试环境变量
export ENV=test

# 启动测试环境服务
echo "启动测试环境服务..."
echo "环境变量: ENV=$ENV"
echo "API地址: http://localhost:8000/test/api"
echo "静态文件: http://localhost:8000/test/uploads"

# 启动服务
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload 