#!/bin/bash

# 初始化生产环境数据
# 为生产环境添加基础数据

set -e

# 配置信息
SERVER_IP="YOUR_SERVER_IP_HERE"
SERVER_PASSWORD="YOUR_SERVER_PASSWORD_HERE"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 初始化公司信息
init_company_info() {
    log_step "初始化公司信息..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE enterprise_prod << 'MYSQL_EOF'
INSERT INTO company_info (
    name, 
    logo_url, 
    email, 
    phone, 
    address, 
    working_hours, 
    company_image, 
    main_business, 
    main_pic_url, 
    about_text
) VALUES (
    '企业官网',
    '',
    'contact@catusfoto.top',
    '400-123-4567',
    '中国上海市浦东新区张江高科技园区',
    '周一至周五: 9:00-18:00',
    '',
    '专注于为客户提供优质的产品和服务，致力于技术创新和品质保证。',
    '',
    '我们是一家专业的企业，致力于为客户提供优质的产品和服务。多年来，我们始终坚持"质量第一、客户至上"的经营理念，不断创新和发展，在行业内树立了良好的口碑和信誉。'
) ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    email = VALUES(email),
    phone = VALUES(phone),
    address = VALUES(address),
    working_hours = VALUES(working_hours),
    main_business = VALUES(main_business),
    about_text = VALUES(about_text);
MYSQL_EOF
EOF
}

# 初始化基础分类
init_categories() {
    log_step "初始化产品分类..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE enterprise_prod << 'MYSQL_EOF'
INSERT INTO categories (name, description, image, sort_order) VALUES
('电子产品', '各类电子产品，包括手机、电脑、平板等', '', 1),
('机械设备', '工业机械设备，包括生产设备、加工设备等', '', 2),
('建筑材料', '建筑用材料，包括钢材、水泥、木材等', '', 3)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description),
    sort_order = VALUES(sort_order);
MYSQL_EOF
EOF
}

# 初始化示例产品
init_sample_products() {
    log_step "初始化示例产品..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE enterprise_prod << 'MYSQL_EOF'
INSERT INTO products (title, model, brief_intro, detail_intro, category_id, images) VALUES
('智能手机', 'SM-001', '高性能智能手机，支持5G网络', '这是一款高性能智能手机，采用最新处理器，支持5G网络，配备高清摄像头和大容量电池。', 1, '[]'),
('工业机器人', 'RB-002', '自动化工业机器人，提高生产效率', '先进的工业机器人，具有高精度、高效率的特点，适用于各种工业生产环境。', 2, '[]'),
('高强度钢材', 'ST-003', '优质建筑钢材，符合国家标准', '高强度建筑钢材，经过严格质量检测，符合国家标准，适用于各类建筑工程。', 3, '[]')
ON DUPLICATE KEY UPDATE
    title = VALUES(title),
    model = VALUES(model),
    brief_intro = VALUES(brief_intro),
    detail_intro = VALUES(detail_intro),
    category_id = VALUES(category_id);
MYSQL_EOF
EOF
}

# 初始化轮播图
init_carousel() {
    log_step "初始化轮播图..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE enterprise_prod << 'MYSQL_EOF'
INSERT INTO carousel_images (image_url, caption, description, sort_order, is_active) VALUES
('', '欢迎访问企业官网', '我们致力于为客户提供最优质的产品和服务', 1, 1),
('', '专业团队', '拥有专业的技术团队和丰富的行业经验', 2, 1),
('', '品质保证', '严格的质量管理体系，确保每一个产品都符合标准', 3, 1)
ON DUPLICATE KEY UPDATE
    caption = VALUES(caption),
    description = VALUES(description),
    sort_order = VALUES(sort_order),
    is_active = VALUES(is_active);
MYSQL_EOF
EOF
}

# 初始化业务板块
init_services() {
    log_step "初始化业务板块..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE enterprise_prod << 'MYSQL_EOF'
INSERT INTO services (name, description, image_url, sort_order, is_active) VALUES
('产品研发', '专注于产品研发和创新，为客户提供最先进的技术解决方案', '', 1, 1),
('生产制造', '拥有先进的生产设备和专业的技术团队，确保产品质量', '', 2, 1),
('销售服务', '提供全方位的销售服务和技术支持，满足客户各种需求', '', 3, 1)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description),
    sort_order = VALUES(sort_order),
    is_active = VALUES(is_active);
MYSQL_EOF
EOF
}

# 验证数据
verify_data() {
    log_step "验证数据..."
    
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
echo "=== 公司信息 ==="
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SELECT name, email, phone FROM company_info;'

echo "=== 产品分类 ==="
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SELECT name, description FROM categories;'

echo "=== 示例产品 ==="
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SELECT title, model FROM products LIMIT 3;'

echo "=== 轮播图 ==="
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SELECT caption, description FROM carousel_images;'

echo "=== 业务板块 ==="
mysql -u enterprise_user -pYOUR_DATABASE_PASSWORD_HERE -e 'USE enterprise_prod; SELECT name, description FROM services;'
EOF
}

# 测试API
test_api() {
    log_step "测试API..."
    
    echo "测试公司信息API..."
    curl -s https://catusfoto.top/api/company/ | head -5
    
    echo ""
    echo "测试产品分类API..."
    curl -s https://catusfoto.top/api/categories/ | head -5
    
    echo ""
    echo "测试产品API..."
    curl -s https://catusfoto.top/api/products/ | head -5
}

# 主函数
main() {
    echo "🚀 开始初始化生产环境数据..."
    echo ""
    
    init_company_info
    init_categories
    init_sample_products
    init_carousel
    init_services
    verify_data
    test_api
    
    echo ""
    echo "✅ 数据初始化完成！"
    echo ""
    echo "📋 访问信息："
    echo "   - 网站: https://catusfoto.top"
    echo "   - 管理后台: https://catusfoto.top/admin/login"
    echo "   - 管理员账号: admin/admin123"
    echo ""
}

# 执行主函数
main "$@" 