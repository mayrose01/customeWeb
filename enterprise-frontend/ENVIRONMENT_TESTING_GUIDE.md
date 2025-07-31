# 环境配置测试指南 (基于域名访问)

## 问题描述
之前的实现存在端口冲突问题，现在改用基于域名的环境区分方式，更加直观和可靠。

## 新的解决方案

### 1. 基于域名的环境配置

现在使用不同域名来明确区分环境：

#### 开发环境
- **访问地址**: `http://localhost:3000`
- **API地址**: `http://localhost:8000/api`
- **启动命令**: `npm run dev`

#### 测试环境
- **访问地址**: `http://test.catusfoto.top`
- **API地址**: `http://test.catusfoto.top/api`
- **启动命令**: `npm run dev:test` (构建部署)
- **本地开发**: `npm run dev:test-local` (本地开发)

#### 生产环境
- **访问地址**: `https://catusfoto.top`
- **API地址**: `https://catusfoto.top/api`
- **启动命令**: `npm run build:prod`

### 2. 环境判断逻辑

新的环境判断优先级（从高到低）：
1. **环境变量** `VITE_APP_ENV` (最可靠)
2. **URL参数** `?env=test` (用于临时测试)
3. **域名判断**:
   - `localhost` → 开发环境
   - `test.catusfoto.top` → 测试环境
   - `catusfoto.top` → 生产环境
   - 其他域名 → 生产环境

### 3. 环境配置说明

| 环境 | 访问地址 | API地址 | 启动命令 | 数据库 |
|------|----------|---------|----------|--------|
| 开发 | localhost:3000 | `http://localhost:8000/api` | `npm run dev` | 开发数据库 |
| 测试 | test.catusfoto.top | `http://test.catusfoto.top/api` | `npm run dev:test` | 测试数据库 |
| 生产 | catusfoto.top | `https://catusfoto.top/api` | `npm run build:prod` | 生产数据库 |

### 4. 启动脚本功能

#### `npm run dev` (开发环境)
- 自动启动后端服务 (端口8000)
- 自动启动前端服务 (端口3000)
- 设置环境变量 `VITE_APP_ENV=development`
- 访问地址: `http://localhost:3000`

#### `npm run dev:test` (测试环境部署)
- 构建测试环境代码
- 部署到 `test.catusfoto.top` 服务器
- 设置环境变量 `VITE_APP_ENV=test`
- 访问地址: `http://test.catusfoto.top`

#### `npm run dev:test-local` (测试环境本地开发)
- 本地开发测试环境
- 调用测试域名API
- 设置环境变量 `VITE_APP_ENV=test`
- 访问地址: `http://localhost:3000` (但调用测试API)

### 5. 测试方法

#### 方法1：直接访问不同域名
- 开发环境：`http://localhost:3000`
- 测试环境：`http://test.catusfoto.top`
- 生产环境：`https://catusfoto.top`

#### 方法2：使用测试页面
访问 `http://localhost:3000/env-test` 查看当前环境配置

#### 方法3：使用URL参数
- 开发环境：`http://localhost:3000/env-test?env=development`
- 测试环境：`http://localhost:3000/env-test?env=test`
- 生产环境：`http://localhost:3000/env-test?env=production`

#### 方法4：查看浏览器控制台
打开浏览器开发者工具，查看控制台输出：
```
=== API配置信息 ===
当前API_BASE_URL: http://test.catusfoto.top/api
当前环境: test
```

### 6. 验证步骤

#### 开发环境验证
```bash
# 1. 启动开发环境
npm run dev

# 2. 访问开发环境
http://localhost:3000

# 3. 验证API调用
# 检查网络请求是否调用 http://localhost:8000/api
# 应该显示开发环境的完整数据
```

#### 测试环境验证
```bash
# 方式1：部署到测试服务器
npm run dev:test
# 然后访问 http://test.catusfoto.top

# 方式2：本地开发测试环境
npm run dev:test-local
# 然后访问 http://localhost:3000 (但调用测试API)

# 3. 验证API调用
# 检查网络请求是否调用 http://test.catusfoto.top/api
# 应该显示测试环境的空数据
```

### 7. 优势

#### ✅ 解决了之前的问题
- **无端口冲突**：不再依赖特定端口号
- **环境明确**：通过域名明确区分环境
- **数据隔离**：不同环境使用不同数据库
- **直观易懂**：域名直接反映环境类型
- **访问简单**：直接访问对应域名即可

#### ✅ 新的特性
- **域名检测**：自动检测当前域名并选择对应环境
- **环境隔离**：不同环境使用不同的API地址和数据库
- **调试友好**：详细的控制台输出
- **灵活配置**：支持URL参数临时切换环境
- **部署简单**：构建后直接部署到对应域名

### 8. 域名配置要求

#### 开发环境
- 无需额外配置，使用 `localhost` 即可

#### 测试环境
- 需要配置DNS：`test.catusfoto.top` 指向测试服务器
- 测试服务器需要运行后端服务
- 确保防火墙允许访问
- 部署前端代码到测试服务器

#### 生产环境
- 需要配置DNS：`catusfoto.top` 指向生产服务器
- 生产服务器需要运行后端服务
- 配置SSL证书
- 部署前端代码到生产服务器

### 9. 故障排除

#### 问题1：测试环境仍然调用开发环境API
**解决：** 
- 确保使用正确的启动命令
- 检查环境变量是否正确设置
- 查看控制台调试信息

#### 问题2：测试域名无法访问
**解决：** 
- 检查DNS配置是否正确
- 确认测试服务器是否运行
- 检查防火墙设置
- 确认前端代码已部署到测试服务器

#### 问题3：环境变量不生效
**解决：** 
- 检查启动命令是否正确
- 清除浏览器缓存
- 查看控制台调试信息

#### 问题4：数据混乱
**解决：** 
- 确认不同环境使用不同数据库
- 检查API地址是否正确
- 验证域名配置

### 10. 最佳实践

1. **使用推荐的启动命令**
   - 开发环境：`npm run dev`
   - 测试环境：`npm run dev:test` (部署) 或 `npm run dev:test-local` (本地开发)

2. **直接访问对应域名**
   - 开发环境：`http://localhost:3000`
   - 测试环境：`http://test.catusfoto.top`
   - 生产环境：`https://catusfoto.top`

3. **检查环境配置**
   - 访问 `/env-test` 页面
   - 查看控制台调试信息

4. **验证API调用**
   - 打开浏览器开发者工具
   - 检查网络请求的API地址

5. **数据验证**
   - 开发环境：应该显示完整数据
   - 测试环境：应该显示空数据或测试数据
   - 生产环境：应该显示生产数据

### 11. 总结

新的基于域名的环境配置方案：
- ✅ **可靠**：基于域名，不依赖端口
- ✅ **直观**：域名直接反映环境类型
- ✅ **隔离**：不同环境使用不同数据库
- ✅ **简单**：直接访问对应域名
- ✅ **友好**：详细的错误提示和调试信息 