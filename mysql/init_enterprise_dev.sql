-- 企业官网开发环境数据库初始化脚本
-- 创建完整的数据库表结构

USE enterprise_dev;

-- 1. 更新产品表，添加缺失字段（如果不存在）
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'enterprise_dev' 
     AND TABLE_NAME = 'product' 
     AND COLUMN_NAME = 'base_price') = 0,
    'ALTER TABLE product ADD COLUMN base_price DECIMAL(10,2) DEFAULT 0.00',
    'SELECT "base_price column already exists"'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'enterprise_dev' 
     AND TABLE_NAME = 'product' 
     AND COLUMN_NAME = 'is_active') = 0,
    'ALTER TABLE product ADD COLUMN is_active BOOLEAN DEFAULT TRUE',
    'SELECT "is_active column already exists"'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. 创建产品规格表
CREATE TABLE IF NOT EXISTS product_specification (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    parent_id INT NULL,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES product_specification(id) ON DELETE SET NULL
);

-- 3. 创建产品规格值表
CREATE TABLE IF NOT EXISTS product_specification_value (
    id INT AUTO_INCREMENT PRIMARY KEY,
    specification_id INT NOT NULL,
    value VARCHAR(100) NOT NULL,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (specification_id) REFERENCES product_specification(id) ON DELETE CASCADE
);

-- 4. 创建产品SKU表
CREATE TABLE IF NOT EXISTS product_sku (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    sku_code VARCHAR(100) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE
);

-- 5. 创建SKU规格关联表
CREATE TABLE IF NOT EXISTS sku_specification (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sku_id INT NOT NULL,
    spec_value_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sku_id) REFERENCES product_sku(id) ON DELETE CASCADE,
    FOREIGN KEY (spec_value_id) REFERENCES product_specification_value(id) ON DELETE CASCADE
);

-- 6. 创建购物车表
CREATE TABLE IF NOT EXISTS cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 7. 创建购物车项表
CREATE TABLE IF NOT EXISTS cart_item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    sku_id INT NOT NULL,
    quantity INT DEFAULT 1 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES cart(id) ON DELETE CASCADE,
    FOREIGN KEY (sku_id) REFERENCES product_sku(id) ON DELETE CASCADE
);

-- 8. 创建订单表
CREATE TABLE IF NOT EXISTS `order` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_no VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20),
    payment_status VARCHAR(20) DEFAULT 'unpaid',
    payment_time TIMESTAMP NULL,
    shipping_address TEXT,
    shipping_contact VARCHAR(100),
    shipping_phone VARCHAR(50),
    shipping_company VARCHAR(100),
    tracking_number VARCHAR(100),
    shipping_time TIMESTAMP NULL,
    delivery_time TIMESTAMP NULL,
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 9. 创建订单项表
CREATE TABLE IF NOT EXISTS order_item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    sku_id INT NULL,
    product_title VARCHAR(255) NOT NULL,
    sku_code VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    specifications JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES `order`(id) ON DELETE CASCADE,
    FOREIGN KEY (sku_id) REFERENCES product_sku(id) ON DELETE SET NULL
);

-- 10. 创建索引
CREATE INDEX idx_product_spec_product_id ON product_specification(product_id);
CREATE INDEX idx_product_spec_value_spec_id ON product_specification_value(specification_id);
CREATE INDEX idx_product_sku_product_id ON product_sku(product_id);
CREATE INDEX idx_product_sku_code ON product_sku(sku_code);
CREATE INDEX idx_sku_spec_sku_id ON sku_specification(sku_id);
CREATE INDEX idx_cart_user_id ON cart(user_id);
CREATE INDEX idx_cart_item_cart_id ON cart_item(cart_id);
CREATE INDEX idx_order_user_id ON `order`(user_id);
CREATE INDEX idx_order_order_no ON `order`(order_no);
CREATE INDEX idx_order_item_order_id ON order_item(order_id);

-- 11. 显示创建的表
SHOW TABLES; 