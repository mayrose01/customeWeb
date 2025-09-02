# 数据库名称修改总结

## 修改概述

根据用户要求，已将不同环境的数据库名称进行修改，以便更好地区分开发、测试和生产环境：

| 环境 | 原数据库名 | 新数据库名 |
|------|------------|------------|
| 开发环境 | `enterprise` | `enterprise_dev` |
| 测试环境 | `enterprise_test_db` | `enterprise_test` |
| 生产环境 | `enterprise_db` | `enterprise_prod` |

## 已修改的文件

### 核心配置文件

1. **`enterprise-backend/app/database.py`**
   - 修改了默认数据库URL配置
   - 开发环境：`enterprise` → `enterprise_dev`
   - 生产环境：`enterprise_db` → `enterprise_prod`

2. **`enterprise-backend/dev.env`**
   - 开发环境数据库URL：`enterprise` → `enterprise_dev`

3. **`enterprise-backend/production.env`**
   - 生产环境数据库URL：`enterprise_db` → `enterprise_prod`

4. **`enterprise-backend/production.env.example`**
   - 示例配置文件中的数据库名称更新

### Docker配置文件

5. **`docker-compose.yml`**
   - MySQL容器数据库名：`enterprise_db` → `enterprise_prod`
   - 后端服务数据库URL更新

6. **`docker-compose.test.yml`**
   - 测试环境MySQL数据库名：`enterprise_test_db` → `enterprise_test`
   - 后端服务数据库URL更新

### 数据库初始化文件

7. **`mysql/init.sql`**
   - 数据库创建语句：`enterprise_db` → `enterprise_prod`
   - 数据库使用语句更新
   - 字符集设置更新

8. **`add_admin_user.sql`**
   - 数据库使用语句：`enterprise_db` → `enterprise_prod`

### 启动脚本

9. **`start_simple_test_env.sh`**
   - 测试环境数据库URL：`enterprise_test_db` → `enterprise_test`
   - 数据库连接信息更新

### 文档文件

10. **`TEST_ENVIRONMENT_README.md`**
    - 测试环境说明文档中的数据库名称更新
    - 数据库连接示例更新

## 数据库名称规范

### 命名规则
- **开发环境**: `enterprise_dev`
- **测试环境**: `enterprise_test`
- **生产环境**: `enterprise_prod`

### 环境变量配置
```bash
# 开发环境
DATABASE_URL=mysql+pymysql://root:root@localhost:3306/enterprise_dev

# 测试环境
DATABASE_URL=mysql+pymysql://root:root@localhost:3306/enterprise_test

# 生产环境
DATABASE_URL=mysql://enterprise_user:YOUR_DATABASE_PASSWORD_HERE@localhost:3306/enterprise_prod
```

## 部署注意事项

### 1. 数据库创建
在部署时需要创建对应的数据库：

```sql
-- 开发环境
CREATE DATABASE IF NOT EXISTS enterprise_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 测试环境
CREATE DATABASE IF NOT EXISTS enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 生产环境
CREATE DATABASE IF NOT EXISTS enterprise_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2. 数据迁移
如果已有数据需要迁移：

```bash
# 备份原数据库
mysqldump -u username -p old_database > backup.sql

# 创建新数据库
mysql -u username -p -e "CREATE DATABASE new_database CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 恢复数据到新数据库
mysql -u username -p new_database < backup.sql
```

### 3. 环境变量设置
确保在启动服务时设置正确的环境变量：

```bash
# 开发环境
ENV=development python3 -m uvicorn app.main:app --reload

# 测试环境
ENV=test python3 -m uvicorn app.main:app --reload

# 生产环境
ENV=production python3 -m uvicorn app.main:app
```

## 验证步骤

### 1. 检查配置文件
确认以下文件中的数据库名称已正确更新：
- `enterprise-backend/app/database.py`
- `enterprise-backend/dev.env`
- `enterprise-backend/production.env`
- `docker-compose.yml`
- `docker-compose.test.yml`

### 2. 测试数据库连接
```bash
# 开发环境
mysql -u root -p enterprise_dev

# 测试环境
mysql -u test_user -p enterprise_test

# 生产环境
mysql -u enterprise_user -p enterprise_prod
```

### 3. 启动服务测试
```bash
# 开发环境
cd enterprise-backend
ENV=development python3 -m uvicorn app.main:app --reload

# 测试环境
cd enterprise-backend
ENV=test python3 -m uvicorn app.main:app --reload --port 8001

# 生产环境
cd enterprise-backend
ENV=production python3 -m uvicorn app.main:app
```

## 注意事项

1. **数据隔离**: 三个环境使用不同的数据库，确保数据完全隔离
2. **端口隔离**: 测试环境使用不同的端口避免冲突
3. **文件隔离**: 不同环境使用不同的上传目录和日志文件
4. **配置隔离**: 每个环境使用独立的配置文件

## 后续工作

1. **更新其他脚本**: 检查并更新其他部署脚本中的数据库名称
2. **更新文档**: 更新所有相关文档中的数据库名称引用
3. **测试验证**: 在各个环境中测试数据库连接和应用功能
4. **数据迁移**: 如有需要，进行现有数据的迁移工作

## 总结

通过这次修改，三个环境的数据库名称更加规范和清晰，便于管理和维护。每个环境都有独立的数据库，确保了数据的完全隔离，提高了系统的安全性和可维护性。 