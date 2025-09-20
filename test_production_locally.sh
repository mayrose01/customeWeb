#!/bin/bash

# 本地测试生产环境配置
# 使用生产环境的Docker配置在本地测试

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🧪 本地测试生产环境配置...${NC}"

# 创建本地生产环境配置
echo -e "${BLUE}📝 创建本地生产环境配置...${NC}"
cat > .env.production.local << 'EOF'
# 本地生产环境测试配置
MYSQL_ROOT_PASSWORD=local_prod_password
MYSQL_DATABASE=enterprise_prod_local
MYSQL_USER=enterprise_user
MYSQL_PASSWORD=local_prod_password
DATABASE_URL=mysql+pymysql://enterprise_user:local_prod_password@mysql:3306/enterprise_prod_local
SECRET_KEY=local_production_secret_key_2024
CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080"]
VITE_API_BASE_URL=http://localhost:8000/api
VITE_APP_TITLE=企业官网-本地生产测试
SMTP_SERVER=smtp.gmail.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
WORKERS=4
EOF

# 停止现有服务
echo -e "${YELLOW}🛑 停止现有服务...${NC}"
docker-compose -f docker-compose.yml -f docker-compose.prod.yml down -v 2>/dev/null || true

# 启动生产环境配置
echo -e "${BLUE}🚀 启动本地生产环境...${NC}"
docker-compose -f docker-compose.yml -f docker-compose.prod.yml --env-file .env.production.local up -d

# 等待服务启动
echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
sleep 30

# 检查服务状态
echo -e "${BLUE}🔍 检查服务状态...${NC}"
docker-compose -f docker-compose.yml -f docker-compose.prod.yml ps

# 测试服务
echo -e "${BLUE}🧪 测试服务...${NC}"
echo "测试后端健康检查..."
if curl -s http://localhost:8000/health > /dev/null; then
    echo -e "${GREEN}✅ 后端服务正常${NC}"
else
    echo -e "${RED}❌ 后端服务异常${NC}"
fi

echo "测试前端服务..."
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✅ 前端服务正常${NC}"
else
    echo -e "${RED}❌ 前端服务异常${NC}"
fi

echo "测试Nginx代理..."
if curl -s http://localhost:8080 > /dev/null; then
    echo -e "${GREEN}✅ Nginx代理正常${NC}"
else
    echo -e "${RED}❌ Nginx代理异常${NC}"
fi

echo ""
echo -e "${GREEN}🎉 本地生产环境测试完成！${NC}"
echo ""
echo -e "${BLUE}📋 访问信息：${NC}"
echo -e "   🌐 前端应用: http://localhost:3000"
echo -e "   🔧 后端API: http://localhost:8000"
echo -e "   🌐 Nginx代理: http://localhost:8080"
echo -e "   🗄️  MySQL数据库: localhost:3306"
echo ""
echo -e "${BLUE}🔧 管理命令：${NC}"
echo -e "   查看日志: docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs -f"
echo -e "   停止服务: docker-compose -f docker-compose.yml -f docker-compose.prod.yml down"
echo ""
echo -e "${YELLOW}💡 提示：${NC}"
echo -e "   这个配置模拟了生产环境，可以用来测试部署流程"
echo -e "   确认无误后，可以使用 deploy_production_docker.sh 部署到服务器"
