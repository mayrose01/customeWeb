#!/bin/bash

# Docker镜像构建和推送脚本
# 用于CI/CD流水线中的镜像构建和推送

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Docker镜像构建和推送脚本${NC}"
    echo "================================================"
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --registry <registry>    镜像仓库地址 (默认: ghcr.io)"
    echo "  --namespace <namespace>  命名空间 (默认: 从Git仓库获取)"
    echo "  --version <version>      镜像版本 (默认: latest)"
    echo "  --push                   推送到仓库"
    echo "  --platform <platform>   目标平台 (默认: linux/amd64,linux/arm64)"
    echo "  --cache                  启用构建缓存"
    echo "  --help                   显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --version v1.0.0 --push"
    echo "  $0 --registry ghcr.io --namespace myorg --version latest"
    echo ""
}

# 默认参数
REGISTRY="ghcr.io"
NAMESPACE=""
VERSION="latest"
PUSH=false
PLATFORM="linux/amd64,linux/arm64"
CACHE=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --push)
            PUSH=true
            shift
            ;;
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --cache)
            CACHE=true
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

# 获取Git仓库信息
if [ -z "$NAMESPACE" ]; then
    if [ -n "$GITHUB_REPOSITORY" ]; then
        NAMESPACE="$GITHUB_REPOSITORY"
    else
        NAMESPACE=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')
    fi
fi

# 获取Git提交哈希作为版本标签
GIT_SHA=$(git rev-parse --short HEAD)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo -e "${BLUE}🚀 Docker镜像构建和推送${NC}"
echo "================================================"
echo -e "${YELLOW}仓库: $REGISTRY/$NAMESPACE${NC}"
echo -e "${YELLOW}版本: $VERSION${NC}"
echo -e "${YELLOW}Git SHA: $GIT_SHA${NC}"
echo -e "${YELLOW}时间戳: $TIMESTAMP${NC}"
echo -e "${YELLOW}平台: $PLATFORM${NC}"
echo -e "${YELLOW}推送: $PUSH${NC}"
echo ""

# 检查Docker是否可用
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker未安装或不可用${NC}"
    exit 1
fi

# 检查Docker Buildx是否可用
if ! docker buildx version &> /dev/null; then
    echo -e "${RED}❌ Docker Buildx不可用${NC}"
    exit 1
fi

# 设置构建缓存参数
CACHE_ARGS=""
if [ "$CACHE" = true ]; then
    CACHE_ARGS="--cache-from type=gha --cache-to type=gha,mode=max"
fi

# 构建后端镜像
build_backend() {
    echo -e "${GREEN}🔨 构建后端镜像...${NC}"
    
    local tags=(
        "$REGISTRY/$NAMESPACE-backend:$VERSION"
        "$REGISTRY/$NAMESPACE-backend:$GIT_SHA"
        "$REGISTRY/$NAMESPACE-backend:$TIMESTAMP"
    )
    
    if [ "$VERSION" = "latest" ]; then
        tags+=("$REGISTRY/$NAMESPACE-backend:latest")
    fi
    
    local tag_args=""
    for tag in "${tags[@]}"; do
        tag_args="$tag_args --tag $tag"
    done
    
    local push_arg=""
    if [ "$PUSH" = true ]; then
        push_arg="--push"
    fi
    
    docker buildx build \
        --platform "$PLATFORM" \
        $tag_args \
        $push_arg \
        $CACHE_ARGS \
        ./enterprise-backend
    
    echo -e "${GREEN}✅ 后端镜像构建完成${NC}"
}

# 构建前端镜像
build_frontend() {
    echo -e "${GREEN}🔨 构建前端镜像...${NC}"
    
    local tags=(
        "$REGISTRY/$NAMESPACE-frontend:$VERSION"
        "$REGISTRY/$NAMESPACE-frontend:$GIT_SHA"
        "$REGISTRY/$NAMESPACE-frontend:$TIMESTAMP"
    )
    
    if [ "$VERSION" = "latest" ]; then
        tags+=("$REGISTRY/$NAMESPACE-frontend:latest")
    fi
    
    local tag_args=""
    for tag in "${tags[@]}"; do
        tag_args="$tag_args --tag $tag"
    done
    
    local push_arg=""
    if [ "$PUSH" = true ]; then
        push_arg="--push"
    fi
    
    docker buildx build \
        --platform "$PLATFORM" \
        $tag_args \
        $push_arg \
        $CACHE_ARGS \
        ./enterprise-frontend
    
    echo -e "${GREEN}✅ 前端镜像构建完成${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}开始构建镜像...${NC}"
    
    # 构建后端镜像
    build_backend
    
    # 构建前端镜像
    build_frontend
    
    echo ""
    echo -e "${GREEN}🎉 所有镜像构建完成！${NC}"
    echo ""
    
    if [ "$PUSH" = true ]; then
        echo -e "${YELLOW}📋 推送的镜像标签:${NC}"
        echo "后端:"
        echo "  - $REGISTRY/$NAMESPACE-backend:$VERSION"
        echo "  - $REGISTRY/$NAMESPACE-backend:$GIT_SHA"
        echo "  - $REGISTRY/$NAMESPACE-backend:$TIMESTAMP"
        if [ "$VERSION" = "latest" ]; then
            echo "  - $REGISTRY/$NAMESPACE-backend:latest"
        fi
        echo ""
        echo "前端:"
        echo "  - $REGISTRY/$NAMESPACE-frontend:$VERSION"
        echo "  - $REGISTRY/$NAMESPACE-frontend:$GIT_SHA"
        echo "  - $REGISTRY/$NAMESPACE-frontend:$TIMESTAMP"
        if [ "$VERSION" = "latest" ]; then
            echo "  - $REGISTRY/$NAMESPACE-frontend:latest"
        fi
    else
        echo -e "${YELLOW}💡 使用 --push 参数推送到仓库${NC}"
    fi
}

# 运行主函数
main
