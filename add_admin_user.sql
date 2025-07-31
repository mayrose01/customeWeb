-- 在测试环境数据库中插入管理员用户
USE enterprise_prod;

-- 插入管理员用户
INSERT INTO users (username, password_hash, email, role, status, created_at, updated_at) 
VALUES ('admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vJQKq6y', 'admin@catusfoto.top', 'admin', 'active', NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- 验证插入结果
SELECT id, username, email, role, status, created_at FROM users WHERE username = 'admin'; 