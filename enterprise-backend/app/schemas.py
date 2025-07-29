from pydantic import BaseModel, EmailStr, validator
from typing import Optional, List
from datetime import datetime

class CompanyInfoBase(BaseModel):
    name: Optional[str] = None  # 公司名称
    logo_url: Optional[str] = None  # Logo图片路径
    email: Optional[EmailStr] = None  # 公司邮箱
    phone: Optional[str] = None  # 公司电话
    address: Optional[str] = None  # 公司地址
    working_hours: Optional[str] = None  # 工作时间
    company_image: Optional[str] = None  # 公司图片路径
    main_business: Optional[str] = None  # 主营业务简介（文本）
    main_pic_url: Optional[str] = None  # 主营业务配图路径
    about_text: Optional[str] = None  # 公司介绍（About页面）

class CompanyInfoCreate(CompanyInfoBase):
    pass

class CompanyInfoUpdate(CompanyInfoBase):
    pass

class CompanyInfoOut(CompanyInfoBase):
    id: int
    class Config:
        from_attributes = True

class CategoryBase(BaseModel):
    name: str
    parent_id: Optional[int] = None
    image: Optional[str] = None
    sort_order: Optional[int] = 0

class CategoryCreate(CategoryBase):
    pass

class CategoryOut(BaseModel):
    id: int
    name: str
    parent_id: Optional[int]
    image: Optional[str]
    sort_order: Optional[int]
    class Config:
        from_attributes = True

class ProductBase(BaseModel):
    title: str
    model: Optional[str] = None
    short_desc: Optional[str] = None  # 富文本简要介绍
    detail: Optional[str] = None  # 富文本详情介绍
    images: Optional[List[str]] = []  # 多张图片URL数组，最多5张
    category_id: int

    @validator('images')
    def validate_images(cls, v):
        if v and len(v) > 5:
            raise ValueError('最多只能上传5张图片')
        return v

class ProductCreate(ProductBase):
    pass

class ProductUpdate(ProductBase):
    pass

class ProductOut(BaseModel):
    id: int
    title: str
    model: Optional[str]
    short_desc: Optional[str]
    detail: Optional[str]
    images: Optional[List[str]]
    category_id: int
    created_at: datetime
    updated_at: datetime
    category: Optional[CategoryOut]
    class Config:
        from_attributes = True

class ProductListResponse(BaseModel):
    items: List[ProductOut]
    total: int
    page: int
    page_size: int
    total_pages: int

class InquiryBase(BaseModel):
    user_id: Optional[int] = None  # 用户ID（可选，关联用户表）
    product_id: Optional[int] = None
    product_title: Optional[str] = None  # 产品标题
    product_model: Optional[str] = None  # 产品型号
    product_image: Optional[str] = None  # 产品图片
    customer_name: str  # 询价人姓名
    customer_email: EmailStr  # 询价人邮箱
    customer_phone: Optional[str] = None  # 询价人电话
    inquiry_subject: Optional[str] = None  # 询价主题
    inquiry_content: str  # 询价内容

class InquiryCreate(InquiryBase):
    pass

class InquiryCreateWithUser(BaseModel):
    """兼容前端发送的询价数据格式"""
    product_id: Optional[int] = None
    product_name: Optional[str] = None  # 前端发送的字段名
    product_model: Optional[str] = None
    product_image: Optional[str] = None
    name: str  # 前端发送的字段名
    email: EmailStr  # 前端发送的字段名
    phone: Optional[str] = None  # 前端发送的字段名
    content: str  # 前端发送的字段名

class InquiryOut(BaseModel):
    id: int
    user_id: Optional[int]
    product_id: Optional[int]
    product_title: Optional[str]
    product_model: Optional[str]
    product_image: Optional[str]
    customer_name: str
    customer_email: str
    customer_phone: Optional[str]
    inquiry_subject: Optional[str]
    inquiry_content: str
    created_at: datetime
    product: Optional[ProductOut] = None
    user: Optional['UserOut'] = None
    class Config:
        from_attributes = True

