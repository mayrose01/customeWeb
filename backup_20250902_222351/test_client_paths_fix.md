# 客户端路径修复测试

## 问题描述
测试环境的客户端页面路径没有正确使用 `/test` 前缀，导致访问 `http://localhost:3000/about` 而不是 `http://localhost:3000/test/about`。

## 修复内容

### 1. 创建路径工具函数 (`src/utils/pathUtils.js`)
- 添加了环境检测函数 `isTestEnvironment()`
- 添加了路径生成函数 `getPath()`, `getClientPath()`, `getAdminPath()`
- 添加了根路径获取函数 `getRootPath()`

### 2. 修复客户端组件
- **Header 组件** (`src/components/client/Header.vue`)
  - 修复了所有导航链接
  - 修复了用户菜单跳转
  - 修复了搜索功能跳转

- **Footer 组件** (`src/components/client/Footer.vue`)
  - 修复了快速导航链接

- **Home 页面** (`src/views/client/Home.vue`)
  - 修复了产品查看和联系我们链接

- **SubCategories 页面** (`src/views/client/SubCategories.vue`)
  - 修复了面包屑导航链接

- **ProductDetail 页面** (`src/views/client/ProductDetail.vue`)
  - 修复了面包屑导航链接
  - 修复了联系我们跳转

## 测试步骤

### 1. 测试环境客户端页面
1. 访问 `http://localhost:3002/test/`
2. 验证页面标题和导航栏显示正确
3. 点击"关于我们"链接，验证跳转到 `http://localhost:3002/test/about`
4. 点击"联系我们"链接，验证跳转到 `http://localhost:3002/test/contact`
5. 点击"产品列表"链接，验证跳转到 `http://localhost:3002/test/all-products`
6. 点击"分类"链接，验证跳转到 `http://localhost:3002/test/categories`

### 2. 测试产品详情页面
1. 访问 `http://localhost:3002/test/all-products`
2. 点击任意产品，验证跳转到 `http://localhost:3002/test/product/{id}`
3. 在产品详情页面，验证面包屑导航正确显示

### 3. 测试分类页面
1. 访问 `http://localhost:3002/test/categories`
2. 点击任意分类，验证跳转到 `http://localhost:3002/test/categories/{id}`
3. 在子分类页面，验证面包屑导航正确显示

### 4. 测试用户功能
1. 点击"登录"链接，验证跳转到 `http://localhost:3002/test/login`
2. 点击"注册"链接，验证跳转到 `http://localhost:3002/test/register`
3. 登录后，验证个人中心、询价列表等链接正确

### 5. 测试开发环境
1. 访问 `http://localhost:3002/` (不带 /test 前缀)
2. 验证所有链接都使用正确的开发环境路径

## 预期结果
- 测试环境的所有客户端页面都应该使用 `/test` 前缀
- 开发环境的所有客户端页面都应该使用根路径
- 所有导航、面包屑、用户功能都应该在正确的环境下工作
- 页面刷新后应该保持在正确的环境中

## 修复的文件列表
1. `src/utils/pathUtils.js` - 新建路径工具函数
2. `src/components/client/Header.vue` - 修复导航链接
3. `src/components/client/Footer.vue` - 修复导航链接
4. `src/views/client/Home.vue` - 修复页面链接
5. `src/views/client/SubCategories.vue` - 修复面包屑导航
6. `src/views/client/ProductDetail.vue` - 修复面包屑导航和跳转 