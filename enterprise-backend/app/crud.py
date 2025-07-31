import logging
from sqlalchemy.orm import Session, joinedload
from . import models, schemas
from typing import List, Optional
from passlib.context import CryptContext
from datetime import datetime

logger = logging.getLogger(__name__)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

# CompanyInfo

def get_company_info(db: Session) -> Optional[models.CompanyInfo]:
    return db.query(models.CompanyInfo).first()

def update_company_info(db: Session, data: schemas.CompanyInfoUpdate) -> models.CompanyInfo:
    info = get_company_info(db)
    if not info:
        # 如果没有记录，创建新记录，只包含非None的字段
        create_data = {k: v for k, v in data.dict().items() if v is not None}
        info = models.CompanyInfo(**create_data)
        db.add(info)
        logger.info(f"创建公司信息: {create_data}")
    else:
        # 如果有记录，只更新非None的字段
        old_data = {k: getattr(info, k) for k in data.dict(exclude_unset=True).keys()}
        update_data = data.dict(exclude_unset=True)
        for k, v in update_data.items():
            if v is not None:  # 只更新非None的字段
                setattr(info, k, v)
        logger.info(f"更新公司信息: 旧数据={old_data}, 新数据={update_data}")
    db.commit()
    db.refresh(info)
    return info

# Category

def get_categories(db: Session) -> List[models.Category]:
    return db.query(models.Category).all()

def get_categories_tree(db: Session) -> List[models.Category]:
    """获取分类树形结构，只返回顶级分类及其子分类"""
    return db.query(models.Category).filter(models.Category.parent_id.is_(None)).all()

def get_subcategories(db: Session, parent_id: int) -> List[models.Category]:
    """获取指定父分类下的所有子分类"""
    return db.query(models.Category).filter(models.Category.parent_id == parent_id).all()

def create_category(db: Session, data: schemas.CategoryCreate) -> models.Category:
    category = models.Category(**data.dict())
    db.add(category)
    db.commit()
    db.refresh(category)
    logger.info(f"创建分类: ID={category.id}, 名称={category.name}, 父级ID={category.parent_id}")
    return category

def get_category(db: Session, category_id: int) -> Optional[models.Category]:
    return db.query(models.Category).filter(models.Category.id == category_id).first()

def update_category(db: Session, category_id: int, data: schemas.CategoryCreate) -> Optional[models.Category]:
    category = get_category(db, category_id)
    if not category:
        logger.warning(f"尝试更新不存在的分类: ID={category_id}")
        return None
    
    # 记录更新前的数据
    old_data = {
        'id': category.id,
        'name': category.name,
        'parent_id': category.parent_id,
        'image': category.image,
        'sort_order': category.sort_order
    }
    
    # 检查该分类是否有子分类
    has_children = db.query(models.Category).filter(models.Category.parent_id == category_id).first() is not None
    
    # 如果是顶级分类且有子分类，不允许修改父级分类
    if category.parent_id is None and has_children:
        # 只允许修改名称、排序、图片，不允许修改父级分类
        if data.parent_id is not None:
            logger.warning(f"尝试修改有子分类的顶级分类父级: ID={category_id}, 新父级ID={data.parent_id}")
            raise ValueError("顶级分类下有子分类时，不能修改父级分类")
        
        # 只更新允许的字段
        if data.name is not None:
            category.name = data.name
        if data.sort_order is not None:
            category.sort_order = data.sort_order
        if data.image is not None:
            category.image = data.image
    else:
        # 其他情况正常更新
        for k, v in data.dict(exclude_unset=True).items():
            setattr(category, k, v)
    
    db.commit()
    db.refresh(category)
    
    new_data = {
        'id': category.id,
        'name': category.name,
        'parent_id': category.parent_id,
        'image': category.image,
        'sort_order': category.sort_order
    }
    logger.info(f"更新分类: ID={category_id}, 旧数据={old_data}, 新数据={new_data}")
    return category

