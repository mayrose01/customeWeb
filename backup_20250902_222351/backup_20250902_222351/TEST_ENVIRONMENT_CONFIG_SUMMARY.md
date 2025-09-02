# 测试环境配置总结

## 🎯 测试环境地址配置

### 本地测试环境
- **前端地址**: http://localhost:3001
- **后端API**: http://localhost:8001/api
- **数据库**: enterprise_test
- **环境**: test

### 远程测试环境
- **前端地址**: http://test.catusfoto.top:3001
- **后端API**: http://test.catusfoto.top:8001/api
- **数据库**: enterprise_test
- **环境**: test

## 📋 配置文件更新

### 1. 前端配置更新

#### `enterprise-frontend/env.config.js`
```javascript
// 测试环境配置
test: {
  API_BASE_URL: 'http://localhost:8001/api',  // 本地测试
  APP_ENV: 'test'
}
```

#### `enterprise-frontend/env.test`
```bash
# API基础URL
VITE_API_BASE_URL=http://test.catusfoto.top:8001/api  # 远程测试
```

### 2. 后端配置更新

#### `enterprise-backend/test.env`
```bash
# CORS配置
CORS_ORIGINS=["http://localhost", "http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "http://localhost:8080", "http://test.catusfoto.top", "http://test.catusfoto.top:3001"]
```

#### `docker-compose.test.yml`
```yaml
# 后端服务配置
backend_test:
  environment:
    - CORS_ORIGINS=["http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "http://test.catusfoto.top:3001", "http://test.catusfoto.top"]
  ports:
    - "8001:8000"  # 端口映射

# 前端服务配置
frontend_test:
  environment:
    - VITE_API_BASE_URL=http://test.catusfoto.top:8001/api
  ports:
    - "3001:80"
```

## 🚀 启动方式

### 方式一：本地开发测试
```bash
# 启动后端
cd enterprise-backend
source .venv/bin/activate
export ENV=test
export DATABASE_URL="mysql+pymysql://root:root@localhost:3306/enterprise_test"
python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001

# 启动前端
cd enterprise-frontend
npm run dev -- --port 3001
```

### 方式二：Docker 测试环境
```bash
# 启动完整的测试环境
docker-compose -f docker-compose.test.yml up -d

# 查看服务状态
docker-compose -f docker-compose.test.yml ps

# 查看日志
docker-compose -f docker-compose.test.yml logs -f
```

### 方式三：使用启动脚本
```bash
# 使用后端启动脚本
cd enterprise-backend
./start_test_backend.sh

# 使用环境验证脚本
cd enterprise-backend
./test_environment.sh
```

## 🔍 验证步骤

### 1. 检查服务状态
```bash
# 检查后端服务
curl -s http://localhost:8001/docs

# 检查前端服务
curl -s http://localhost:3001

# 检查数据库连接
mysql -u root -p enterprise_test -e "SELECT 1;"
```

### 2. 测试API端点
```bash
# 测试登录API
curl -X POST http://localhost:8001/api/user/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 3. 测试远程访问
```bash
# 运行远程API测试脚本
./test_remote_api.sh
```

## 🌐 访问地址

### 本地开发
- **管理后台**: http://localhost:3001/admin/login
- **API文档**: http://localhost:8001/docs
- **数据库**: localhost:3306/enterprise_test

### 远程测试
- **管理后台**: http://test.catusfoto.top:3001/admin/login
- **API文档**: http://test.catusfoto.top:8001/docs
- **数据库**: test.catusfoto.top:3306/enterprise_test

## ⚠️ 注意事项

### 1. 域名解析
如果使用 `test.catusfoto.top` 域名，需要在 `/etc/hosts` 文件中添加：
```
127.0.0.1 test.catusfoto.top
```

### 2. 端口配置
- **开发环境**: 前端 3000，后端 8000
- **测试环境**: 前端 3001，后端 8001
- **生产环境**: 前端 80，后端 8000

### 3. 数据库隔离
- **开发环境**: enterprise_dev
- **测试环境**: enterprise_test
- **生产环境**: enterprise_prod

### 4. CORS 配置
确保后端 CORS 配置包含所有前端域名：
```python
CORS_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:3001", 
    "http://test.catusfoto.top:3001",
    "http://test.catusfoto.top"
]
```

## 🔧 故障排除

### 问题 1: 502 Bad Gateway
**原因**: 后端服务未启动或端口配置错误
**解决**: 
```bash
# 检查后端服务状态
ps aux | grep uvicorn

# 重启后端服务
cd enterprise-backend
ENV=test python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

### 问题 2: CORS 错误
**原因**: 前端域名不在 CORS 允许列表中
**解决**: 更新后端 CORS 配置，添加前端域名

### 问题 3: 数据库连接失败
**原因**: 数据库未启动或配置错误
**解决**:
```bash
# 创建测试数据库
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 初始化数据库
mysql -u root -p enterprise_test < mysql/init.sql
```

## 📊 环境对比

| 项目 | 开发环境 | 测试环境 | 生产环境 |
|------|----------|----------|----------|
| 前端端口 | 3000 | 3001 | 80 |
| 后端端口 | 8000 | 8001 | 8000 |
| 数据库 | enterprise_dev | enterprise_test | enterprise_prod |
| 域名 | localhost | test.catusfoto.top | catusfoto.top |
| API地址 | localhost:8000 | test.catusfoto.top:8001 | catusfoto.top |

## ✅ 总结

现在测试环境已经正确配置为：
- **本地访问**: http://localhost:8001/api/
- **远程访问**: http://test.catusfoto.top:8001/api/

两个地址都应该可以正常工作，前提是：
1. 测试环境服务正在运行
2. 域名解析正确（如果使用远程地址）
3. CORS 配置正确
4. 数据库连接正常 