# 测试环境快速启动指南

## 🚀 快速启动

### 方法一：使用启动脚本（推荐）

```bash
# 进入后端目录
cd enterprise-backend

# 运行启动脚本
./start_test_backend.sh
```

### 方法二：手动启动

```bash
# 1. 进入后端目录
cd enterprise-backend

# 2. 激活虚拟环境
source .venv/bin/activate

# 3. 设置环境变量
export ENV=test
export DATABASE_URL="mysql+pymysql://root:root@localhost:3306/enterprise_test"

# 4. 启动服务
python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

## 📋 访问信息

启动成功后，您可以访问：

- **API 文档**: http://localhost:8001/docs
- **数据库**: `enterprise_test`
- **端口**: 8001
- **环境**: test

## 🔍 环境验证

运行验证脚本检查环境状态：

```bash
cd enterprise-backend
./test_environment.sh
```

## 🛠️ 故障排除

### 问题 1: ModuleNotFoundError: No module named 'dotenv'

**解决方案**:
```bash
cd enterprise-backend
source .venv/bin/activate
pip install python-dotenv
```

### 问题 2: ModuleNotFoundError: No module named 'app'

**解决方案**:
```bash
# 确保在正确的目录下
cd enterprise-backend
source .venv/bin/activate
python -c "import app; print('✅ app 模块导入成功')"
```

### 问题 3: 数据库连接失败

**解决方案**:
```bash
# 创建测试数据库
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 初始化数据库
mysql -u root -p enterprise_test < ../mysql/init.sql
```

### 问题 4: 端口被占用

**解决方案**:
```bash
# 检查端口占用
lsof -i :8001

# 使用其他端口
ENV=test python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8002
```

## 📝 环境配置

### 数据库配置
- **数据库名**: `enterprise_test`
- **用户名**: `root`
- **密码**: `root`
- **主机**: `localhost`
- **端口**: `3306`

### 环境变量
```bash
ENV=test
DATABASE_URL=mysql+pymysql://root:root@localhost:3306/enterprise_test
```

### 服务配置
- **端口**: 8001
- **主机**: 0.0.0.0
- **重载**: 启用
- **日志级别**: INFO

## 🎯 成功标志

当测试环境成功启动时，您应该看到：

1. **服务启动信息**:
   ```
   INFO:     Uvicorn running on http://0.0.0.0:8001 (Press CTRL+C to quit)
   INFO:     Started reloader process [xxxxx] using StatReload
   ```

2. **API 文档可访问**:
   - 访问 http://localhost:8001/docs
   - 显示 Swagger UI 界面

3. **数据库连接正常**:
   - 没有数据库连接错误
   - 可以正常访问 API 端点

## 📚 相关文档

- [测试环境故障排除指南](TEST_ENVIRONMENT_TROUBLESHOOTING.md)
- [数据库名称修改总结](../DATABASE_NAMES_UPDATE.md)
- [测试环境说明](../TEST_ENVIRONMENT_README.md)

## 🆘 获取帮助

如果遇到问题：

1. 运行 `./test_environment.sh` 检查环境状态
2. 查看 [故障排除指南](TEST_ENVIRONMENT_TROUBLESHOOTING.md)
3. 检查错误日志
4. 确认所有依赖已正确安装 