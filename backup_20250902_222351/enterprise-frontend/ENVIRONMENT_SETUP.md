# 🌍 环境配置说明

## 📋 环境概览

本项目支持多环境部署，包括：

- **开发环境 (development)**: 本地开发
- **测试环境 (test)**: 测试服务器
- **生产环境 (production)**: 正式服务器

## 🔧 环境配置

### 1. 环境变量文件

项目使用以下环境变量文件：

- `.env.development` - 开发环境配置
- `.env.production` - 生产环境配置
- `.env.local` - 本地覆盖配置（git忽略）

### 2. API基础URL配置

| 环境 | API基础URL | 说明 |
|------|------------|------|
| development | `http://localhost:8000/api` | 本地开发 |
| test | `http://test.catusfoto.top/api` | 测试环境 |
| production | `https://catusfoto.top/api` | 生产环境 |

## 🚀 使用方法

### 1. 环境切换

```bash
# 切换到开发环境
npm run env:dev

# 切换到测试环境
npm run env:test

# 切换到生产环境
npm run env:prod
```

### 2. 构建不同环境

```bash
# 构建开发版本
npm run build:dev

# 构建测试版本
npm run build:test

# 构建生产版本
npm run build:prod
```

### 3. 一键部署

```bash
# 部署到开发环境
npm run deploy:dev

# 部署到测试环境
npm run deploy:test

# 部署到生产环境
npm run deploy:prod
```

## 📁 文件结构

```
enterprise-frontend/
├── env.config.js          # 环境配置逻辑
├── scripts/
│   └── switch-env.sh      # 环境切换脚本
├── .env.development       # 开发环境变量
├── .env.production        # 生产环境变量
├── env.example           # 环境变量示例
└── ENVIRONMENT_SETUP.md  # 本文档
```

## 🔄 自动环境检测

系统会根据当前域名自动检测环境：

- `localhost` 或 `127.0.0.1` → 开发环境
- 包含 `test.` 的域名 → 测试环境
- 其他域名 → 生产环境

## 📝 自定义配置

### 1. 添加新的环境变量

在 `env.config.js` 中添加新的环境配置：

```javascript
const envConfig = {
  development: {
    API_BASE_URL: 'http://localhost:8000/api',
    APP_ENV: 'development',
    // 添加新的配置项
    NEW_CONFIG: 'value'
  },
  // ... 其他环境
};
```

### 2. 在代码中使用

```javascript
import { config } from '../env.config.js';

// 使用配置
console.log(config.API_BASE_URL);
console.log(config.NEW_CONFIG);
```

## 🛠️ 故障排除

### 1. 环境变量不生效

检查以下几点：
- 确保环境变量文件存在
- 重启开发服务器
- 清除浏览器缓存

### 2. API请求失败

检查API基础URL是否正确：
- 开发环境：确保后端服务在8000端口运行
- 生产环境：确保域名解析正确

### 3. 构建失败

检查Node.js版本和依赖：
```bash
node --version
npm install
```

## 📞 支持

如有问题，请检查：
1. 环境变量配置
2. 网络连接
3. 服务器状态
4. 域名解析 