def delete_category(db: Session, category_id: int) -> bool:
    category = get_category(db, category_id)
    if not category:
        logger.warning(f"尝试删除不存在的分类: ID={category_id}")
        return False
    
    # 记录删除前的数据
    category_data = {
        'id': category.id,
        'name': category.name,
        'parent_id': category.parent_id,
        'image': category.image,
        'sort_order': category.sort_order
    }
    
    # 检查该分类是否有子分类
    has_children = db.query(models.Category).filter(models.Category.parent_id == category_id).first() is not None
    
    # 如果有子分类，不允许删除
    if has_children:
        logger.warning(f"尝试删除有子分类的分类: ID={category_id}, 名称={category.name}")
        raise ValueError("该分类下有子分类，请先删除子分类")
    
    # 检查该分类下是否有产品
    has_products = db.query(models.Product).filter(models.Product.category_id == category_id).first() is not None
    if has_products:
        logger.warning(f"尝试删除有产品的分类: ID={category_id}, 名称={category.name}")
        raise ValueError("该分类下有产品，请先删除或移动产品")
    
    db.delete(category)
    db.commit()
    logger.warning(f"删除分类: ID={category_id}, 数据={category_data}, 时间={datetime.now()}")
    return True

# Product

def get_products(db: Session, skip=0, limit=100, title=None, product_id=None, model=None, category_id=None) -> List[models.Product]:
    query = db.query(models.Product).options(joinedload(models.Product.category))
    
    # 添加搜索条件
    if title:
        query = query.filter(models.Product.title.contains(title))
    if product_id:
        query = query.filter(models.Product.id == product_id)
    if model:
        query = query.filter(models.Product.model.contains(model))
    if category_id:
        query = query.filter(models.Product.category_id == category_id)
    
    # 按修改时间降序排列
    return query.order_by(models.Product.updated_at.desc()).offset(skip).limit(limit).all()

def get_products_with_count(db: Session, skip=0, limit=100, title=None, product_id=None, model=None, category_id=None) -> tuple[List[models.Product], int]:
    """获取产品列表和总数"""
    query = db.query(models.Product).options(joinedload(models.Product.category))
    
    # 添加搜索条件
    if title:
        query = query.filter(models.Product.title.contains(title))
    if product_id:
        query = query.filter(models.Product.id == product_id)
    if model:
        query = query.filter(models.Product.model.contains(model))
    if category_id:
        query = query.filter(models.Product.category_id == category_id)
    
    # 获取总数
    total = query.count()
    
    # 按修改时间降序排列并分页
    products = query.order_by(models.Product.updated_at.desc()).offset(skip).limit(limit).all()
    
    return products, total

def create_product(db: Session, data: schemas.ProductCreate) -> models.Product:
    # 验证产品只能挂在子分类下
    category = get_category(db, data.category_id)
    if not category:
        logger.error(f"尝试创建产品时指定了不存在的分类: category_id={data.category_id}")
        raise ValueError("指定的分类不存在")
    
    # 检查是否为子分类（有父分类的分类）
    if category.parent_id is None:
        logger.warning(f"尝试将产品挂在大类目下: category_id={data.category_id}, 分类名称={category.name}")
        raise ValueError("产品只能挂在子分类下，不能直接挂在大类目下")
    
    product = models.Product(**data.dict())
    db.add(product)
    db.commit()
    db.refresh(product)
    logger.info(f"创建产品: ID={product.id}, 标题={product.title}, 分类ID={product.category_id}, 分类名称={category.name}")
    return product

def get_product(db: Session, product_id: int) -> Optional[models.Product]:
    return db.query(models.Product).options(joinedload(models.Product.category)).filter(models.Product.id == product_id).first()

def get_all_products_for_client(db: Session, category_id: Optional[int] = None, search: Optional[str] = None) -> List[models.Product]:
    """
    获取所有产品（客户端专用）
    返回所有产品，包含分类信息，支持按分类筛选和搜索
    """
    query = db.query(models.Product).options(joinedload(models.Product.category))
    
    # 按分类筛选
    if category_id is not None:
        query = query.filter(models.Product.category_id == category_id)
    
    # 按关键词搜索
    if search:
        search_term = f"%{search}%"
        query = query.filter(
            models.Product.title.like(search_term) |
            models.Product.model.like(search_term) |
            models.Product.short_desc.like(search_term)
        )
    
    # 按创建时间倒序排列
    query = query.order_by(models.Product.created_at.desc())
    
    return query.all()

