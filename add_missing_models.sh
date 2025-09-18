#!/bin/bash

# 添加缺失模型的脚本
# 将所有缺失的模型添加到models.py文件中

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

# 添加缺失的模型
add_missing_models() {
    log_step "添加缺失的模型..."
    
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no "$SERVER_USERNAME@$SERVER_IP" << 'EOF'
cd /var/www/enterprise/enterprise-backend

echo "=== 1. 备份当前models.py文件 ==="
cp app/models.py app/models.py.backup.$(date +%Y%m%d_%H%M%S)

echo "=== 2. 在User类后添加缺失的模型 ==="
# 找到User类的结束位置
user_end=$(grep -n "^class " app/models.py | awk -v start="$(grep -n 'class User' app/models.py | cut -d: -f1)" '$1 > start {print $1; exit}')
if [ -z "$user_end" ]; then
    user_end=$(wc -l < app/models.py)
fi

echo "User类结束位置: 第${user_end}行"

# 在User类后插入缺失的模型
cat > /tmp/missing_models.py << 'INNER_EOF'
class CarouselImage(Base):
    __tablename__ = "carousel_images"
    id = Column(Integer, primary_key=True, index=True)
    image_url = Column(String(255), nullable=False)  # 图片URL
    caption = Column(String(255), nullable=True)     # 图片标题
    link_url = Column(String(255), nullable=True)    # 链接URL
    sort_order = Column(Integer, default=0)          # 排序
    is_active = Column(Boolean, default=True)        # 是否激活
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))

class ContactField(Base):
    __tablename__ = "contact_fields"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)       # 字段名称
    field_type = Column(String(50), nullable=False)  # 字段类型
    is_required = Column(Boolean, default=False)     # 是否必填
    sort_order = Column(Integer, default=0)          # 排序
    is_active = Column(Boolean, default=True)        # 是否激活
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))

class ContactMessage(Base):
    __tablename__ = "contact_messages"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)       # 联系人姓名
    email = Column(String(255), nullable=False)      # 邮箱
    phone = Column(String(50), nullable=True)        # 电话
    subject = Column(String(200), nullable=True)     # 主题
    message = Column(Text, nullable=False)           # 消息内容
    ip_address = Column(String(45), nullable=True)   # IP地址
    status = Column(Enum('new', 'read', 'replied'), default='new')  # 状态
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))

class MallCategory(Base):
    __tablename__ = "mall_categories"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)       # 分类名称
    description = Column(Text, nullable=True)        # 分类描述
    parent_id = Column(Integer, ForeignKey('mall_categories.id'), nullable=True)
    sort_order = Column(Integer, default=0)          # 排序
    is_active = Column(Boolean, default=True)        # 是否激活
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))
    
    # 关系定义
    children = relationship("MallCategory", backref='parent', remote_side=[id])
    products = relationship("MallProduct", back_populates="category")

class MallProduct(Base):
    __tablename__ = "mall_products"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)       # 产品名称
    description = Column(Text, nullable=True)        # 产品描述
    price = Column(DECIMAL(10,2), nullable=True)     # 产品价格
    image_url = Column(String(255), nullable=True)   # 产品图片
    category_id = Column(Integer, ForeignKey('mall_categories.id'), nullable=True)
    sort_order = Column(Integer, default=0)          # 排序
    is_active = Column(Boolean, default=True)        # 是否激活
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))
    
    # 关系定义
    category = relationship("MallCategory", back_populates="products")
    skus = relationship("MallProductSKU", back_populates="product")

class MallProductSKU(Base):
    __tablename__ = "mall_product_skus"
    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey('mall_products.id'), nullable=False)
    sku_code = Column(String(100), nullable=False, unique=True)  # SKU编码
    price = Column(DECIMAL(10,2), nullable=False)                # SKU价格
    stock = Column(Integer, default=0)                           # 库存
    is_active = Column(Boolean, default=True)                    # 是否激活
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))
    
    # 关系定义
    product = relationship("MallProduct", back_populates="skus")
    specifications = relationship("MallProductSpecificationValue", back_populates="sku")

