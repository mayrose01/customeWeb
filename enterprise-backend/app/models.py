from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, JSON
from sqlalchemy.orm import relationship, declarative_base
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
    __tablename__ = "category"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    parent_id = Column(Integer, ForeignKey('category.id'), nullable=True)
    image = Column(String(255), nullable=True)  # 分类图片
    sort_order = Column(Integer, default=0)  # 排序字段
    children = relationship("Category", backref='parent', remote_side=[id])

class Product(Base):
    __tablename__ = "product"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    model = Column(String(100))
    short_desc = Column(Text)  # 富文本简要介绍
    detail = Column(Text)  # 富文本详情介绍
    images = Column(JSON)  # 存储多张图片URL的JSON数组，最多5张
    category_id = Column(Integer, ForeignKey('category.id'))
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))  # 创建时间（北京时间）
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))  # 修改时间（北京时间）
    category = relationship("Category")

class Inquiry(Base):
    __tablename__ = "inquiry"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True)  # 用户ID（可选，关联用户表）
    product_id = Column(Integer, ForeignKey('product.id'), nullable=True)
    product_title = Column(String(255), nullable=True)  # 产品标题
    product_model = Column(String(100), nullable=True)  # 产品型号
    product_image = Column(String(255), nullable=True)  # 产品图片
    customer_name = Column(String(100), nullable=False)  # 询价人姓名
    customer_email = Column(String(100), nullable=False)  # 询价人邮箱
    customer_phone = Column(String(50), nullable=True)  # 询价人电话
    inquiry_subject = Column(String(255), nullable=True)  # 询价主题
    inquiry_content = Column(Text, nullable=False)  # 询价内容
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))
    product = relationship("Product")
    user = relationship("User")

class CarouselImage(Base):
    __tablename__ = "carousel_images"
    id = Column(Integer, primary_key=True, index=True)
    image_url = Column(String(255), nullable=False)  # 轮播图片路径
    caption = Column(String(255))  # 图片上的简短文字介绍
    description = Column(Text)  # 图片详细介绍（可选）
    sort_order = Column(Integer, default=0)  # 显示顺序
    is_active = Column(Integer, default=1)  # 是否启用（1/0）

class ContactField(Base):
    __tablename__ = "contact_fields"
    id = Column(Integer, primary_key=True, index=True)
    field_name = Column(String(50), nullable=False)  # 字段名，如name、email
    field_label = Column(String(50), nullable=False)  # 字段显示名称，如"姓名"
    field_type = Column(String(20), nullable=False)  # 类型（text, email等）
    is_required = Column(Integer, default=0)  # 是否必填（1/0）
    sort_order = Column(Integer, default=0)  # 显示顺序

class ContactMessage(Base):
    __tablename__ = "contact_messages"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True)  # 用户ID（可选，关联用户表）
    name = Column(String(100), nullable=False)  # 联系人姓名
    email = Column(String(100), nullable=False)  # 联系人邮箱
    phone = Column(String(50))  # 联系人电话
    subject = Column(String(200), nullable=True)  # 咨询主题
    message = Column(Text, nullable=False)  # 留言内容
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))  # 提交时间
    user = relationship("User")

class Service(Base):
    __tablename__ = "services"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)  # 业务名称
    description = Column(Text)  # 业务简介
    image_url = Column(String(255))  # 配图路径
    sort_order = Column(Integer, default=0)  # 显示顺序
    is_active = Column(Integer, default=1)  # 是否显示（1/0）

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True)  # 用户名/昵称（可选）
    password_hash = Column(String(255))  # 密码Hash（如果有密码则存储）
    email = Column(String(100))  # 邮箱（可选）
    phone = Column(String(50))  # 手机号（可选，便于手机号注册登录）
    role = Column(String(20), default="customer")  # 用户角色：admin/customer/app_user/wx_user
    wx_openid = Column(String(50), unique=True, nullable=True)  # 微信OpenID（小程序用户唯一标识）
    wx_unionid = Column(String(50), nullable=True)  # 微信UnionID（同一微信账号下唯一）
    app_openid = Column(String(50), unique=True, nullable=True)  # App端第三方登录openid（可选）
    avatar_url = Column(String(255), nullable=True)  # 头像地址
    status = Column(Integer, default=1)  # 1:启用, 0:禁用
    created_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))))  # 注册时间
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone(timedelta(hours=8))), onupdate=lambda: datetime.now(timezone(timedelta(hours=8))))  # 更新时间 