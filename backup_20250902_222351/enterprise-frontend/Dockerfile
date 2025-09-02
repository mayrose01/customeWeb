# 构建阶段
FROM node:18-alpine as build-stage

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV NODE_ENV=production
ENV ROLLUP_SKIP_NATIVE=true
ENV VITE_SKIP_NATIVE=true

# 复制package文件
COPY package*.json ./

# 清理并重新安装依赖
RUN rm -rf node_modules package-lock.json
RUN npm install --legacy-peer-deps --platform=linux --arch=x64

# 复制源代码
COPY . .

# 构建应用（使用简单构建）
RUN npm run build

# 生产阶段
FROM nginx:alpine as production-stage

# 复制构建产物到nginx目录
COPY --from=build-stage /app/dist /usr/share/nginx/html

# 复制nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"] 