def get_client_products(db: Session) -> List[models.Product]:
    """获取客户端产品列表（简化版）"""
    return get_all_products_for_client(db)

def update_product(db: Session, product_id: int, data: schemas.ProductUpdate) -> Optional[models.Product]:
    product = get_product(db, product_id)
    if not product:
        logger.warning(f"尝试更新不存在的产品: ID={product_id}")
        return None
    
    # 记录更新前的数据
    old_data = {
        'id': product.id,
        'title': product.title,
        'model': product.model,
        'category_id': product.category_id,
        'images': product.images
    }
    
    # 如果更新了分类，验证新分类是否为子分类
    if data.category_id and data.category_id != product.category_id:
        category = get_category(db, data.category_id)
        if not category:
            logger.error(f"尝试更新产品时指定了不存在的分类: product_id={product_id}, category_id={data.category_id}")
            raise ValueError("指定的分类不存在")
        
        # 检查是否为子分类（有父分类的分类）
        if category.parent_id is None:
            logger.warning(f"尝试将产品挂在大类目下: product_id={product_id}, category_id={data.category_id}, 分类名称={category.name}")
            raise ValueError("产品只能挂在子分类下，不能直接挂在大类目下")
    
    for k, v in data.dict(exclude_unset=True).items():
        setattr(product, k, v)
    db.commit()
    db.refresh(product)
    
    new_data = {
        'id': product.id,
        'title': product.title,
        'model': product.model,
        'category_id': product.category_id,
        'images': product.images
    }
    logger.info(f"更新产品: ID={product_id}, 旧数据={old_data}, 新数据={new_data}")
    return product

def delete_product(db: Session, product_id: int) -> bool:
    product = get_product(db, product_id)
    if not product:
        logger.warning(f"尝试删除不存在的产品: ID={product_id}")
        return False
    
    # 记录删除前的数据
    product_data = {
        'id': product.id,
        'title': product.title,
        'model': product.model,
        'category_id': product.category_id,
        'images': product.images,
        'short_desc': product.short_desc,
        'detail': product.detail
    }
    
    db.delete(product)
    db.commit()
    logger.warning(f"删除产品: ID={product_id}, 数据={product_data}, 时间={datetime.now()}")
    return True

def copy_product(db: Session, product_id: int) -> models.Product:
    """复制产品"""
    original_product = get_product(db, product_id)
    if not original_product:
        logger.error(f"尝试复制不存在的产品: ID={product_id}")
        raise ValueError("产品不存在")
    
    # 创建新产品对象，复制原产品的所有字段（除了id和时间字段）
    new_product_data = {
        'title': original_product.title,
        'model': original_product.model,
        'short_desc': original_product.short_desc,
        'detail': original_product.detail,
        'images': original_product.images,
        'category_id': original_product.category_id
    }
    
    new_product = models.Product(**new_product_data)
    # 创建时间和修改时间会自动设置为当前时间
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    
    logger.info(f"复制产品: 原产品ID={product_id}, 新产品ID={new_product.id}, 标题={new_product.title}")
    return new_product

# Inquiry

def create_inquiry(db: Session, data: schemas.InquiryCreate) -> models.Inquiry:
    # 如果提供了产品ID，自动填充产品信息
    if data.product_id:
        product = get_product(db, data.product_id)
        if product:
            if not data.product_title:
                data.product_title = product.title
            if not data.product_model:
                data.product_model = product.model
    
    inquiry = models.Inquiry(**data.dict())
    db.add(inquiry)
    db.commit()
    db.refresh(inquiry)
    logger.info(f"创建询盘: ID={inquiry.id}, 客户={inquiry.customer_name}, 邮箱={inquiry.customer_email}, 手机={inquiry.customer_phone}")
    return inquiry

def get_inquiries(db: Session, skip=0, limit=100) -> List[models.Inquiry]:
    return db.query(models.Inquiry).options(joinedload(models.Inquiry.product)).offset(skip).limit(limit).all()