class UserBase(BaseModel):
    username: Optional[str] = None  # 用户名/昵称（可选）
    email: Optional[str] = None  # 邮箱（可选）
    phone: Optional[str] = None  # 手机号（可选）
    role: Optional[str] = "customer"  # 用户角色：admin/customer/app_user/wx_user
    wx_openid: Optional[str] = None  # 微信OpenID
    wx_unionid: Optional[str] = None  # 微信UnionID
    app_openid: Optional[str] = None  # App端第三方登录openid
    avatar_url: Optional[str] = None  # 头像地址
    status: Optional[int] = 1  # 状态：1启用，0禁用

class UserCreate(UserBase):
    password: Optional[str] = None  # 密码（可选，第三方登录可能不需要）

class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    role: Optional[str] = None
    wx_openid: Optional[str] = None
    wx_unionid: Optional[str] = None
    app_openid: Optional[str] = None
    avatar_url: Optional[str] = None
    status: Optional[int] = None

class UserOut(BaseModel):
    id: int
    username: Optional[str]
    email: Optional[str]
    phone: Optional[str]
    role: str
    wx_openid: Optional[str]
    wx_unionid: Optional[str]
    app_openid: Optional[str]
    avatar_url: Optional[str]
    status: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class ChangePasswordRequest(BaseModel):
    username: str
    old_password: str
    new_password: str

# 轮播图相关schema
class CarouselImageBase(BaseModel):
    image_url: str
    caption: Optional[str] = None
    description: Optional[str] = None
    sort_order: Optional[int] = 0
    is_active: Optional[int] = 1

class CarouselImageCreate(CarouselImageBase):
    pass

class CarouselImageUpdate(CarouselImageBase):
    pass

class CarouselImageOut(BaseModel):
    id: int
    image_url: str
    caption: Optional[str]
    description: Optional[str]
    sort_order: int
    is_active: int
    class Config:
        from_attributes = True

# 联系我们字段相关schema
class ContactFieldBase(BaseModel):
    field_name: str
    field_label: str
    field_type: str
    is_required: Optional[int] = 0
    sort_order: Optional[int] = 0

class ContactFieldCreate(ContactFieldBase):
    pass

class ContactFieldUpdate(ContactFieldBase):
    pass

class ContactFieldOut(BaseModel):
    id: int
    field_name: str
    field_label: str
    field_type: str
    is_required: int
    sort_order: int
    class Config:
        from_attributes = True

# 联系我们提交相关schema
class ContactMessageBase(BaseModel):
    user_id: Optional[int] = None  # 用户ID（可选，关联用户表）
    name: str
    email: EmailStr
    phone: Optional[str] = None
    subject: Optional[str] = None
    message: str

class ContactMessageCreate(ContactMessageBase):
    pass

class ContactMessageOut(BaseModel):
    id: int
    user_id: Optional[int]
    name: str
    email: str
    phone: Optional[str]
    subject: Optional[str]
    message: str
    created_at: datetime
    user: Optional[UserOut] = None
    class Config:
        from_attributes = True

# 主营业务相关schema
class ServiceBase(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    sort_order: Optional[int] = 0
    is_active: Optional[int] = 1

class ServiceCreate(ServiceBase):
    pass

class ServiceUpdate(ServiceBase):
    pass

class ServiceOut(BaseModel):
    id: int
    name: str
    description: Optional[str]
    image_url: Optional[str]
    sort_order: int
    is_active: int
    class Config:
        from_attributes = True

# 客户端用户相关schema
class ClientUserRegister(BaseModel):
    username: str
    password: str
    email: EmailStr
    phone: Optional[str] = None

class ClientUserLogin(BaseModel):
    username: str  # 可以是用户名、邮箱或手机号
    password: str

class ClientUserProfile(BaseModel):
    username: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = None

class ClientUserProfileUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = None

class ClientUserOut(BaseModel):
    id: int
    username: Optional[str]
    email: Optional[str]
    phone: Optional[str]
    avatar_url: Optional[str]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

# 用户询价和咨询列表相关schema
class UserInquiryList(BaseModel):
    items: List[InquiryOut]
    total: int
    page: int
    page_size: int
    total_pages: int

class UserConsultationList(BaseModel):
    items: List[ContactMessageOut]
    total: int
    page: int
    page_size: int
    total_pages: int 