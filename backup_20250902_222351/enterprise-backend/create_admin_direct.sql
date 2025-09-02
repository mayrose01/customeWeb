-- 创建管理员用户SQL脚本
-- 用于在生产环境中直接创建管理员用户

USE enterprise_prod;

-- 检查用户表是否存在
SHOW TABLES LIKE 'users';

-- 检查是否已存在admin用户
SELECT id, username, email, role, status, created_at FROM users WHERE username = 'admin';

-- 如果admin用户不存在，则创建
INSERT INTO users (username, password_hash, email, role, status, created_at, updated_at) 
VALUES (
    'admin', 
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vJQKq6y', 
    'admin@catusfoto.top', 
    'admin', 
    1, 
    NOW(), 
    NOW()
) ON DUPLICATE KEY UPDATE 
    password_hash = '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vJQKq6y',
    updated_at = NOW();

-- 验证插入结果
SELECT id, username, email, role, status, created_at FROM users WHERE username = 'admin';

-- 显示所有管理员用户
SELECT id, username, email, role, status, created_at FROM users WHERE role = 'admin'; 