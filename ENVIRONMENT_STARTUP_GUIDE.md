# 环境启动指南

## 快速启动

### 开发环境
```bash
./start_dev.sh
```

### 测试环境
```bash
./start_test.sh
```

## 手动启动方法

### 1. 开发环境

#### 启动后端
```bash
cd enterprise-backend
ENV=development python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --env-file dev.env
```

#### 启动前端
```bash
cd enterprise-frontend
npm run dev -- --mode development --port 3000
```

### 2. 测试环境

#### 启动后端
```bash
cd enterprise-backend
ENV=test python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload --env-file test.env
```

#### 启动前端
```bash
cd enterprise-frontend
npm run dev -- --mode test --port 3001
```

## 环境配置

### 开发环境
- **后端端口**: 8000
- **前端端口**: 3000
- **数据库**: enterprise_dev (端口3306)
- **配置文件**: dev.env
- **环境变量**: ENV=development

### 测试环境
- **后端端口**: 8001
- **前端端口**: 3001
- **数据库**: enterprise_test (端口3307)
- **配置文件**: test.env
- **环境变量**: ENV=test

## 访问地址

### 开发环境
- 前端: http://localhost:3000
- 后端API: http://localhost:8000/api
- 管理后台: http://localhost:3000/admin

### 测试环境
- 前端: http://localhost:3001
- 后端API: http://localhost:8001/api
- 管理后台: http://localhost:3001/admin

## 数据库连接

### 开发环境数据库
```bash
mysql -u root -proot -D enterprise_dev
```

### 测试环境数据库
```bash
mysql -h 127.0.0.1 -P 3307 -u test_user -ptest_password -D enterprise_test
```

## 停止服务

### 停止开发环境
```bash
pkill -f "uvicorn.*8000"
pkill -f "vite.*3000"
```

### 停止测试环境
```bash
pkill -f "uvicorn.*8001"
pkill -f "vite.*3001"
```

## 查看日志

### 开发环境日志
```bash
tail -f enterprise-backend/logs/app_$(date +%Y%m%d).log
```

### 测试环境日志
```bash
tail -f enterprise-backend/logs/app_test.log
```

## 注意事项

1. **环境隔离**: 确保每个环境使用对应的数据库和配置
2. **端口冲突**: 启动前检查端口是否被占用
3. **环境变量**: 必须设置正确的 ENV 环境变量
4. **数据库状态**: 确保对应的数据库服务正在运行

## 故障排除

### 端口被占用
```bash
lsof -i :8000  # 检查开发环境后端端口
lsof -i :8001  # 检查测试环境后端端口
lsof -i :3000  # 检查开发环境前端端口
lsof -i :3001  # 检查测试环境前端端口
```

### 数据库连接失败
```bash
# 检查MySQL服务
brew services list | grep mysql

# 检查测试环境数据库
docker ps | grep mysql
```

### 环境变量问题
确保启动时设置了正确的环境变量：
- 开发环境: `ENV=development`
- 测试环境: `ENV=test` 