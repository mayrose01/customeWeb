# 登录路径修复测试

## 问题描述
在测试环境登录后，浏览器地址栏显示的是开发环境的地址 `http://localhost:3000/admin/company`，而不是测试环境的地址。

## 修复内容

### 1. 后台登录页面修复 (`src/views/Login.vue`)
- 添加了环境检测函数 `isTestEnvironment()`
- 修改登录成功后的跳转逻辑，根据环境跳转到正确的路径：
  - 测试环境：`/test/admin`
  - 开发环境：`/admin`

### 2. 客户端登录组件修复 (`src/components/client/LoginForm.vue`)
- 修复了登录成功后的跳转逻辑
- 修复了注册成功后的跳转逻辑
- 修复了登录/注册页面切换的逻辑

### 3. 后台管理面板修复 (`src/views/Dashboard.vue`)
- 添加了环境检测和菜单路径生成函数
- 修复了菜单项的路径，使其根据环境动态生成
- 修复了退出登录的跳转逻辑

## 测试步骤

### 测试环境登录
1. 访问 `http://localhost:3000/test/admin/login`
2. 输入正确的用户名和密码
3. 点击登录
4. 验证浏览器地址栏是否显示 `http://localhost:3000/test/admin/company`

### 开发环境登录
1. 访问 `http://localhost:3000/admin/login`
2. 输入正确的用户名和密码
3. 点击登录
4. 验证浏览器地址栏是否显示 `http://localhost:3000/admin/company`

### 客户端登录测试
1. 访问 `http://localhost:3000/test/login`
2. 输入正确的用户名和密码
3. 点击登录
4. 验证是否跳转到 `http://localhost:3000/test/profile`

## 预期结果
- 测试环境登录后应该保持在 `/test/` 路径下
- 开发环境登录后应该保持在 `/admin/` 路径下
- 所有菜单导航都应该在正确的环境下工作
- 退出登录后应该跳转到对应环境的登录页面 