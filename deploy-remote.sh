#!/bin/bash

# 远程服务器部署脚本
# 用于CI/CD流水线中的远程部署

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}远程服务器部署脚本${NC}"
    echo "================================================"
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --host <host>           服务器地址"
    echo "  --user <user>           用户名"
    echo "  --key <key>             SSH私钥文件路径"
    echo "  --env <environment>     目标环境 (test/production)"
    echo "  --version <version>     镜像版本 (默认: latest)"
    echo "  --registry <registry>   镜像仓库地址"
    echo "  --namespace <namespace> 命名空间"
    echo "  --backup                部署前备份"
    echo "  --rollback              回滚到上一个版本"
    echo "  --help                  显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --host server.com --user root --key ~/.ssh/id_rsa --env production"
    echo "  $0 --host server.com --user root --key ~/.ssh/id_rsa --env test --version v1.0.0"
    echo ""
}

# 默认参数
HOST=""
USER=""
KEY=""
ENVIRONMENT=""
VERSION="latest"
REGISTRY="ghcr.io"
NAMESPACE=""
BACKUP=false
ROLLBACK=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            HOST="$2"
            shift 2
            ;;
        --user)
            USER="$2"
            shift 2
            ;;
        --key)
            KEY="$2"
            shift 2
            ;;
        --env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --backup)
            BACKUP=true
            shift
            ;;
        --rollback)
            ROLLBACK=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}❌ 未知参数: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 验证必需参数
if [ -z "$HOST" ] || [ -z "$USER" ] || [ -z "$KEY" ] || [ -z "$ENVIRONMENT" ]; then
    echo -e "${RED}❌ 缺少必需参数${NC}"
    show_help
    exit 1
fi

# 获取Git仓库信息
if [ -z "$NAMESPACE" ]; then
    if [ -n "$GITHUB_REPOSITORY" ]; then
        NAMESPACE="$GITHUB_REPOSITORY"
    else
        NAMESPACE=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')
    fi
fi

echo -e "${BLUE}🚀 远程服务器部署${NC}"
echo "================================================"
echo -e "${YELLOW}服务器: $USER@$HOST${NC}"
echo -e "${YELLOW}环境: $ENVIRONMENT${NC}"
echo -e "${YELLOW}版本: $VERSION${NC}"
echo -e "${YELLOW}仓库: $REGISTRY/$NAMESPACE${NC}"
echo ""

# SSH连接测试
test_ssh_connection() {
    echo -e "${YELLOW}🔍 测试SSH连接...${NC}"
    
    if ! ssh -i "$KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$USER@$HOST" "echo 'SSH连接成功'" 2>/dev/null; then
        echo -e "${RED}❌ SSH连接失败${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ SSH连接成功${NC}"
}

# 备份当前部署
backup_deployment() {
    if [ "$BACKUP" = true ]; then
        echo -e "${YELLOW}💾 备份当前部署...${NC}"
        
        ssh -i "$KEY" -o StrictHostKeyChecking=no "$USER@$HOST" << EOF
            cd /var/www/enterprise
            BACKUP_DIR="backup_\$(date +%Y%m%d_%H%M%S)"
            mkdir -p "\$BACKUP_DIR"
            
            # 备份数据库
            if [ -f "backup_database.sh" ]; then
                ./backup_database.sh "\$BACKUP_DIR"
            fi
            
            # 备份配置文件
            cp -r .env* "\$BACKUP_DIR/" 2>/dev/null || true
            cp -r docker-compose*.yml "\$BACKUP_DIR/" 2>/dev/null || true
            
            echo "备份完成: \$BACKUP_DIR"
EOF
        
        echo -e "${GREEN}✅ 备份完成${NC}"
    fi
}