def get_inquiry(db: Session, inquiry_id: int) -> Optional[models.Inquiry]:
    return db.query(models.Inquiry).options(joinedload(models.Inquiry.product)).filter(models.Inquiry.id == inquiry_id).first()

def delete_inquiry(db: Session, inquiry_id: int) -> bool:
    inquiry = get_inquiry(db, inquiry_id)
    if not inquiry:
        logger.warning(f"尝试删除不存在的询盘: ID={inquiry_id}")
        return False
    
    # 记录删除前的数据
    inquiry_data = {
        'id': inquiry.id,
        'product_id': inquiry.product_id,
        'product_title': inquiry.product_title,
        'customer_name': inquiry.customer_name,
        'customer_email': inquiry.customer_email,
        'customer_phone': inquiry.customer_phone,
        'inquiry_content': inquiry.inquiry_content,
        'created_at': inquiry.created_at
    }
    
    db.delete(inquiry)
    db.commit()
    logger.warning(f"删除询盘: ID={inquiry_id}, 数据={inquiry_data}, 时间={datetime.now()}")
    return True

# AdminUser

def get_user_by_username(db: Session, username: str) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.username == username).first()

def get_user_by_id(db: Session, user_id: int) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_user_by_wx_openid(db: Session, wx_openid: str) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.wx_openid == wx_openid).first()

def get_user_by_app_openid(db: Session, app_openid: str) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.app_openid == app_openid).first()

def create_user(db: Session, data: schemas.UserCreate) -> models.User:
    user_data = data.dict(exclude={'password'})
    
    # 如果有密码，则加密存储
    if data.password:
        user_data['password_hash'] = get_password_hash(data.password)
    
    # 确保新用户状态为启用
    if 'status' not in user_data or user_data['status'] is None:
        user_data['status'] = 1
    
    user = models.User(**user_data)
    db.add(user)
    db.commit()
    db.refresh(user)
    logger.info(f"创建用户: 用户名={user.username}, 角色={user.role}, 状态={user.status}")
    return user

def update_user(db: Session, user_id: int, data: schemas.UserUpdate) -> Optional[models.User]:
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        return None
    
    for k, v in data.dict(exclude_unset=True).items():
        setattr(user, k, v)
    
    db.commit()
    db.refresh(user)
    logger.info(f"更新用户: ID={user_id}")
    return user

def get_users(db: Session, skip=0, limit=100, role=None, status=None) -> List[models.User]:
    query = db.query(models.User)
    
    # 按角色筛选
    if role:
        query = query.filter(models.User.role == role)
    
    # 按状态筛选
    if status is not None:
        query = query.filter(models.User.status == status)
    
    return query.offset(skip).limit(limit).all()

def delete_user(db: Session, user_id: int) -> bool:
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        return False
    
    db.delete(user)
    db.commit()
    logger.info(f"删除用户: ID={user_id}")
    return True

# CarouselImage

def get_carousel_images(db: Session, active_only: bool = True) -> List[models.CarouselImage]:
    """获取轮播图列表"""
    query = db.query(models.CarouselImage)
    if active_only:
        query = query.filter(models.CarouselImage.is_active == 1)
    return query.order_by(models.CarouselImage.sort_order).all()

def get_carousel_admin(db: Session) -> List[models.CarouselImage]:
    """获取轮播图列表（后台管理，不限制激活状态）"""
    return db.query(models.CarouselImage).order_by(models.CarouselImage.sort_order).all()

def create_carousel_image(db: Session, data: schemas.CarouselImageCreate) -> models.CarouselImage:
    """创建轮播图"""
    carousel_image = models.CarouselImage(**data.dict())
    db.add(carousel_image)
    db.commit()
    db.refresh(carousel_image)
    logger.info(f"创建轮播图: ID={carousel_image.id}, 标题={carousel_image.caption}")
    return carousel_image

def get_carousel_image(db: Session, image_id: int) -> Optional[models.CarouselImage]:
    """获取单个轮播图"""
    return db.query(models.CarouselImage).filter(models.CarouselImage.id == image_id).first()

