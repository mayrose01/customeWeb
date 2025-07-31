# 统一环境配置指南

## 概述

本项目已统一环境配置，使用域名和端口区分不同环境。

## 环境配置

### 1. 本地开发环境
- **访问地址**: `http://localhost:3000`
- **API地址**: `http://localhost:8000/api`
- **端口**: 3000 (前端), 8000 (后端)
- **数据库**: 本地MySQL
- **配置文件**: `env.development`

### 2. 测试环境
- **访问地址**: `http://test.catusfoto.top:3001`
- **API地址**: `http://test.catusfoto.top:8000/api`
- **端口**: 3001 (前端), 8000 (后端)
- **数据库**: 测试MySQL
- **配置文件**: `env.test`

### 3. 生产环境
- **访问地址**: `https://catusfoto.top`
- **API地址**: `https://catusfoto.top/api`
- **端口**: 443
- **数据库**: 生产MySQL
- **配置文件**: `env.production`

## 启动命令

### 开发环境
```bash
# 启动开发环境（前端+后端）
npm run dev

# 仅启动前端开发服务器
npm run vite

# 访问地址
http://localhost:3000
```

### 测试环境
```bash
# 本地模拟测试环境
npm run dev:test-local

# 构建测试环境
npm run build:test

# 访问地址
http://test.catusfoto.top:3001
```

### 生产环境
```bash
# 构建生产环境
npm run build:prod

# 访问地址
https://catusfoto.top
```

## 环境切换

### 使用脚本切换环境
```bash
# 切换到开发环境
./scripts/switch-env.sh development

# 切换到测试环境
./scripts/switch-env.sh test

# 切换到生产环境
./scripts/switch-env.sh production
```

### 使用npm命令切换
```bash
# 切换到开发环境
npm run env:dev

# 切换到测试环境
npm run env:test

# 切换到生产环境
npm run env:prod
```

## Hosts配置

### 本地测试环境配置
在 `/etc/hosts` 文件中添加：
```
127.0.0.1 test.catusfoto.top
```

### 验证hosts配置
```bash
# 检查hosts配置
grep "test.catusfoto.top" /etc/hosts

# 测试域名解析
ping test.catusfoto.top
```

## 环境检测机制

### 1. 环境变量优先级（最高）
- `VITE_APP_ENV`: 直接指定环境

### 2. 域名和端口检测（次优先级）
- `localhost:3000` → 开发环境
- `localhost:3001` → 测试环境
- `test.catusfoto.top` → 测试环境
- `catusfoto.top` → 生产环境

### 3. 默认环境
- 其他域名默认为生产环境

## 配置文件说明

### env.config.js
- 环境配置的核心文件
- 定义各环境的API地址
- 提供环境检测逻辑

### env.development
- 开发环境配置
- 端口：3000
- 主机：localhost

### env.test
- 测试环境配置
- 端口：3001
- 主机：test.catusfoto.top

### env.production
- 生产环境配置
- 端口：443
- 主机：catusfoto.top

## 环境测试

### 访问测试页面
- 开发环境: `http://localhost:3000/env-test`
- 测试环境: `http://test.catusfoto.top:3001/env-test`
- 生产环境: `https://catusfoto.top/env-test`

### 测试内容
- 当前环境信息
- API连接状态
- 配置详情对比

### 运行完整环境测试
```bash
./scripts/test-full-env.sh
```

## 部署说明

### 开发环境部署
1. 确保后端服务运行在 `localhost:8000`
2. 运行 `npm run dev`
3. 访问 `http://localhost:3000`

### 测试环境部署
1. 配置hosts文件映射 `test.catusfoto.top`
2. 确保后端服务运行在 `test.catusfoto.top:8000`
3. 运行 `npm run build:test`
4. 将 `dist` 目录部署到测试服务器
5. 访问 `http://test.catusfoto.top:3001`

### 生产环境部署
1. 确保后端服务运行在 `catusfoto.top:443`
2. 运行 `npm run build:prod`
3. 将 `dist` 目录部署到生产服务器
4. 访问 `https://catusfoto.top`

## 故障排除

### 常见问题

#### 1. 端口被占用
```bash
# 检查端口占用
lsof -i :3000
lsof -i :3001
lsof -i :8000

# 停止占用端口的服务
kill -9 <PID>
```

#### 2. Hosts配置不生效
```bash
# 刷新DNS缓存
sudo dscacheutil -flushcache

# 重启网络服务
sudo ifconfig en0 down && sudo ifconfig en0 up
```

#### 3. API连接失败
- 检查后端服务是否运行
- 检查防火墙设置
- 检查CORS配置

#### 4. 环境检测错误
- 检查 `env.config.js` 配置
- 检查环境变量设置
- 检查域名解析

## 注意事项

1. **端口配置**: 开发环境使用3000端口，测试环境使用3001端口，避免权限问题
2. **域名区分**: 通过域名和端口组合区分环境
3. **环境隔离**: 不同环境使用不同的数据库和配置
4. **安全考虑**: 生产环境使用HTTPS，测试环境使用HTTP
5. **缓存清理**: 切换环境后可能需要清理浏览器缓存

## 更新日志

- **2024-07-31**: 统一环境配置，使用端口区分避免权限问题
- 开发环境: `http://localhost:3000`
- 测试环境: `http://test.catusfoto.top:3001`
- 生产环境: `https://catusfoto.top`
- 添加完整环境测试脚本
- 完善部署脚本和文档 