# 环境配置指南

## 概述

本文档说明如何在不同环境中正确配置图片URL和CORS设置，避免常见的环境切换问题。

## 环境配置

### 开发环境 (Development)
- **前端地址**: `http://localhost:3000`
- **后端地址**: `http://localhost:8000`
- **数据库**: `enterprise_dev` (localhost:3306)
- **图片URL**: `http://localhost:8000/uploads/`
- **CORS配置**: `["http://localhost:3000", "http://localhost:3001", "http://localhost:3002"]`

### 测试环境 (Testing)
- **前端地址**: `http://localhost:3000`
- **后端地址**: `http://localhost:8001`
- **数据库**: `enterprise_test` (Docker容器)
- **图片URL**: `http://localhost:8001/uploads/`
- **CORS配置**: `["http://localhost", "http://localhost:3000", "http://localhost:3001", ...]`

### 生产环境 (Production)
- **前端地址**: `https://catusfoto.top`
- **后端地址**: `https://catusfoto.top/api`
- **数据库**: `enterprise_prod` (生产服务器)
- **图片URL**: `https://catusfoto.top/uploads/`
- **CORS配置**: `["https://catusfoto.top", "http://catusfoto.top", ...]`

## 常见问题解决

### 1. 图片显示"FAILED"

**问题**: 图片无法显示，显示"FAILED"状态。

**原因**: 图片URL指向错误的环境地址。

**解决方案**:
```bash
# 修复测试环境图片URL
./fix_image_urls.sh test

# 修复开发环境图片URL
./fix_image_urls.sh dev

# 修复生产环境图片URL
./fix_image_urls.sh prod
```

### 2. CORS错误

**问题**: 浏览器控制台显示CORS策略错误。

**原因**: 后端CORS配置中没有包含前端地址。

**解决方案**: 检查并更新 `docker-compose.test.yml` 中的CORS配置:
```yaml
environment:
  - CORS_ORIGINS=["http://localhost", "http://localhost:3000", ...]
```

### 3. 上传图片失败

**问题**: 后台管理上传图片返回500错误。

**原因**: CORS配置问题或文件路径配置错误。

**解决方案**:
1. 确保CORS配置正确
2. 检查 `FILE_BASE_URL` 环境变量
3. 重启后端服务

## 环境切换流程

### 从开发环境切换到测试环境

1. **启动测试环境**:
   ```bash
   ./deploy.sh test up
   ```

2. **修复图片URL**:
   ```bash
   ./fix_image_urls.sh test
   ```

3. **启动前端**:
   ```bash
   cd enterprise-frontend && ./scripts/start-test.sh
   ```

### 从测试环境切换到生产环境

1. **更新生产环境配置**
2. **修复图片URL**:
   ```bash
   ./fix_image_urls.sh prod
   ```
3. **部署到生产服务器**

## 环境变量配置

### 测试环境 (.env.test)
```env
ENVIRONMENT=testing
DATABASE_URL=mysql+pymysql://test_user:test_password@mysql_test:3306/enterprise_test
FILE_BASE_URL=http://localhost:8001
CORS_ORIGINS=["http://localhost", "http://localhost:3000", ...]
```

### 生产环境 (.env.production)
```env
ENVIRONMENT=production
DATABASE_URL=mysql+pymysql://prod_user:prod_password@mysql_prod:3306/enterprise_prod
FILE_BASE_URL=https://catusfoto.top
CORS_ORIGINS=["https://catusfoto.top", "http://catusfoto.top", ...]
```

## 自动化脚本

### 图片URL修复脚本
```bash
# 使用说明
./fix_image_urls.sh [environment]

# 示例
./fix_image_urls.sh test    # 修复测试环境
./fix_image_urls.sh dev     # 修复开发环境
./fix_image_urls.sh prod    # 修复生产环境
```

### 环境验证脚本
```bash
# 验证所有环境配置
./validate-environments.sh
```

## 最佳实践

1. **环境隔离**: 每个环境使用独立的数据库和配置
2. **配置管理**: 使用环境变量而非硬编码
3. **自动化**: 使用脚本自动修复常见问题
4. **文档记录**: 记录每个环境的配置差异
5. **测试验证**: 切换环境后及时验证功能

## 故障排除

### 检查清单
- [ ] 环境变量是否正确设置
- [ ] CORS配置是否包含前端地址
- [ ] 图片URL是否指向正确的环境
- [ ] 数据库连接是否正常
- [ ] 文件上传路径是否正确

### 日志检查
```bash
# 查看后端日志
docker logs enterprise_backend_test

# 查看前端日志
# 在浏览器开发者工具中查看控制台
```

### 网络检查
```bash
# 测试API连接
curl -v http://localhost:8001/api/health

# 测试CORS
curl -v -H "Origin: http://localhost:3000" http://localhost:8001/api/health
```