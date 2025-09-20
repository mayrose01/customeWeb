-- MySQL测试数据库初始化脚本
-- 创建企业官网测试数据库

-- 创建数据库
CREATE DATABASE IF NOT EXISTS enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE enterprise_test;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(50),
    role ENUM('admin', 'user') DEFAULT 'user',
    wx_openid VARCHAR(100),
    wx_unionid VARCHAR(100),
    app_openid VARCHAR(100),
    avatar_url VARCHAR(255),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建公司信息表
CREATE TABLE IF NOT EXISTS company_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    logo_url VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address VARCHAR(500),
    working_hours VARCHAR(200),
    company_image VARCHAR(255),
    main_business TEXT,
    main_pic_url VARCHAR(255),
    about_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建轮播图表
CREATE TABLE IF NOT EXISTS carousel_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
    caption VARCHAR(255),
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建联系我们字段表
CREATE TABLE IF NOT EXISTS contact_fields (
    id INT AUTO_INCREMENT PRIMARY KEY,
    field_name VARCHAR(50) NOT NULL,
    field_label VARCHAR(50) NOT NULL,
    field_type VARCHAR(20) DEFAULT 'text',
    is_required BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建联系我们提交表
CREATE TABLE IF NOT EXISTS contact_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    message TEXT NOT NULL,
    status ENUM('new', 'read', 'replied') DEFAULT 'new',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 创建产品分类表
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id INT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- 创建产品表
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2),
    image_url VARCHAR(255),
    category_id INT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- 创建服务表
CREATE TABLE IF NOT EXISTS services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建询价表
CREATE TABLE IF NOT EXISTS inquiries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    service_id INT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    message TEXT,
    status ENUM('new', 'processing', 'completed', 'cancelled') DEFAULT 'new',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL
);

-- 插入默认管理员用户 (密码: admin123)
INSERT INTO users (username, password_hash, email, role, status) VALUES 
('admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vJQKq6y', 'admin@catusfoto.top', 'admin', 'active')
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入默认公司信息
INSERT INTO company_info (name, logo_url, email, phone, address, working_hours, company_image, main_business, main_pic_url, about_text) VALUES 
('CatusFoto', '/company-logo.jpg', 'info@catusfoto.top', '+86 123 4567 8900', '中国上海市浦东新区', '周一至周五 9:00-18:00', '/company-image.jpg', '专业摄影服务，包括商业摄影、人像摄影、活动摄影等', '/main-business.jpg', 'CatusFoto是一家专业的摄影服务公司，致力于为客户提供高质量的摄影作品。我们拥有经验丰富的摄影师团队和先进的摄影设备，能够满足各种摄影需求。')
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入默认轮播图
INSERT INTO carousel_images (image_url, caption, description, sort_order, is_active) VALUES 
('/carousel1.jpg', '专业摄影服务', '为您提供高质量的摄影服务', 1, TRUE),
('/carousel2.jpg', '商业摄影', '专业的商业摄影解决方案', 2, TRUE),
('/carousel3.jpg', '人像摄影', '精美的人像摄影作品', 3, TRUE)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入默认联系字段
INSERT INTO contact_fields (field_name, field_label, field_type, is_required, sort_order) VALUES 
('name', '姓名', 'text', TRUE, 1),
('email', '邮箱', 'email', TRUE, 2),
('phone', '电话', 'tel', FALSE, 3),
('message', '留言', 'textarea', TRUE, 4)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入默认产品分类
INSERT INTO categories (name, description, sort_order, is_active) VALUES 
('商业摄影', '专业的商业摄影服务', 1, TRUE),
('人像摄影', '精美的人像摄影作品', 2, TRUE),
('活动摄影', '各类活动摄影服务', 3, TRUE)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入默认产品
INSERT INTO products (name, description, price, image_url, category_id, sort_order, is_active) VALUES 
('商业产品摄影', '专业的商业产品摄影服务', 500.00, '/product1.jpg', 1, 1, TRUE),
('企业形象摄影', '企业形象和团队摄影', 800.00, '/product2.jpg', 1, 2, TRUE),
('个人写真', '个人艺术写真摄影', 300.00, '/product3.jpg', 2, 1, TRUE),
('婚纱摄影', '浪漫婚纱摄影服务', 2000.00, '/product4.jpg', 2, 2, TRUE)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入默认服务
INSERT INTO services (name, description, image_url, sort_order, is_active) VALUES 
('摄影咨询', '专业的摄影咨询服务', '/service1.jpg', 1, TRUE),
('后期制作', '专业的照片后期处理', '/service2.jpg', 2, TRUE),
('摄影培训', '摄影技巧培训课程', '/service3.jpg', 3, TRUE)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 设置数据库字符集
ALTER DATABASE enterprise_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;