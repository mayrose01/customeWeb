-- 在测试环境数据库中插入管理员用户
USE enterprise_db;

-- 插入管理员用户
INSERT INTO users (
    username, 
    password_hash, 
    email, 
    phone, 
    role, 
    status, 
    created_at, 
    updated_at
) VALUES (
    'admin', 
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8K5K5K5',  -- 密码: admin123
    'admin@test.com', 
    '13800138000', 
    'admin', 
    1, 
    NOW(), 
    NOW()
);

-- 验证插入结果
SELECT id, username, email, role, status, created_at FROM users WHERE username = 'admin'; 