# 环境配置修复总结

## 问题描述
生产环境的后台登录页面 `https://catusfoto.top/admin/login` 调用的是 `http://localhost:8000/api/user/login`，这是本地开发环境的地址，而不是生产环境的地址。

## 根本原因
1. 前端代码中多处硬编码了 `localhost:8000` 的API地址
2. 环境配置逻辑有问题，生产环境应该使用相对路径而不是完整URL
3. 图片URL处理逻辑没有考虑不同环境的差异

## 修复内容

### 1. 修复环境配置 (env.config.js)
- 修改生产环境配置，使用相对路径 `/api` 而不是完整URL
- 因为nginx会代理API请求到后端，所以前端应该使用相对路径

### 2. 修复硬编码的API地址
修复了以下文件中的硬编码地址：

#### 管理后台页面：
- `src/views/CategoryManage.vue` - 分类管理
- `src/views/ProductManage.vue` - 产品管理  
- `src/views/ServiceManage.vue` - 服务管理
- `src/views/CarouselManage.vue` - 轮播图管理
- `src/views/CompanyInfo.vue` - 公司信息管理

#### 客户端页面：
- `src/views/client/Contact.vue` - 联系我们
- `src/views/client/Profile.vue` - 用户个人中心
- `src/components/client/InquiryModal.vue` - 询价弹窗

#### 工具文件：
- `src/utils/imageUtils.js` - 图片URL处理工具

### 3. 统一图片URL处理逻辑
- 创建了统一的 `getImageUrl` 函数
- 根据环境自动选择正确的图片URL格式
- 生产环境使用相对路径，开发/测试环境使用完整URL

### 4. 修复构建问题
- 修复了重复导入问题
- 移除了不存在的依赖引用
- 修复了路径引用错误

## 环境配置说明

### 开发环境 (localhost:3000)
- API地址: `http://localhost:8000/api`
- 图片地址: `http://localhost:8000/uploads/xxx.jpg`

### 测试环境 (localhost:3001)
- API地址: `http://localhost:8001/api`
- 图片地址: `http://localhost:8001/uploads/xxx.jpg`

### 生产环境 (catusfoto.top)
- API地址: `/api` (相对路径，由nginx代理)
- 图片地址: `/uploads/xxx.jpg` (相对路径)

## 验证方法

1. **开发环境测试**：
   ```bash
   cd enterprise-frontend
   npm run dev
   ```
   访问 `http://localhost:3000/admin/login`，检查API调用是否正确

2. **生产环境测试**：
   - 部署到生产环境
   - 访问 `https://catusfoto.top/admin/login`
   - 检查浏览器开发者工具中的网络请求，确认API调用的是相对路径 `/api`

3. **构建测试**：
   ```bash
   npm run build
   ```
   确保构建成功，没有错误

## 注意事项

1. 确保nginx配置正确代理API请求到后端
2. 确保后端服务在生产环境中正确运行
3. 如果修改了环境配置，需要重新构建前端项目
4. 图片上传功能现在会根据环境自动选择正确的URL格式

## 相关文件

- `env.config.js` - 环境配置文件
- `src/utils/imageUtils.js` - 图片URL处理工具
- `vite.config.js` - 构建配置
- 所有修复的Vue组件文件 