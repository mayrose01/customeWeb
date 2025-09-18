# 🚀 现在该做什么？环境验证指南

## 📋 当前状态
您的CI/CD系统已经配置完成，现在需要验证所有环境是否正常工作。

## 🌍 环境概览
- **开发环境** (Development): 本地开发，端口8000/3000
- **测试环境** (Testing): Docker容器，端口8001/3001  
- **生产环境** (Production): Docker容器，端口8002/3002

## 🎯 第一步：验证本地开发环境

### 1.1 启动开发环境
```bash
# 进入项目目录
cd /Users/huangqing/enterprise

# 启动开发环境
./deploy.sh dev up
```

### 1.2 验证开发环境
```bash
# 检查服务状态
./deploy.sh dev status

# 验证健康检查
curl http://localhost:8000/health
curl http://localhost:8000/api/health

# 访问前端页面
open http://localhost:3000
```

### 1.3 预期结果
- ✅ 后端服务运行在 http://localhost:8000
- ✅ 前端服务运行在 http://localhost:3000
- ✅ 健康检查返回正常状态
- ✅ 前端页面正常加载

## 🎯 第二步：验证Docker测试环境

### 2.1 启动测试环境
```bash
# 启动测试环境
./deploy.sh test up
```

### 2.2 验证测试环境
```bash
# 检查服务状态
./deploy.sh test status

# 验证健康检查
curl http://localhost:8001/health
curl http://localhost:8001/api/health

# 访问前端页面
open http://localhost:3001
```

### 2.3 预期结果
- ✅ 后端服务运行在 http://localhost:8001
- ✅ 前端服务运行在 http://localhost:3001
- ✅ 健康检查返回正常状态
- ✅ 前端页面正常加载
- ✅ 数据库迁移执行成功

## 🎯 第三步：验证生产环境

### 3.1 准备生产环境
```bash
# 设置生产环境变量
source set_env.sh prod

# 检查环境变量
echo $DATABASE_URL
echo $SECRET_KEY
```

### 3.2 启动生产环境
```bash
# 启动生产环境
./deploy.sh prod up
```

### 3.3 验证生产环境
```bash
# 检查服务状态
./deploy.sh prod status

# 验证健康检查
curl http://localhost:8002/health
curl http://localhost:8002/api/health

# 访问前端页面
open http://localhost:3002
```

### 3.4 预期结果
- ✅ 后端服务运行在 http://localhost:8002
- ✅ 前端服务运行在 http://localhost:3002
- ✅ 健康检查返回正常状态
- ✅ 前端页面正常加载
- ✅ 数据库迁移执行成功

## 🔍 快速验证脚本

### 使用验证脚本
```bash
# 验证所有环境
./validate-environments.sh --all

# 快速验证（只检查服务状态）
./validate-environments.sh --quick --all

# 验证特定环境
./validate-environments.sh --dev
./validate-environments.sh --test
./validate-environments.sh --prod
```

## 🚨 常见问题排查

### 问题1：端口被占用
```bash
# 检查端口占用
lsof -i :8000
lsof -i :8001
lsof -i :8002
lsof -i :3000
lsof -i :3001
lsof -i :3002

# 停止占用端口的进程
kill -9 <PID>
```

### 问题2：Docker服务未启动
```bash
# 启动Docker Desktop
open -a Docker

# 检查Docker状态
docker info
```

### 问题3：环境变量未设置
```bash
# 设置环境变量
source set_env.sh dev
source set_env.sh test
source set_env.sh prod

# 检查环境变量
env | grep DATABASE_URL
env | grep SECRET_KEY
```

### 问题4：数据库连接失败
```bash
# 检查数据库容器
docker-compose -f docker-compose.yml -f docker-compose.dev.yml logs mysql
docker-compose -f docker-compose.yml -f docker-compose.test.yml logs mysql
docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs mysql

# 重启数据库
./deploy.sh dev down
./deploy.sh dev up
```

## 📊 验证检查清单

### 开发环境验证
- [ ] 启动开发环境
- [ ] 检查服务状态
- [ ] 验证健康检查
- [ ] 访问前端页面
- [ ] 测试API接口
- [ ] 检查数据库连接

### 测试环境验证
- [ ] 启动测试环境
- [ ] 检查容器状态
- [ ] 验证健康检查
- [ ] 访问前端页面
- [ ] 测试API接口
- [ ] 检查数据库迁移

### 生产环境验证
- [ ] 设置环境变量
- [ ] 启动生产环境
- [ ] 检查容器状态
- [ ] 验证健康检查
- [ ] 访问前端页面
- [ ] 测试API接口
- [ ] 检查数据库迁移

## 🎯 验证完成后的下一步

### 1. 配置CI/CD部署
```bash
# 配置GitHub Secrets
# 1. 进入GitHub仓库设置
# 2. 添加Secrets：
#    - TEST_SERVER_HOST
#    - TEST_SERVER_USER
#    - TEST_SERVER_SSH_KEY
#    - PROD_SERVER_HOST
#    - PROD_SERVER_USER
#    - PROD_SERVER_SSH_KEY
#    - TEST_DATABASE_URL
#    - PROD_DATABASE_URL
#    - TEST_SECRET_KEY
#    - PROD_SECRET_KEY
#    - PROD_MYSQL_ROOT_PASSWORD
#    - PROD_MYSQL_PASSWORD
#    - PROD_VITE_API_BASE_URL
```

### 2. 设置环境保护规则
```bash
# 在GitHub仓库设置中：
# 1. 进入Settings > Environments
# 2. 创建test环境（自动部署）
# 3. 创建production环境（需要审批）
```

### 3. 测试自动部署
```bash
# 推送到develop分支 - 自动部署到测试环境
git add .
git commit -m "test: 验证CI/CD部署"
git push origin develop

# 推送到main分支 - 自动部署到生产环境
git add .
git commit -m "feat: 发布新版本"
git push origin main
```

## 🚀 推荐操作顺序

### 立即执行
1. **验证开发环境** - 确保本地开发正常
2. **验证测试环境** - 确保Docker环境正常
3. **验证生产环境** - 确保生产配置正确

### 接下来执行
4. **配置GitHub Secrets** - 设置CI/CD部署
5. **测试自动部署** - 验证CI/CD流水线
6. **监控部署状态** - 确保部署成功

## 📞 需要帮助？

如果遇到问题，请：
1. 查看 `ENVIRONMENT_VALIDATION_CHECKLIST.md` 详细指南
2. 使用 `./validate-environments.sh --help` 查看帮助
3. 检查 `DOCKER_DEPLOYMENT_GUIDE.md` 部署指南
4. 联系开发团队

---

**🎯 现在开始验证环境，确保系统正常运行！**
