# 数据库连接信息

## 开发环境数据库
- **数据库名称**: `enterprise_dev`
- **端口**: 3306
- **用户名**: `root`
- **密码**: `root`
- **连接字符串**: `mysql+pymysql://root:root@localhost:3306/enterprise_dev`

## 测试环境数据库
- **数据库名称**: `enterprise_test`
- **端口**: 3307
- **用户名**: `test_user`
- **密码**: `test_password`
- **连接字符串**: `mysql+pymysql://test_user:test_password@localhost:3307/enterprise_test`

## 生产环境数据库
- **数据库名称**: `enterprise_prod`
- **端口**: 3306
- **用户名**: `enterprise_user`
- **密码**: `enterprise_password_2024`
- **连接字符串**: `mysql://enterprise_user:enterprise_password_2024@localhost:3306/enterprise_prod`

## 数据库状态

### enterprise_dev (开发环境)
- ✅ 已创建
- ✅ 数据已迁移
- ✅ 包含所有表结构
- 📊 数据统计:
  - 用户表: 16条记录
  - 产品表: 3条记录
  - 其他表: 已包含完整数据

### enterprise_test (测试环境)
- ✅ 已创建
- ✅ 独立运行
- 📊 数据统计: 测试数据

### enterprise (原数据库)
- ⚠️ 已废弃，建议删除
- 📝 数据已迁移到 enterprise_dev

## 连接方式

### 命令行连接
```bash
# 开发环境
mysql -u root -proot -D enterprise_dev

# 测试环境
mysql -u test_user -ptest_password -h localhost -P 3307 -D enterprise_test

# 生产环境
mysql -u enterprise_user -penterprise_password_2024 -D enterprise_prod
```

### 查看数据库
```bash
# 查看所有数据库
mysql -u root -proot -e "SHOW DATABASES;"

# 查看开发环境表
mysql -u root -proot -e "SHOW TABLES FROM enterprise_dev;"

# 查看测试环境表
mysql -u test_user -ptest_password -h localhost -P 3307 -e "SHOW TABLES FROM enterprise_test;"
```

## 环境配置

### 开发环境 (dev.env)
```
DATABASE_URL=mysql+pymysql://root:root@localhost:3306/enterprise_dev
```

### 测试环境 (test.env)
```
DATABASE_URL=mysql+pymysql://test_user:test_password@localhost:3307/enterprise_test
```

### 生产环境 (production.env)
```
DATABASE_URL=mysql://enterprise_user:enterprise_password_2024@localhost:3306/enterprise_prod
```

## 注意事项
1. 开发环境现在使用 `enterprise_dev` 数据库
2. 原来的 `enterprise` 数据库可以安全删除
3. 测试环境使用独立的数据库和端口
4. 生产环境使用独立的用户和数据库 