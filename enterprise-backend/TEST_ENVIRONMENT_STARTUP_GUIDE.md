# 测试环境启动指南

## 🎯 问题解决

### 问题1: ModuleNotFoundError: No module named 'dotenv'
**原因**: 在错误的目录下运行命令
**解决**: 确保在 `enterprise-backend` 目录下运行

### 问题2: ModuleNotFoundError: No module named 'app'
**原因**: 在错误的目录下运行命令
**解决**: 确保在 `enterprise-backend` 目录下运行

### 问题3: 域名无法解析
**原因**: `test.catusfoto.top` 域名未在 `/etc/hosts` 中映射
**解决**: 已添加域名映射 `127.0.0.1 test.catusfoto.top`

## ✅ 正确的启动步骤

### 1. 进入正确的目录
```bash
cd enterprise-backend
pwd  # 应该显示 /Users/huangqing/enterprise/enterprise-backend
```

### 2. 激活虚拟环境
```bash
source .venv/bin/activate
```

### 3. 设置环境变量
```bash
export ENV=test
export DATABASE_URL="mysql+pymysql://root:root@localhost:3306/enterprise_test"
```

### 4. 启动测试环境
```bash
python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

## 🌐 访问地址

### 本地访问
- **API文档**: http://localhost:8001/docs
- **登录API**: http://localhost:8001/api/user/login
- **管理后台**: http://localhost:3001/admin/login

### 远程访问（使用域名）
- **API文档**: http://test.catusfoto.top:8001/docs
- **登录API**: http://test.catusfoto.top:8001/api/user/login
- **管理后台**: http://test.catusfoto.top:3001/admin/login

## 🔍 验证步骤

### 1. 检查服务状态
```bash
# 检查后端服务
curl -s http://localhost:8001/docs

# 检查远程访问
curl -s http://test.catusfoto.top:8001/docs

# 检查域名解析
ping test.catusfoto.top
```

### 2. 测试API端点
```bash
# 测试登录API
curl -X POST http://test.catusfoto.top:8001/api/user/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 3. 检查进程状态
```bash
# 查看运行中的服务
ps aux | grep uvicorn

# 检查端口占用
lsof -i :8001
```

## 📋 环境配置

### 数据库配置
- **数据库名**: `enterprise_test`
- **用户名**: `root`
- **密码**: `root`
- **主机**: `localhost`
- **端口**: `3306`

### 服务配置
- **后端端口**: 8001
- **前端端口**: 3001
- **环境**: test
- **域名**: test.catusfoto.top

### 域名映射
```
127.0.0.1 test.catusfoto.top
```

## 🚀 快速启动脚本

### 使用启动脚本
```bash
cd enterprise-backend
./start_test_backend.sh
```

### 使用验证脚本
```bash
cd enterprise-backend
./test_environment.sh
```

## ⚠️ 常见问题

### 问题1: 端口被占用
```bash
# 检查端口占用
lsof -i :8001

# 杀死占用进程
kill -9 <PID>

# 或使用其他端口
python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8002
```

### 问题2: 数据库连接失败
```bash
# 创建测试数据库
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 初始化数据库
mysql -u root -p enterprise_test < ../mysql/init.sql
```

### 问题3: 域名解析失败
```bash
# 检查hosts文件
grep test.catusfoto.top /etc/hosts

# 重新添加域名映射
echo "127.0.0.1 test.catusfoto.top" | sudo tee -a /etc/hosts
```

## 📊 成功标志

当测试环境成功启动时，您应该看到：

1. **服务启动信息**:
   ```
   INFO:     Uvicorn running on http://0.0.0.0:8001 (Press CTRL+C to quit)
   INFO:     Started reloader process [xxxxx] using StatReload
   ```

2. **API文档可访问**:
   - http://localhost:8001/docs
   - http://test.catusfoto.top:8001/docs

3. **域名解析正常**:
   ```bash
   ping test.catusfoto.top  # 应该返回 127.0.0.1
   ```

4. **数据库连接正常**:
   - 没有数据库连接错误
   - 可以正常访问 API 端点

## 🎉 总结

现在您的测试环境应该可以正常工作了！

- **本地访问**: http://localhost:8001/api/
- **远程访问**: http://test.catusfoto.top:8001/api/

两个地址都应该可以正常访问，前提是：
1. 在正确的目录下运行命令 (`enterprise-backend`)
2. 虚拟环境已激活
3. 环境变量已设置
4. 域名映射已添加
5. 数据库已创建并初始化 