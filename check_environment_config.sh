#!/bin/bash

# 环境配置检查脚本
# 用于检查环境配置是否正确设置

set -e

echo "🔍 环境配置检查"
echo "================================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_env_var() {
    local var_name=$1
    local var_value=$2
    local required=$3
    
    if [ -z "$var_value" ]; then
        if [ "$required" = "true" ]; then
            echo -e "${RED}❌ $var_name: 未设置 (必需)${NC}"
            return 1
        else
            echo -e "${YELLOW}⚠️  $var_name: 未设置 (可选)${NC}"
            return 0
        fi
    else
        # 隐藏敏感信息
        if [[ "$var_name" == *"PASSWORD"* ]] || [[ "$var_name" == *"SECRET"* ]] || [[ "$var_name" == *"KEY"* ]]; then
            echo -e "${GREEN}✅ $var_name: 已设置 (${#var_value} 字符)${NC}"
        else
            echo -e "${GREEN}✅ $var_name: $var_value${NC}"
        fi
        return 0
    fi
}

# 检查环境
echo "📋 当前环境: ${ENVIRONMENT:-未设置}"
echo ""

# 基础配置检查
echo "🔧 基础配置:"
check_env_var "ENVIRONMENT" "$ENVIRONMENT" "true"
check_env_var "DEBUG" "$DEBUG" "false"
echo ""

# 数据库配置检查
echo "🗄️  数据库配置:"
check_env_var "DATABASE_URL" "$DATABASE_URL" "true"
check_env_var "DB_HOST" "$DB_HOST" "false"
check_env_var "DB_PORT" "$DB_PORT" "false"
check_env_var "DB_DATABASE" "$DB_DATABASE" "false"
check_env_var "DB_USERNAME" "$DB_USERNAME" "false"
check_env_var "DB_PASSWORD" "$DB_PASSWORD" "false"
echo ""

# JWT配置检查
echo "🔐 JWT配置:"
check_env_var "SECRET_KEY" "$SECRET_KEY" "true"
check_env_var "ALGORITHM" "$ALGORITHM" "false"
check_env_var "ACCESS_TOKEN_EXPIRE_MINUTES" "$ACCESS_TOKEN_EXPIRE_MINUTES" "false"
echo ""

# CORS配置检查
echo "🌐 CORS配置:"
check_env_var "CORS_ORIGINS" "$CORS_ORIGINS" "false"
echo ""

# 邮件配置检查
echo "📧 邮件配置:"
check_env_var "SMTP_SERVER" "$SMTP_SERVER" "false"
check_env_var "SMTP_PORT" "$SMTP_PORT" "false"
check_env_var "SMTP_USERNAME" "$SMTP_USERNAME" "false"
check_env_var "SMTP_PASSWORD" "$SMTP_PASSWORD" "false"
check_env_var "SMTP_USE_TLS" "$SMTP_USE_TLS" "false"
echo ""

# 文件上传配置检查
echo "📁 文件上传配置:"
check_env_var "UPLOAD_DIR" "$UPLOAD_DIR" "false"
check_env_var "MAX_FILE_SIZE" "$MAX_FILE_SIZE" "false"
check_env_var "ALLOWED_EXTENSIONS" "$ALLOWED_EXTENSIONS" "false"
echo ""

# 日志配置检查
echo "📝 日志配置:"
check_env_var "LOG_LEVEL" "$LOG_LEVEL" "false"
check_env_var "LOG_FILE" "$LOG_FILE" "false"
echo ""

# 服务器配置检查
echo "🖥️  服务器配置:"
check_env_var "BACKEND_HOST" "$BACKEND_HOST" "false"
check_env_var "BACKEND_PORT" "$BACKEND_PORT" "false"
echo ""

# 前端配置检查
echo "🎨 前端配置:"
check_env_var "VITE_API_BASE_URL" "$VITE_API_BASE_URL" "false"
check_env_var "VITE_APP_TITLE" "$VITE_APP_TITLE" "false"
echo ""

# 检查配置文件是否存在
echo "📄 配置文件检查:"
if [ -f ".env" ]; then
    echo -e "${GREEN}✅ .env 文件存在${NC}"
else
    echo -e "${YELLOW}⚠️  .env 文件不存在${NC}"
fi

if [ -f ".env.${ENVIRONMENT:-development}" ]; then
    echo -e "${GREEN}✅ .env.${ENVIRONMENT:-development} 文件存在${NC}"
else
    echo -e "${YELLOW}⚠️  .env.${ENVIRONMENT:-development} 文件不存在${NC}"
fi

if [ -f "env.${ENVIRONMENT:-development}.example" ]; then
    echo -e "${GREEN}✅ env.${ENVIRONMENT:-development}.example 文件存在${NC}"
else
    echo -e "${YELLOW}⚠️  env.${ENVIRONMENT:-development}.example 文件不存在${NC}"
fi
echo ""

# 安全建议
echo "🛡️  安全建议:"
if [ "$ENVIRONMENT" = "production" ]; then
    if [ "$DEBUG" = "true" ]; then
        echo -e "${RED}❌ 生产环境不应启用DEBUG模式${NC}"
    else
        echo -e "${GREEN}✅ 生产环境已禁用DEBUG模式${NC}"
    fi
    
    if [ ${#SECRET_KEY} -lt 32 ]; then
        echo -e "${RED}❌ 生产环境SECRET_KEY长度不足32位${NC}"
    else
        echo -e "${GREEN}✅ 生产环境SECRET_KEY长度足够${NC}"
    fi
else
    echo -e "${GREEN}✅ 非生产环境，安全检查通过${NC}"
fi
echo ""

# 总结
echo "================================================"
echo "🎯 配置检查完成"
echo ""
echo "💡 提示:"
echo "   - 如果看到 ❌ 错误，请设置相应的环境变量"
echo "   - 如果看到 ⚠️  警告，可以设置可选的环境变量"
echo "   - 生产环境请确保所有必需配置都已正确设置"
echo ""
echo "📖 更多信息请参考: ENVIRONMENT_CONFIGURATION_GUIDE.md"
