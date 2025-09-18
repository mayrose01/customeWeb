# CI/CD 自动化构建与部署指南

## 📋 概述

本指南说明如何使用CI/CD流水线实现企业官网项目的自动化构建与部署，包括持续集成(CI)和持续部署(CD)。

## 🎯 CI/CD 架构

### 流水线组件
- **GitHub Actions**: CI/CD执行平台
- **GitHub Container Registry**: Docker镜像仓库
- **Docker**: 容器化构建和部署
- **Alembic**: 数据库迁移管理
- **多环境支持**: 开发、测试、生产环境

### 工作流文件
- `.github/workflows/ci.yml` - 主CI/CD流水线
- `.github/workflows/deploy.yml` - 手动部署工作流
- `.github/workflows/quality.yml` - 代码质量检查

## 🚀 快速开始

### 1. 配置GitHub Secrets

在GitHub仓库设置中添加以下Secrets：

#### 服务器配置
```
TEST_SERVER_HOST=your-test-server.com
TEST_SERVER_USER=root
TEST_SERVER_SSH_KEY=your-ssh-private-key

PROD_SERVER_HOST=your-prod-server.com
PROD_SERVER_USER=root
PROD_SERVER_SSH_KEY=your-ssh-private-key
```

#### 环境变量
```
TEST_DATABASE_URL=mysql+pymysql://user:password@host:port/database
TEST_SECRET_KEY=your-test-secret-key

PROD_DATABASE_URL=mysql+pymysql://user:password@host:port/database
PROD_SECRET_KEY=your-production-secret-key
PROD_MYSQL_ROOT_PASSWORD=your-mysql-root-password
PROD_MYSQL_PASSWORD=your-mysql-password
PROD_VITE_API_BASE_URL=https://yourdomain.com/api
```

#### 通知配置
```
SLACK_WEBHOOK=your-slack-webhook-url
```

### 2. 设置环境保护规则

在GitHub仓库设置中配置环境保护规则：

#### 测试环境
- 自动部署：`develop`分支推送时
- 手动审批：不需要

#### 生产环境
- 自动部署：`main`分支推送时
- 手动审批：需要
- 必需审查者：至少1人

## 🔄 CI/CD 工作流程

### 持续集成 (CI)

当代码推送到`develop`或`main`分支时，自动执行：

#### 1. 代码质量检查
```yaml
# 后端检查
- Python代码格式化 (Black)
- 代码风格检查 (Flake8)
- 类型检查 (MyPy)
- 安全扫描 (Bandit)
- 依赖安全检查 (Safety)

# 前端检查
- ESLint代码检查
- TypeScript类型检查
- Prettier格式化检查
- 安全审计 (npm audit)
```

#### 2. 自动化测试
```yaml
# 后端测试
- 单元测试 (pytest)
- 集成测试
- 代码覆盖率检查

# 前端测试
- 单元测试 (Vitest)
- 组件测试
- 代码覆盖率检查
```

#### 3. Docker镜像构建
```yaml
# 构建多平台镜像
- 后端镜像 (enterprise-backend)
- 前端镜像 (enterprise-frontend)
- 推送到GitHub Container Registry
- 多架构支持 (linux/amd64, linux/arm64)
```

#### 4. 安全扫描
```yaml
# 镜像安全扫描
- Trivy漏洞扫描
- 安全报告上传
- 漏洞告警
```

### 持续部署 (CD)

#### 自动部署
- **测试环境**: `develop`分支推送时自动部署
- **生产环境**: `main`分支推送时自动部署

#### 手动部署
通过GitHub Actions界面手动触发部署：

1. 进入Actions页面
2. 选择"Manual Deployment"工作流
3. 点击"Run workflow"
4. 选择目标环境和版本
5. 点击"Run workflow"

## 🛠️ 本地开发工具

### 镜像构建和推送
```bash
# 构建镜像
./build-and-push.sh --version v1.0.0

# 构建并推送
./build-and-push.sh --version v1.0.0 --push

# 指定仓库和命名空间
./build-and-push.sh --registry ghcr.io --namespace myorg --version latest --push
```

### 远程部署
```bash
# 部署到测试环境
./deploy-remote.sh \
  --host test-server.com \
  --user root \
  --key ~/.ssh/id_rsa \
  --env test \
  --version v1.0.0

# 部署到生产环境
./deploy-remote.sh \
  --host prod-server.com \
  --user root \
  --key ~/.ssh/id_rsa \
  --env production \
  --version v1.0.0 \
  --backup
```