def update_carousel_image(db: Session, image_id: int, data: schemas.CarouselImageUpdate) -> Optional[models.CarouselImage]:
    """更新轮播图"""
    carousel_image = get_carousel_image(db, image_id)
    if not carousel_image:
        return None
    
    for k, v in data.dict(exclude_unset=True).items():
        setattr(carousel_image, k, v)
    
    db.commit()
    db.refresh(carousel_image)
    logger.info(f"更新轮播图: ID={image_id}")
    return carousel_image

def delete_carousel_image(db: Session, image_id: int) -> bool:
    """删除轮播图"""
    carousel_image = get_carousel_image(db, image_id)
    if not carousel_image:
        return False
    
    db.delete(carousel_image)
    db.commit()
    logger.info(f"删除轮播图: ID={image_id}")
    return True

# ContactField

def get_contact_fields(db: Session) -> List[models.ContactField]:
    """获取联系我们字段列表"""
    return db.query(models.ContactField).order_by(models.ContactField.sort_order).all()

def create_contact_field(db: Session, data: schemas.ContactFieldCreate) -> models.ContactField:
    """创建联系我们字段"""
    contact_field = models.ContactField(**data.dict())
    db.add(contact_field)
    db.commit()
    db.refresh(contact_field)
    logger.info(f"创建联系我们字段: ID={contact_field.id}, 字段名={contact_field.field_name}")
    return contact_field

def get_contact_field(db: Session, field_id: int) -> Optional[models.ContactField]:
    """获取单个联系我们字段"""
    return db.query(models.ContactField).filter(models.ContactField.id == field_id).first()

def update_contact_field(db: Session, field_id: int, data: schemas.ContactFieldUpdate) -> Optional[models.ContactField]:
    """更新联系我们字段"""
    contact_field = get_contact_field(db, field_id)
    if not contact_field:
        return None
    
    for k, v in data.dict(exclude_unset=True).items():
        setattr(contact_field, k, v)
    
    db.commit()
    db.refresh(contact_field)
    logger.info(f"更新联系我们字段: ID={field_id}")
    return contact_field

def delete_contact_field(db: Session, field_id: int) -> bool:
    """删除联系我们字段"""
    contact_field = get_contact_field(db, field_id)
    if not contact_field:
        return False
    
    db.delete(contact_field)
    db.commit()
    logger.info(f"删除联系我们字段: ID={field_id}")
    return True

# ContactMessage

def create_contact_message(db: Session, data: schemas.ContactMessageCreate) -> models.ContactMessage:
    """创建联系我们提交"""
    contact_message = models.ContactMessage(**data.dict())
    db.add(contact_message)
    db.commit()
    db.refresh(contact_message)
    logger.info(f"创建联系我们提交: ID={contact_message.id}, 姓名={contact_message.name}, 邮箱={contact_message.email}")
    return contact_message

def get_contact_messages(db: Session, skip=0, limit=100) -> List[models.ContactMessage]:
    """获取联系我们提交列表"""
    return db.query(models.ContactMessage).order_by(models.ContactMessage.created_at.desc()).offset(skip).limit(limit).all()

def get_contact_message(db: Session, message_id: int) -> Optional[models.ContactMessage]:
    """获取单个联系我们提交"""
    return db.query(models.ContactMessage).filter(models.ContactMessage.id == message_id).first()

def delete_contact_message(db: Session, message_id: int) -> bool:
    """删除联系我们提交"""
    contact_message = get_contact_message(db, message_id)
    if not contact_message:
        return False
    
    db.delete(contact_message)
    db.commit()
    logger.info(f"删除联系我们提交: ID={message_id}")
    return True

# Service

def get_services(db: Session, active_only: bool = True) -> List[models.Service]:
    """获取主营业务列表"""
    query = db.query(models.Service)
    if active_only:
        query = query.filter(models.Service.is_active == 1)
    return query.order_by(models.Service.sort_order).all()

def get_services_admin(db: Session) -> List[models.Service]:
    """获取服务列表（后台管理，不限制激活状态）"""
    return db.query(models.Service).order_by(models.Service.sort_order).all()

def create_service(db: Session, data: schemas.ServiceCreate) -> models.Service:
    """创建主营业务"""
    service = models.Service(**data.dict())
    db.add(service)
    db.commit()
    db.refresh(service)
    logger.info(f"创建主营业务: ID={service.id}, 名称={service.name}")
    return service