class MallProductSpecification(Base):
    __tablename__ = "mall_product_specifications"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)       # 规格名称
    description = Column(Text, nullable=True)        # 规格描述
    is_active = Column(Boolean, default=True)        # 是否激活
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))

class MallProductSpecificationValue(Base):
    __tablename__ = "mall_product_specification_values"
    id = Column(Integer, primary_key=True, index=True)
    sku_id = Column(Integer, ForeignKey('mall_product_skus.id'), nullable=False)
    specification_id = Column(Integer, ForeignKey('mall_product_specifications.id'), nullable=False)
    value = Column(String(100), nullable=False)      # 规格值
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    
    # 关系定义
    sku = relationship("MallProductSKU", back_populates="specifications")
    specification = relationship("MallProductSpecification")

class MallOrder(Base):
    __tablename__ = "mall_orders"
    id = Column(Integer, primary_key=True, index=True)
    order_number = Column(String(100), nullable=False, unique=True)  # 订单号
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    total_amount = Column(DECIMAL(10,2), nullable=False)             # 订单总金额
    status = Column(Enum('pending', 'paid', 'shipped', 'delivered', 'cancelled'), default='pending')
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))
    
    # 关系定义
    items = relationship("MallOrderItem", back_populates="order")

class MallOrderItem(Base):
    __tablename__ = "mall_order_items"
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey('mall_orders.id'), nullable=False)
    product_id = Column(Integer, ForeignKey('mall_products.id'), nullable=False)
    sku_id = Column(Integer, ForeignKey('mall_product_skus.id'), nullable=False)
    quantity = Column(Integer, nullable=False)       # 数量
    unit_price = Column(DECIMAL(10,2), nullable=False)  # 单价
    total_price = Column(DECIMAL(10,2), nullable=False) # 总价
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    
    # 关系定义
    order = relationship("MallOrder", back_populates="items")
INNER_EOF

echo "缺失模型定义已创建"

echo "=== 3. 插入缺失的模型到models.py ==="
# 在User类后插入缺失的模型
head -n $((user_end - 1)) app/models.py > app/models.py.new
cat /tmp/missing_models.py >> app/models.py.new
tail -n +$user_end app/models.py >> app/models.py.new

# 替换原文件
mv app/models.py.new app/models.py
echo "缺失模型已插入"

echo "=== 4. 验证新文件 ==="
echo "新models.py文件中的模型类:"
grep "^class " app/models.py | awk '{print $2}' | sed 's/(.*//'

echo -e "\n=== 5. 检查语法 ==="
python3 -m py_compile app/models.py
if [ $? -eq 0 ]; then
    echo "语法检查通过"
else
    echo "语法检查失败，需要手动修复"
    exit 1
fi

echo -e "\n=== 6. 重启后端服务 ==="
systemctl restart enterprise-backend

echo "等待服务启动..."
sleep 5

echo -e "\n=== 7. 测试产品API ==="
echo "测试产品列表API:"
curl -s -w "HTTP状态码: %{http_code}\n" "http://localhost:8000/api/product/?page=1&page_size=10" | head -10

echo -e "\n测试产品创建API:"
curl -s -X POST "http://localhost:8000/api/product/" \
  -H "Content-Type: application/json" \
  -d '{"title": "测试产品", "short_desc": "这是一个测试产品", "category_id": 2}' \
  -w "HTTP状态码: %{http_code}\n" | head -10

echo -e "\n=== 8. 验证新创建的产品 ==="
echo "检查数据库中的产品:"
mysql -u root -proot -e "USE enterprise_prod; SELECT * FROM products;"

echo -e "\n=== 9. 清理临时文件 ==="
rm -f /tmp/missing_models.py

echo "=== 缺失模型添加完成 ==="
EOF
}

# 主函数
main() {
    log_info "开始添加缺失的模型..."
    
    check_ssh_key
    test_ssh_connection
    
    if [ $? -eq 0 ]; then
        add_missing_models
        
        log_info "缺失模型添加完成！"
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
