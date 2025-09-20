# 企业官网前端服务 Dockerfile
# 适用于所有环境：开发、测试、生产

# 构建阶段
FROM node:24-alpine as build-stage

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV NODE_ENV=production \
    ROLLUP_SKIP_NATIVE=true \
    VITE_SKIP_NATIVE=true

# 复制package文件（利用Docker层缓存）
COPY package*.json ./

# 复制源代码
COPY . .

# 安装所有依赖（包括devDependencies，因为构建需要vite）
RUN npm install --include=dev

# 构建应用 - 根据构建参数设置环境
ARG VITE_APP_ENV=production
ARG VITE_API_BASE_URL
ENV VITE_APP_ENV=${VITE_APP_ENV}
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
RUN npm run build

# 生产阶段
FROM nginx:alpine as production-stage

# 安装curl用于健康检查
RUN apk add --no-cache curl

# 复制构建产物到nginx目录
COPY --from=build-stage /app/dist /usr/share/nginx/html

# 复制nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 创建非root用户（安全最佳实践）
RUN addgroup -g 1001 -S appuser && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G appuser -g appuser appuser

# 健康检查
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"] 