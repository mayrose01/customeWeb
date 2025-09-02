-- 创建管理员用户SQL脚本（基于实际表结构）
-- 用于在生产环境中直接创建管理员用户

USE enterprise_db;

-- 检查用户表是否存在
SHOW TABLES LIKE 'users';

-- 检查用户表结构
DESCRIBE users;

-- 检查是否已存在admin用户
SELECT id, username, email, role, status, created_at FROM users WHERE username = 'admin';

-- 如果admin用户不存在，则创建
-- 注意：这里使用的是bcrypt加密的密码，对应明文密码 'admin123'
INSERT INTO users (
    username, 
    password_hash, 
    email, 
    role, 
    status, 
    created_at, 
    updated_at
) VALUES (
    'admin', 
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vJQKq6y', 
    'admin@catusfoto.top', 
    'admin', 
    1, 
    NOW(), 
    NOW()
) ON DUPLICATE KEY UPDATE 
    password_hash = '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vJQKq6y',
    email = 'admin@catusfoto.top',
    role = 'admin',
    status = 1,
    updated_at = NOW();

-- 验证插入结果
SELECT id, username, email, role, status, created_at FROM users WHERE username = 'admin';

-- 显示所有管理员用户
SELECT id, username, email, role, status, created_at FROM users WHERE role = 'admin';

-- 显示所有用户
SELECT id, username, email, role, status, created_at FROM users; 