# 拉取最新代码
pull_latest_code() {
    echo -e "${YELLOW}📥 拉取最新代码...${NC}"
    
    ssh -i "$KEY" -o StrictHostKeyChecking=no "$USER@$HOST" << EOF
        cd /var/www/enterprise
        
        # 拉取最新代码
        git fetch origin
        git reset --hard origin/main
        
        # 确保脚本有执行权限
        chmod +x *.sh
        chmod +x enterprise-backend/*.sh 2>/dev/null || true
EOF
    
    echo -e "${GREEN}✅ 代码拉取完成${NC}"
}

# 设置环境变量
setup_environment() {
    echo -e "${YELLOW}🔧 设置环境变量...${NC}"
    
    ssh -i "$KEY" -o StrictHostKeyChecking=no "$USER@$HOST" << EOF
        cd /var/www/enterprise
        
        # 设置环境变量
        export ENVIRONMENT=$ENVIRONMENT
        export IMAGE_VERSION=$VERSION
        export REGISTRY=$REGISTRY
        export NAMESPACE=$NAMESPACE
        
        # 根据环境设置特定变量
        if [ "$ENVIRONMENT" = "test" ]; then
            export DATABASE_URL="\$TEST_DATABASE_URL"
            export SECRET_KEY="\$TEST_SECRET_KEY"
        elif [ "$ENVIRONMENT" = "production" ]; then
            export DATABASE_URL="\$PROD_DATABASE_URL"
            export SECRET_KEY="\$PROD_SECRET_KEY"
            export MYSQL_ROOT_PASSWORD="\$PROD_MYSQL_ROOT_PASSWORD"
            export MYSQL_PASSWORD="\$PROD_MYSQL_PASSWORD"
            export VITE_API_BASE_URL="\$PROD_VITE_API_BASE_URL"
        fi
        
        # 保存环境变量到文件
        cat > .env.deploy << EOL
ENVIRONMENT=$ENVIRONMENT
IMAGE_VERSION=$VERSION
REGISTRY=$REGISTRY
NAMESPACE=$NAMESPACE
EOL
EOF
    
    echo -e "${GREEN}✅ 环境变量设置完成${NC}"
}

# 拉取新镜像
pull_images() {
    echo -e "${YELLOW}📦 拉取新镜像...${NC}"
    
    ssh -i "$KEY" -o StrictHostKeyChecking=no "$USER@$HOST" << EOF
        cd /var/www/enterprise
        
        # 登录到镜像仓库
        echo "\$GITHUB_TOKEN" | docker login $REGISTRY -u \$GITHUB_ACTOR --password-stdin
        
        # 拉取新镜像
        docker pull $REGISTRY/$NAMESPACE-backend:$VERSION
        docker pull $REGISTRY/$NAMESPACE-frontend:$VERSION
        
        # 标记为latest
        docker tag $REGISTRY/$NAMESPACE-backend:$VERSION $REGISTRY/$NAMESPACE-backend:latest
        docker tag $REGISTRY/$NAMESPACE-frontend:$VERSION $REGISTRY/$NAMESPACE-frontend:latest
EOF
    
    echo -e "${GREEN}✅ 镜像拉取完成${NC}"
}

# 执行部署
deploy_application() {
    echo -e "${YELLOW}🚀 执行部署...${NC}"
    
    ssh -i "$KEY" -o StrictHostKeyChecking=no "$USER@$HOST" << EOF
        cd /var/www/enterprise
        
        # 加载环境变量
        source .env.deploy
        
        # 执行部署
        ./deploy.sh $ENVIRONMENT up
        
        # 等待服务启动
        sleep 30
        
        # 检查服务状态
        ./deploy.sh $ENVIRONMENT status
EOF
    
    echo -e "${GREEN}✅ 部署完成${NC}"
}

# 健康检查
health_check() {
    echo -e "${YELLOW}🔍 执行健康检查...${NC}"
    
    local health_url=""
    if [ "$ENVIRONMENT" = "test" ]; then
        health_url="http://$HOST:8001/health"
    elif [ "$ENVIRONMENT" = "production" ]; then
        health_url="https://$HOST/health"
    fi
    
    if [ -n "$health_url" ]; then
        echo -e "${YELLOW}检查健康状态: $health_url${NC}"
        
        # 等待服务启动
        sleep 10
        
        # 检查健康状态
        for i in {1..5}; do
            if curl -f -s "$health_url" > /dev/null; then
                echo -e "${GREEN}✅ 健康检查通过${NC}"
                return 0
            else
                echo -e "${YELLOW}⏳ 等待服务启动... ($i/5)${NC}"
                sleep 10
            fi
        done
        
        echo -e "${RED}❌ 健康检查失败${NC}"
        return 1
    fi
}

# 回滚部署
rollback_deployment() {
    if [ "$ROLLBACK" = true ]; then
        echo -e "${YELLOW}🔄 执行回滚...${NC}"
        
        ssh -i "$KEY" -o StrictHostKeyChecking=no "$USER@$HOST" << EOF
            cd /var/www/enterprise
            
            # 查找最新的备份
            LATEST_BACKUP=\$(ls -t backup_* | head -n 1)
            
            if [ -n "\$LATEST_BACKUP" ]; then
                echo "回滚到备份: \$LATEST_BACKUP"
                
                # 停止当前服务
                ./deploy.sh $ENVIRONMENT down
                
                # 恢复备份
                cp -r "\$LATEST_BACKUP"/* .
                
                # 重新启动服务
                ./deploy.sh $ENVIRONMENT up
                
                echo "回滚完成"
            else
                echo "没有找到备份文件"
                exit 1
            fi
EOF
        
        echo -e "${GREEN}✅ 回滚完成${NC}"
    fi
}

# 主函数
main() {
    # 测试SSH连接
    test_ssh_connection
    
    if [ "$ROLLBACK" = true ]; then
        # 执行回滚
        rollback_deployment
    else
        # 备份当前部署
        backup_deployment
        
        # 拉取最新代码
        pull_latest_code
        
        # 设置环境变量
        setup_environment
        
        # 拉取新镜像
        pull_images
        
        # 执行部署
        deploy_application
        
        # 健康检查
        health_check
    fi
    
    echo ""
    echo -e "${GREEN}🎉 部署完成！${NC}"
    echo ""
    echo -e "${YELLOW}📋 部署信息:${NC}"
    echo "  服务器: $USER@$HOST"
    echo "  环境: $ENVIRONMENT"
    echo "  版本: $VERSION"
    echo "  时间: $(date)"
}

# 运行主函数
main
