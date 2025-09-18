#!/bin/bash

# 完全重写models.py文件的脚本
# 解决所有结构问题，创建干净的模型定义

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置信息
SERVER_IP="47.243.41.30"
SERVER_USERNAME="root"
SSH_PRIVATE_KEY="./enterprise_prod.pem"

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

# 检查SSH私钥文件
check_ssh_key() {
    log_step "检查SSH私钥文件..."
    
    if [ ! -f "$SSH_PRIVATE_KEY" ]; then
        log_error "SSH私钥文件不存在: $SSH_PRIVATE_KEY"
        exit 1
    fi
    
    chmod 600 "$SSH_PRIVATE_KEY"
    log_info "SSH私钥文件检查完成"
}

# 测试SSH连接
test_ssh_connection() {
    log_step "测试SSH连接..."
    
    if ssh -i "$SSH_PRIVATE_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" "echo 'SSH连接测试成功'" 2>/dev/null; then
        log_info "SSH连接正常"
        return 0
    else
        log_error "SSH连接失败"
        return 1
    fi
}

# 完全重写models.py文件
rewrite_models_complete() {
    log_step "完全重写models.py文件..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
cd /var/www/enterprise/enterprise-backend

echo "=== 1. 备份当前models.py文件 ==="
cp app/models.py app/models.py.backup.$(date +%Y%m%d_%H%M%S)

echo "=== 2. 创建全新的models.py文件 ==="
cat > app/models.py << 'INNER_EOF'
from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, JSON, Float, Boolean, DECIMAL, Enum, TIMESTAMP
from sqlalchemy.orm import relationship, declarative_base
from sqlalchemy.sql import func
from datetime import datetime, timezone, timedelta

Base = declarative_base()

class CompanyInfo(Base):
    __tablename__ = "company_info"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255))  # 公司名称
    logo_url = Column(String(255))  # Logo图片路径
    email = Column(String(255))  # 公司邮箱
    phone = Column(String(50))  # 公司电话
    address = Column(String(500))  # 公司地址
    working_hours = Column(String(200))  # 工作时间
    company_image = Column(String(255))  # 公司图片路径
    main_business = Column(Text)  # 主营业务简介（文本）
    main_pic_url = Column(String(255))  # 主营业务配图路径
    about_text = Column(Text)  # 公司介绍（About页面）

class Category(Base):
    __tablename__ = "categories"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)  # 分类描述
    parent_id = Column(Integer, ForeignKey('categories.id'), nullable=True)
    sort_order = Column(Integer, default=0)  # 排序字段
    is_active = Column(Integer, default=1)  # 是否启用
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))
    image = Column(String(255), nullable=True)  # 分类图片
    
    # 关系定义
    children = relationship("Category", backref='parent', remote_side=[id])
    products = relationship("Product", back_populates="category")

class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)  # 产品标题
    model = Column(String(255), nullable=True)   # 产品型号
    short_desc = Column(Text, nullable=True)     # 简要描述
    detail = Column(Text, nullable=True)         # 详细描述
    images = Column(JSON, nullable=True)         # 图片数组
    category_id = Column(Integer, ForeignKey('categories.id'), nullable=True)
    sort_order = Column(Integer, default=0)      # 排序字段
    is_active = Column(Boolean, default=True)    # 是否启用
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())
    
    # 关系定义
    category = relationship("Category", back_populates="products")

class Service(Base):
    __tablename__ = "services"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)  # 服务名称
    description = Column(Text, nullable=True)  # 服务描述
    price = Column(DECIMAL(10,2), nullable=True)  # 服务价格
    image_url = Column(String(255), nullable=True)  # 服务图片
    sort_order = Column(Integer, default=0)  # 排序字段
    is_active = Column(Integer, default=1)  # 是否启用
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))

class Inquiry(Base):
    __tablename__ = "inquiries"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True)  # 用户ID（可选，关联用户表）
    product_id = Column(Integer, ForeignKey('products.id'), nullable=True)  # 产品ID
    service_id = Column(Integer, ForeignKey('services.id'), nullable=True)  # 服务ID
    name = Column(String(100), nullable=False)  # 询价人姓名
    email = Column(String(255), nullable=False)  # 询价人邮箱
    phone = Column(String(50), nullable=True)  # 询价人电话
    message = Column(Text, nullable=True)  # 询价信息
    status = Column(Enum('new', 'processing', 'completed', 'cancelled'), default='new')  # 询价状态
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)  # 用户名
    email = Column(String(255), unique=True, nullable=False)  # 邮箱
    hashed_password = Column(String(255), nullable=False)  # 加密后的密码
    is_active = Column(Boolean, default=True)  # 是否激活
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))
INNER_EOF

echo "=== 3. 验证新文件 ==="
echo "新models.py文件内容:"
head -50 app/models.py

echo -e "\n=== 4. 检查语法 ==="
python3 -m py_compile app/models.py
if [ $? -eq 0 ]; then
    echo "语法检查通过"
else
    echo "语法检查失败，需要手动修复"
    exit 1
fi

echo -e "\n=== 5. 重启后端服务 ==="
systemctl restart enterprise-backend

echo "等待服务启动..."
sleep 5

echo -e "\n=== 6. 测试产品API ==="
echo "测试产品列表API:"
curl -s -w "HTTP状态码: %{http_code}\n" "http://localhost:8000/api/product/?page=1&page_size=10" | head -10

echo -e "\n测试产品创建API:"
curl -s -X POST "http://localhost:8000/api/product/" \
  -H "Content-Type: application/json" \
  -d '{"title": "测试产品", "short_desc": "这是一个测试产品", "category_id": 2}' \
  -w "HTTP状态码: %{http_code}\n" | head -10

echo -e "\n=== 7. 验证新创建的产品 ==="
echo "检查数据库中的产品:"
mysql -u root -proot -e "USE enterprise_prod; SELECT * FROM products;"

echo "=== 完全重写完成 ==="
EOF
}

# 主函数
main() {
    log_info "开始完全重写models.py文件..."
    
    check_ssh_key
    test_ssh_connection
    
    if [ $? -eq 0 ]; then
        rewrite_models_complete
        
        log_info "models.py文件完全重写完成！"
        log_info "现在请测试："
        log_info "1. 产品列表API是否返回200状态码"
        log_info "2. 产品创建API是否成功"
        log_info "3. 新增的产品是否正确保存"
    else
        log_error "无法连接到生产服务器"
        exit 1
    fi
}

# 执行主函数
main "$@"