def get_service(db: Session, service_id: int) -> Optional[models.Service]:
    """获取单个主营业务"""
    return db.query(models.Service).filter(models.Service.id == service_id).first()

def update_service(db: Session, service_id: int, data: schemas.ServiceUpdate) -> Optional[models.Service]:
    """更新主营业务"""
    service = get_service(db, service_id)
    if not service:
        return None
    
    for k, v in data.dict(exclude_unset=True).items():
        setattr(service, k, v)
    
    db.commit()
    db.refresh(service)
    logger.info(f"更新主营业务: ID={service_id}")
    return service

def delete_service(db: Session, service_id: int) -> bool:
    service = get_service(db, service_id)
    if not service:
        logger.warning(f"尝试删除不存在的服务: ID={service_id}")
        return False
    
    logger.info(f"删除服务: ID={service_id}, 名称={service.name}")
    db.delete(service)
    db.commit()
    return True

# 客户端用户相关功能

def get_user_by_email(db: Session, email: str) -> Optional[models.User]:
    """通过邮箱获取用户"""
    return db.query(models.User).filter(models.User.email == email).first()

def get_user_by_phone(db: Session, phone: str) -> Optional[models.User]:
    """通过手机号获取用户"""
    return db.query(models.User).filter(models.User.phone == phone).first()

def authenticate_user(db: Session, username: str, password: str) -> Optional[models.User]:
    """管理员用户登录验证"""
    # 尝试通过用户名、邮箱或手机号查找用户
    user = get_user_by_username(db, username)
    if not user:
        user = get_user_by_email(db, username)
    if not user:
        user = get_user_by_phone(db, username)
    
    if not user:
        logger.warning(f"用户不存在: {username}")
        return None
    
    if not verify_password(password, user.password_hash):
        logger.warning(f"密码错误: {username}")
        return None
    
    if user.status != 1 and user.status != '1':
        logger.warning(f"用户已被禁用: {username}")
        return None
    
    # 检查用户角色是否为管理员
    if user.role != 'admin':
        logger.warning(f"用户不是管理员: {username}, 角色={user.role}")
        return None
    
    logger.info(f"管理员用户登录成功: {username}")
    return user

def authenticate_client_user(db: Session, username: str, password: str) -> Optional[models.User]:
    """客户端用户登录验证"""
    # 尝试通过用户名、邮箱或手机号查找用户
    user = get_user_by_username(db, username)
    if not user:
        user = get_user_by_email(db, username)
    if not user:
        user = get_user_by_phone(db, username)
    
    if not user:
        logger.warning(f"用户不存在: {username}")
        return None
    
    if not verify_password(password, user.password_hash):
        logger.warning(f"密码错误: {username}")
        return None
    
    if user.status != 1 and user.status != '1':
        logger.warning(f"用户已被禁用: {username}")
        return None
    
    logger.info(f"客户端用户登录成功: {username}")
    return user

def create_client_user(db: Session, data: schemas.ClientUserRegister) -> models.User:
    """创建客户端用户"""
    # 检查用户名是否已存在
    if get_user_by_username(db, data.username):
        raise ValueError("用户名已存在")
    
    # 检查邮箱是否已存在
    if get_user_by_email(db, data.email):
        raise ValueError("邮箱已存在")
    
    # 检查手机号是否已存在（如果提供了手机号）
    if data.phone and get_user_by_phone(db, data.phone):
        raise ValueError("手机号已存在")
    
    # 创建用户数据
    user_data = {
        "username": data.username,
        "password_hash": get_password_hash(data.password),
        "email": data.email,
        "phone": data.phone,
        "role": "customer",  # 客户端用户角色
        "status": 1  # 启用状态
    }
    
    user = models.User(**user_data)
    db.add(user)
    db.commit()
    db.refresh(user)
    
    logger.info(f"创建客户端用户: ID={user.id}, 用户名={user.username}, 邮箱={user.email}")
    return user

