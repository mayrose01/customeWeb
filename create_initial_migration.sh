#!/bin/bash

# 创建初始迁移文件脚本
# 用于将现有数据库结构纳入版本控制

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 创建初始数据库迁移${NC}"
echo "================================================"

# 检查是否在正确的目录
if [ ! -f "enterprise-backend/migrate.py" ]; then
    echo -e "${RED}❌ 请在项目根目录运行此脚本${NC}"
    exit 1
fi

# 设置开发环境变量
echo -e "${YELLOW}🔧 设置开发环境变量...${NC}"
export ENVIRONMENT=development
export DATABASE_URL="mysql+pymysql://dev_user:dev_password@localhost:3308/enterprise_dev"

# 进入后端目录
cd enterprise-backend

# 检查Alembic是否已安装
echo -e "${YELLOW}🔍 检查Alembic安装...${NC}"
if ! python -c "import alembic" 2>/dev/null; then
    echo -e "${RED}❌ Alembic未安装，请先安装: pip install alembic${NC}"
    exit 1
fi

# 初始化迁移环境（如果不存在）
if [ ! -d "migrations" ]; then
    echo -e "${YELLOW}🔧 初始化迁移环境...${NC}"
    python migrate.py init
fi

# 创建初始迁移文件
echo -e "${YELLOW}📝 创建初始迁移文件...${NC}"
python migrate.py create "初始数据库结构"

# 检查生成的迁移文件
echo -e "${YELLOW}🔍 检查生成的迁移文件...${NC}"
if [ -d "migrations/versions" ]; then
    latest_migration=$(ls -t migrations/versions/*.py | head -n 1)
    if [ -f "$latest_migration" ]; then
        echo -e "${GREEN}✅ 初始迁移文件创建成功: $latest_migration${NC}"
        echo ""
        echo -e "${YELLOW}📋 迁移文件内容预览:${NC}"
        head -20 "$latest_migration"
        echo ""
        echo -e "${YELLOW}💡 请检查迁移文件内容，确认无误后可以执行迁移${NC}"
        echo ""
        echo -e "${BLUE}下一步操作:${NC}"
        echo "1. 检查迁移文件: cat $latest_migration"
        echo "2. 执行迁移: ./migrate.sh dev upgrade"
        echo "3. 提交到Git: git add migrations/ && git commit -m 'feat: 添加初始数据库迁移'"
    else
        echo -e "${RED}❌ 迁移文件创建失败${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ 迁移目录不存在${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 初始迁移创建完成${NC}"
