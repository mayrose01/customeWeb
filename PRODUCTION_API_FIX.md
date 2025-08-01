# 生产环境API配置修复方案

## 问题描述

生产环境网站 https://catusfoto.top/ 首页调用的是开发环境的接口 `http://localhost:8000/api/category/`，导致无法正常获取数据。

## 问题原因分析

1. **环境变量未正确设置**：生产环境构建时没有正确设置 `VITE_APP_ENV` 和 `VITE_API_BASE_URL` 环境变量
2. **构建配置问题**：`env.config.js` 中的环境判断逻辑在构建时没有正确识别生产环境
3. **vite.config.js 中的硬编码**：构建配置中包含了 `localhost:8000` 的默认值

## 解决方案

### 1. 修复 env.config.js

更新了环境配置逻辑，确保在构建时能正确识别生产环境：

```javascript
// 获取当前环境 - 基于域名和端口的可靠判断
const getCurrentEnv = () => {
  // 1. 使用环境变量（最高优先级）
  if (import.meta.env.VITE_APP_ENV) {
    console.log('使用环境变量 VITE_APP_ENV:', import.meta.env.VITE_APP_ENV);
    return import.meta.env.VITE_APP_ENV;
  }
  
  // 2. 检查是否在构建环境中（SSR或构建时）
  if (typeof window === 'undefined') {
    // 构建时环境，使用默认环境变量
    console.log('构建时环境，使用默认配置');
    return 'production'; // 默认使用生产环境
  }
  
  // 3. 基于域名判断
  const hostname = window.location.hostname;
  const port = window.location.port;
  
  if (hostname === 'catusfoto.top' || hostname === 'www.catusfoto.top') {
    return 'production';
  } else if (hostname === 'test.catusfoto.top' || hostname === 'localhost' && port === '3001') {
    return 'test';
  } else {
    return 'development';
  }
};
```

### 2. 修复 vite.config.js

移除了硬编码的 `localhost:8000`，改为根据环境动态设置：

```javascript
// 根据环境确定默认API地址
const getDefaultApiUrl = () => {
  if (mode === 'production') {
    return 'https://catusfoto.top/api'
  } else if (mode === 'test') {
    return 'http://test.catusfoto.top:8000/api'
  } else {
    return 'http://localhost:8000/api'
  }
}
```

### 3. 创建生产环境构建脚本

创建了 `scripts/deploy-production.sh` 脚本，确保正确设置环境变量：

```bash
#!/bin/bash

# 设置生产环境变量
export VITE_APP_ENV=production
export VITE_API_BASE_URL=https://catusfoto.top/api
export VITE_UPLOAD_PATH=/uploads
export VITE_PUBLIC_PATH=/
export VITE_DEBUG=false

# 执行生产环境构建
npm run build:prod
```

## 部署步骤

### 1. 本地测试构建

```bash
cd enterprise-frontend
./scripts/deploy-production.sh
```

### 2. 检查构建结果

脚本会自动检查：
- 是否还有 `localhost:8000` 的引用
- 是否包含正确的生产环境API地址 `catusfoto.top`

### 3. 部署到生产环境

将构建后的 `dist/` 目录部署到生产服务器。

## 验证方法

1. **检查构建文件**：
   ```bash
   grep -r "catusfoto.top" dist/
   grep -r "localhost:8000" dist/
   ```

2. **浏览器开发者工具**：
   - 打开 https://catusfoto.top/
   - 打开开发者工具的 Network 标签
   - 检查API请求是否指向正确的地址

3. **环境测试页面**：
   - 访问 https://catusfoto.top/env-test
   - 查看当前环境配置和API连接测试

## 预防措施

1. **CI/CD 集成**：在部署流程中集成环境变量检查
2. **自动化测试**：添加API连接测试
3. **环境配置文档**：维护清晰的环境配置文档

## 相关文件

- `enterprise-frontend/env.config.js` - 环境配置
- `enterprise-frontend/vite.config.js` - 构建配置
- `enterprise-frontend/scripts/deploy-production.sh` - 生产环境部署脚本
- `enterprise-frontend/scripts/build-prod.sh` - 生产环境构建脚本

## 注意事项

1. 确保生产环境的 nginx 配置正确代理 API 请求
2. 确保后端服务在生产环境正常运行
3. 部署前先在测试环境验证配置正确性 