def update_client_user_profile(db: Session, user_id: int, data: schemas.ClientUserProfileUpdate) -> Optional[models.User]:
    """更新客户端用户信息"""
    user = get_user_by_id(db, user_id)
    if not user:
        logger.warning(f"尝试更新不存在的用户: ID={user_id}")
        return None
    
    # 检查用户名唯一性（如果更新用户名）
    if data.username and data.username != user.username:
        if get_user_by_username(db, data.username):
            raise ValueError("用户名已存在")
    
    # 检查邮箱唯一性（如果更新邮箱）
    if data.email and data.email != user.email:
        if get_user_by_email(db, data.email):
            raise ValueError("邮箱已存在")
    
    # 检查手机号唯一性（如果更新手机号）
    if data.phone and data.phone != user.phone:
        if get_user_by_phone(db, data.phone):
            raise ValueError("手机号已存在")
    
    # 更新用户信息
    update_data = data.dict(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(user, field, value)
    
    user.updated_at = datetime.now()
    db.commit()
    db.refresh(user)
    
    logger.info(f"更新客户端用户信息: ID={user_id}, 更新字段={list(update_data.keys())}")
    return user

def get_user_inquiries(db: Session, user_id: int, skip: int = 0, limit: int = 100) -> tuple[List[models.Inquiry], int]:
    """获取用户的询价列表"""
    query = db.query(models.Inquiry).filter(models.Inquiry.user_id == user_id)
    total = query.count()
    inquiries = query.offset(skip).limit(limit).all()
    return inquiries, total

def get_user_consultations(db: Session, user_id: int, skip: int = 0, limit: int = 100) -> tuple[List[models.ContactMessage], int]:
    """获取用户的咨询列表"""
    query = db.query(models.ContactMessage).filter(models.ContactMessage.user_id == user_id)
    total = query.count()
    consultations = query.offset(skip).limit(limit).all()
    return consultations, total

def create_inquiry_with_user(db: Session, data: schemas.InquiryCreate, user_id: Optional[int] = None) -> models.Inquiry:
    """创建询价记录（支持用户关联）"""
    # 处理前端发送的数据格式
    inquiry_data = {}
    
    # 映射字段名
    inquiry_data["product_id"] = getattr(data, 'product_id', None)
    inquiry_data["product_title"] = getattr(data, 'product_name', None) or getattr(data, 'product_title', None)
    inquiry_data["product_model"] = getattr(data, 'product_model', None)
    inquiry_data["product_image"] = getattr(data, 'product_image', None)
    inquiry_data["customer_name"] = getattr(data, 'name', None) or getattr(data, 'customer_name', None)
    inquiry_data["customer_email"] = getattr(data, 'email', None) or getattr(data, 'customer_email', None)
    inquiry_data["customer_phone"] = getattr(data, 'phone', None) or getattr(data, 'customer_phone', None)
    inquiry_data["inquiry_content"] = getattr(data, 'content', None) or getattr(data, 'inquiry_content', None)
    inquiry_data["inquiry_subject"] = getattr(data, 'inquiry_subject', None)
    
    if user_id:
        inquiry_data["user_id"] = user_id
    
    # 如果提供了产品ID，自动填充产品信息
    if inquiry_data["product_id"]:
        product = get_product(db, inquiry_data["product_id"])
        if product:
            inquiry_data["product_title"] = product.title
            inquiry_data["product_model"] = product.model
            if product.images and len(product.images) > 0:
                inquiry_data["product_image"] = product.images[0]  # 使用第一张图片
    
    inquiry = models.Inquiry(**inquiry_data)
    db.add(inquiry)
    db.commit()
    db.refresh(inquiry)
    
    logger.info(f"创建询价记录: ID={inquiry.id}, 用户ID={user_id}, 产品ID={inquiry_data['product_id']}")
    return inquiry

def create_contact_message_with_user(db: Session, data: schemas.ContactMessageCreate, user_id: Optional[int] = None) -> models.ContactMessage:
    """创建咨询记录（支持用户关联）"""
    message_data = data.dict()
    if user_id:
        message_data["user_id"] = user_id
    
    message = models.ContactMessage(**message_data)
    db.add(message)
    db.commit()
    db.refresh(message)
    
    logger.info(f"创建咨询记录: ID={message.id}, 用户ID={user_id}")
    return message 