# 环境验证检查清单

## 🎯 验证目标
按顺序验证所有环境，确保从开发到生产的完整流程正常工作。

## 📋 验证步骤

### 第一步：本地开发环境验证

#### 1.1 启动本地开发环境
```bash
# 进入项目目录
cd /Users/huangqing/enterprise

# 启动本地开发环境
./deploy.sh dev up
```

#### 1.2 验证本地环境
- [ ] 后端服务启动成功 (http://localhost:8000)
- [ ] 前端服务启动成功 (http://localhost:3000)
- [ ] 数据库连接正常
- [ ] 健康检查通过 (http://localhost:8000/health)
- [ ] 可以正常访问前端页面
- [ ] 可以正常调用API接口

#### 1.3 本地环境测试
```bash
# 检查服务状态
./deploy.sh dev status

# 查看日志
./deploy.sh dev logs

# 停止本地环境
./deploy.sh dev down
```

### 第二步：Docker测试环境验证

#### 2.1 启动Docker测试环境
```bash
# 启动测试环境
./deploy.sh test up
```

#### 2.2 验证测试环境
- [ ] 所有容器启动成功
- [ ] 后端服务正常 (http://localhost:8001)
- [ ] 前端服务正常 (http://localhost:3001)
- [ ] 数据库迁移执行成功
- [ ] 健康检查通过 (http://localhost:8001/health)
- [ ] 可以正常访问前端页面
- [ ] 可以正常调用API接口

#### 2.3 测试环境验证
```bash
# 检查容器状态
./deploy.sh test status

# 查看容器日志
./deploy.sh test logs

# 检查数据库迁移状态
./deploy.sh test migrate-check

# 停止测试环境
./deploy.sh test down
```

### 第三步：生产环境验证

#### 3.1 准备生产环境
```bash
# 确保生产环境变量已设置
source set_env.sh prod

# 检查环境变量
echo $DATABASE_URL
echo $SECRET_KEY
echo $MYSQL_ROOT_PASSWORD
```

#### 3.2 启动生产环境
```bash
# 启动生产环境
./deploy.sh prod up
```

#### 3.3 验证生产环境
- [ ] 所有容器启动成功
- [ ] 后端服务正常 (http://localhost:8002)
- [ ] 前端服务正常 (http://localhost:3002)
- [ ] 数据库迁移执行成功
- [ ] 健康检查通过 (http://localhost:8002/health)
- [ ] 可以正常访问前端页面
- [ ] 可以正常调用API接口

#### 3.4 生产环境验证
```bash
# 检查容器状态
./deploy.sh prod status

# 查看容器日志
./deploy.sh prod logs

# 检查数据库迁移状态
./deploy.sh prod migrate-check
```

## 🔍 详细验证内容

### 后端API验证
```bash
# 健康检查
curl http://localhost:8000/health
curl http://localhost:8001/health
curl http://localhost:8002/health

# API接口测试
curl http://localhost:8000/api/health
curl http://localhost:8001/api/health
curl http://localhost:8002/api/health
```

### 前端页面验证
- [ ] 访问 http://localhost:3000 (开发环境)
- [ ] 访问 http://localhost:3001 (测试环境)
- [ ] 访问 http://localhost:3002 (生产环境)
- [ ] 页面正常加载
- [ ] 样式正常显示
- [ ] 功能正常使用

### 数据库验证
```bash
# 检查数据库连接
./deploy.sh dev migrate-check
./deploy.sh test migrate-check
./deploy.sh prod migrate-check

# 查看数据库状态
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec mysql mysql -u root -p -e "SHOW DATABASES;"
docker-compose -f docker-compose.yml -f docker-compose.test.yml exec mysql mysql -u root -p -e "SHOW DATABASES;"
docker-compose -f docker-compose.yml -f docker-compose.prod.yml exec mysql mysql -u root -p -e "SHOW DATABASES;"
```

## 🚨 常见问题排查

### 问题1：服务启动失败
```bash
# 检查端口占用
lsof -i :8000
lsof -i :8001
lsof -i :8002
lsof -i :3000
lsof -i :3001
lsof -i :3002

# 检查Docker状态
docker ps -a
docker-compose ps
```

### 问题2：数据库连接失败
```bash
# 检查数据库容器
docker-compose -f docker-compose.yml -f docker-compose.dev.yml logs mysql
docker-compose -f docker-compose.yml -f docker-compose.test.yml logs mysql
docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs mysql

# 检查环境变量
echo $DATABASE_URL
```

### 问题3：前端构建失败
```bash
# 检查Node.js版本
node --version
npm --version

# 清理缓存
cd enterprise-frontend
rm -rf node_modules package-lock.json
npm install
```

## 📊 验证结果记录

### 开发环境验证结果
- [ ] 启动时间: ___________
- [ ] 服务状态: ___________
- [ ] 健康检查: ___________
- [ ] 功能测试: ___________
- [ ] 问题记录: ___________

### 测试环境验证结果
- [ ] 启动时间: ___________
- [ ] 服务状态: ___________
- [ ] 健康检查: ___________
- [ ] 功能测试: ___________
- [ ] 问题记录: ___________

### 生产环境验证结果
- [ ] 启动时间: ___________
- [ ] 服务状态: ___________
- [ ] 健康检查: ___________
- [ ] 功能测试: ___________
- [ ] 问题记录: ___________

## 🎯 下一步行动

### 验证完成后
1. **记录验证结果** - 填写上述验证结果
2. **修复发现的问题** - 解决验证过程中的问题
3. **优化配置** - 根据验证结果优化环境配置
4. **准备CI/CD** - 配置GitHub Secrets和环境保护规则
5. **测试自动化部署** - 验证CI/CD流水线

### 准备CI/CD部署
```bash
# 1. 配置GitHub Secrets
# 2. 设置环境保护规则
# 3. 测试自动部署
git push origin develop    # 自动部署到测试环境
git push origin main       # 自动部署到生产环境
```

## 📞 技术支持

如有问题，请参考：
1. `DOCKER_DEPLOYMENT_GUIDE.md` - Docker部署指南
2. `CI_CD_GUIDE.md` - CI/CD使用指南
3. 联系开发团队

---

**🎯 按此清单验证所有环境，确保系统正常运行！**
