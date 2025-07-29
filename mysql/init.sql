-- MySQL数据库初始化脚本
-- 创建企业官网数据库

-- 创建数据库
CREATE DATABASE IF NOT EXISTS enterprise_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE enterprise_db;

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
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建轮播图表
CREATE TABLE IF NOT EXISTS carousel_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
    caption VARCHAR(255),
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建联系我们字段表
CREATE TABLE IF NOT EXISTS contact_fields (
    id INT AUTO_INCREMENT PRIMARY KEY,
    field_name VARCHAR(50) NOT NULL,
    field_label VARCHAR(50) NOT NULL,
    field_type VARCHAR(20) DEFAULT 'text',
    is_required TINYINT(1) DEFAULT 0,
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建联系我们提交表
CREATE TABLE IF NOT EXISTS contact_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(50),
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 创建主营业务表
CREATE TABLE IF NOT EXISTS services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    password_hash VARCHAR(255),
    email VARCHAR(100),
    phone VARCHAR(50),
    role VARCHAR(20) DEFAULT 'customer',
    wx_openid VARCHAR(50),
    wx_unionid VARCHAR(50),
    app_openid VARCHAR(50),
    avatar_url VARCHAR(255),
    status TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_role (role),
    INDEX idx_status (status),
    INDEX idx_wx_openid (wx_openid),
    INDEX idx_app_openid (app_openid)
);

-- 创建分类表
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image VARCHAR(255),
    parent_id INT,
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_parent_id (parent_id)
);

-- 创建产品表
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    model VARCHAR(100),
    images JSON,
    brief_intro TEXT,
    detail_intro TEXT,
    category_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_category_id (category_id),
    INDEX idx_title (title),
    INDEX idx_model (model)
);

-- 创建询价表
CREATE TABLE IF NOT EXISTS inquiries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    product_name VARCHAR(255),
    product_model VARCHAR(100),
    product_image VARCHAR(255),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(50),
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_product_id (product_id)
);

-- 插入默认数据

-- 插入默认联系我们字段
INSERT INTO contact_fields (field_name, field_label, field_type, is_required, sort_order) VALUES
('name', '姓名', 'text', 1, 1),
('email', '邮箱', 'email', 1, 2),
('phone', '电话', 'tel', 0, 3),
('subject', '主题', 'text', 1, 4),
('message', '留言内容', 'textarea', 1, 5);

-- 插入默认管理员用户（密码需要在实际部署时修改）
INSERT INTO users (username, password_hash, email, role, status) VALUES
('admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.iK2', 'admin@example.com', 'admin', 1);

-- 创建索引
CREATE INDEX idx_company_info_name ON company_info(name);
CREATE INDEX idx_carousel_sort ON carousel_images(sort_order, is_active);
CREATE INDEX idx_contact_fields_sort ON contact_fields(sort_order);
CREATE INDEX idx_contact_messages_created ON contact_messages(created_at);
CREATE INDEX idx_services_sort ON services(sort_order, is_active);
CREATE INDEX idx_categories_sort ON categories(sort_order);
CREATE INDEX idx_products_updated ON products(updated_at);
CREATE INDEX idx_inquiries_created ON inquiries(created_at);

-- 设置字符集
ALTER DATABASE enterprise_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; 