# 依赖版本管理指南

## 问题分析

### 当前问题
1. **版本不一致**：不同环境使用不同版本的依赖库
2. **包名格式差异**：同一包在不同环境下显示的名称不同
3. **缺少版本锁定**：requirements.txt 没有指定精确版本号

### 影响
- 密码哈希生成不一致
- 数据库操作行为差异
- 运行时错误和异常

## 解决方案

### 1. 版本锁定文件

使用 `requirements-lock.txt` 确保所有环境使用相同版本：

```bash
# 生成精确的依赖锁定文件
pip freeze > requirements-lock.txt

# 安装精确版本
pip install -r requirements-lock.txt
```

### 2. 环境同步脚本

运行 `sync_dependencies.sh` 来同步依赖版本：

```bash
./sync_dependencies.sh
```

### 3. 部署检查清单

#### 开发环境
```bash
# 1. 更新依赖
pip install -r requirements-lock.txt

# 2. 验证版本
pip freeze | grep -E "(fastapi|passlib|bcrypt)"

# 3. 测试密码哈希
python -c "from passlib.context import CryptContext; pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto'); print(pwd_context.hash('test123'))"
```

#### 测试环境
```bash
# 1. 在Docker容器中更新依赖
docker exec -it <container_name> pip install -r requirements-lock.txt

# 2. 重启服务
docker-compose restart backend
```

#### 生产环境
```bash
# 1. 备份当前环境
cp requirements.txt requirements.txt.backup

# 2. 更新依赖文件
scp requirements-lock.txt root@server:/var/www/enterprise/enterprise-backend/

# 3. 在生产环境更新依赖
ssh root@server "cd /var/www/enterprise/enterprise-backend && source venv/bin/activate && pip install -r requirements-lock.txt"

# 4. 重启服务
ssh root@server "systemctl restart enterprise-backend"
```

## 最佳实践

### 1. 版本管理策略
- 使用 `requirements-lock.txt` 锁定精确版本
- 定期更新依赖版本（每月或每季度）
- 在更新前测试所有环境

### 2. 环境一致性
- 使用相同的Python版本（建议3.9+）
- 使用Docker容器确保环境隔离
- 定期同步所有环境的依赖版本

### 3. 部署流程
```bash
# 部署前检查
1. 更新 requirements-lock.txt
2. 在所有环境测试依赖安装
3. 验证密码哈希生成一致性
4. 部署到生产环境
```

### 4. 监控和验证
- 定期检查各环境的依赖版本
- 监控密码哈希相关的错误日志
- 建立依赖版本变更的测试流程

## 当前版本状态

### 核心依赖版本
- fastapi==0.116.1
- uvicorn==0.35.0
- sqlalchemy==2.0.42
- pydantic==2.11.7
- passlib==1.7.4
- bcrypt==4.3.0
- python-jose==3.5.0

### 环境检查命令
```bash
# 检查当前环境版本
pip freeze | grep -E "(fastapi|uvicorn|sqlalchemy|pydantic|passlib|bcrypt)"

# 验证密码哈希一致性
python -c "from passlib.context import CryptContext; pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto'); print('Hash:', pwd_context.hash('admin123'))"
``` 