## 📊 代码质量门禁

### 质量检查标准
- **代码覆盖率**: 后端≥80%，前端≥70%
- **代码风格**: 通过Black和Prettier检查
- **安全扫描**: 无高危漏洞
- **类型检查**: 通过MyPy和TypeScript检查
- **依赖安全**: 无已知安全漏洞

### 质量门禁流程
1. 代码推送触发质量检查
2. 并行执行所有质量检查
3. 所有检查通过才能继续
4. 失败时阻止部署并通知

## 🔒 安全特性

### 镜像安全
- **漏洞扫描**: 使用Trivy扫描镜像漏洞
- **基础镜像**: 使用官方最小化镜像
- **非root用户**: 容器内使用非特权用户
- **多阶段构建**: 减少最终镜像大小

### 部署安全
- **环境隔离**: 不同环境使用独立配置
- **密钥管理**: 使用GitHub Secrets管理敏感信息
- **访问控制**: 生产环境需要审批
- **审计日志**: 记录所有部署操作

### 网络安全
- **HTTPS**: 生产环境强制使用HTTPS
- **防火墙**: 限制不必要的端口访问
- **VPN**: 生产服务器通过VPN访问

## 📈 监控和告警

### 部署状态监控
- **GitHub Actions**: 查看构建和部署状态
- **Slack通知**: 部署成功/失败通知
- **健康检查**: 部署后自动健康检查

### 应用监控
- **服务状态**: Docker容器状态监控
- **数据库迁移**: 迁移执行状态
- **API健康**: 健康检查端点监控

## 🚨 故障处理

### 常见问题

#### 1. 构建失败
```bash
# 检查构建日志
# 在GitHub Actions页面查看详细错误

# 本地复现问题
./build-and-push.sh --version test
```

#### 2. 部署失败
```bash
# 检查部署日志
# 在GitHub Actions页面查看SSH执行日志

# 手动部署测试
./deploy-remote.sh --host server.com --user root --key ~/.ssh/id_rsa --env test
```

#### 3. 健康检查失败
```bash
# 检查服务状态
ssh user@server "cd /var/www/enterprise && ./deploy.sh test status"

# 检查日志
ssh user@server "cd /var/www/enterprise && ./deploy.sh test logs"
```

### 回滚操作

#### 自动回滚
```bash
# 使用部署脚本回滚
./deploy-remote.sh \
  --host server.com \
  --user root \
  --key ~/.ssh/id_rsa \
  --env production \
  --rollback
```

#### 手动回滚
```bash
# SSH到服务器
ssh user@server

# 进入项目目录
cd /var/www/enterprise

# 查看备份
ls -la backup_*

# 恢复备份
./deploy.sh production down
cp -r backup_20240101_120000/* .
./deploy.sh production up
```

## 🔧 自定义配置

### 添加新的质量检查
1. 在`.github/workflows/quality.yml`中添加新的检查步骤
2. 更新质量门禁条件
3. 测试新的检查规则

### 添加新的环境
1. 创建新的环境配置文件
2. 在GitHub Secrets中添加环境变量
3. 更新工作流文件
4. 设置环境保护规则

### 自定义部署脚本
1. 修改`deploy-remote.sh`脚本
2. 添加新的部署步骤
3. 更新健康检查逻辑

## 📚 最佳实践

### 开发流程
1. **功能开发**: 在feature分支开发
2. **代码审查**: 创建Pull Request
3. **质量检查**: 通过所有质量门禁
4. **合并代码**: 合并到develop分支
5. **自动部署**: 自动部署到测试环境
6. **生产发布**: 合并到main分支并部署

### 版本管理
- 使用语义化版本号 (Semantic Versioning)
- 为重要版本创建Git标签
- 保持版本历史记录

### 环境管理
- 环境配置通过环境变量管理
- 敏感信息使用GitHub Secrets
- 定期轮换密钥和密码

## 📞 技术支持

如有问题，请参考：
1. 本CI/CD指南
2. GitHub Actions文档
3. Docker官方文档
4. 联系开发团队

---

**🎯 CI/CD流水线已完全配置！现在可以享受自动化构建与部署的便利！**
