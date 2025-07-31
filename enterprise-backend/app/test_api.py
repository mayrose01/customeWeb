from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_test_session
from app import crud, schemas
from app.core.security import create_access_token, get_current_user
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.responses import FileResponse
from datetime import timedelta
import os
import uuid

router = APIRouter()

# 确保测试环境上传目录存在
TEST_UPLOAD_DIR = "uploads_test"
if not os.path.exists(TEST_UPLOAD_DIR):
    os.makedirs(TEST_UPLOAD_DIR)

# 测试环境API路由
# 这些路由使用测试数据库，但使用真实的API逻辑

@router.get("/company/")
def get_company_info(db: Session = Depends(get_test_session)):
    """获取公司信息（测试环境）"""
    return crud.get_company_info(db)

@router.get("/category/")
def get_categories(db: Session = Depends(get_test_session)):
    """获取分类列表（测试环境）"""
    return crud.get_categories(db)

@router.get("/category/tree")
def get_categories_tree(db: Session = Depends(get_test_session)):
    """获取分类树（测试环境）"""
    return crud.get_categories_tree(db)

@router.get("/category/{parent_id}/subcategories")
def get_subcategories(parent_id: int, db: Session = Depends(get_test_session)):
    """获取子分类（测试环境）"""
    return crud.get_subcategories(db, parent_id)

@router.get("/category/{category_id}")
def get_category(category_id: int, db: Session = Depends(get_test_session)):
    """获取单个分类（测试环境）"""
    return crud.get_category(db, category_id)

@router.get("/product/")
def get_products(db: Session = Depends(get_test_session)):
    """获取产品列表（测试环境）"""
    return crud.get_products(db)

@router.get("/product/{product_id}")
def get_product(product_id: int, db: Session = Depends(get_test_session)):
    """获取单个产品（测试环境）"""
    return crud.get_product(db, product_id)

@router.get("/client-product/")
def get_client_products(db: Session = Depends(get_test_session)):
    """获取客户端产品列表（测试环境）"""
    return crud.get_client_products(db)

@router.get("/service/")
def get_services_admin(db: Session = Depends(get_test_session)):
    """获取服务列表（后台管理，测试环境）"""
    return crud.get_services_admin(db)

@router.get("/service/client")
def get_services(db: Session = Depends(get_test_session)):
    """获取服务列表（测试环境）"""
    return crud.get_services(db)

@router.get("/carousel/")
def get_carousel_admin(db: Session = Depends(get_test_session)):
    """获取轮播图列表（后台管理，测试环境）"""
    return crud.get_carousel_admin(db)

@router.get("/carousel/client")
def get_carousel_images(db: Session = Depends(get_test_session)):
    """获取轮播图（测试环境）"""
    return crud.get_carousel_images(db)

@router.get("/inquiry/")
def get_inquiries(db: Session = Depends(get_test_session)):
    """获取询价列表（测试环境）"""
    return crud.get_inquiries(db)

@router.get("/inquiry/{inquiry_id}")
def get_inquiry(inquiry_id: int, db: Session = Depends(get_test_session)):
    """获取单个询价（测试环境）"""
    return crud.get_inquiry(db, inquiry_id)

@router.get("/contact-message/")
def get_contact_messages(db: Session = Depends(get_test_session)):
    """获取联系消息列表（测试环境）"""
    return crud.get_contact_messages(db)

@router.get("/contact-message/{message_id}")
def get_contact_message(message_id: int, db: Session = Depends(get_test_session)):
    """获取单个联系消息（测试环境）"""
    return crud.get_contact_message(db, message_id)

@router.get("/user/")
def get_users(db: Session = Depends(get_test_session)):
    """获取用户列表（测试环境）"""
    return crud.get_users(db)

@router.get("/user/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_test_session)):
    """获取单个用户（测试环境）"""
    return crud.get_user(db, user_id)

@router.get("/user/current")
def get_current_user_info(current_user: dict = Depends(get_current_user)):
    """获取当前用户信息（测试环境）"""
    return current_user

@router.post("/user/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_test_session)):
    """用户登录（测试环境）"""
    user = crud.authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="用户名或密码错误"
        )
    
    access_token_expires = timedelta(minutes=1440)  # 24小时
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "role": user.role
        }
    }

@router.get("/contact-field/")
def get_contact_fields(db: Session = Depends(get_test_session)):
    """获取联系字段列表（测试环境）"""
    return crud.get_contact_fields(db)

@router.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    """
    上传图片文件（测试环境）
    支持 JPG/PNG 格式，大小限制 2MB
    """
    # 检查文件类型
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="只支持图片文件")
    
    # 检查文件大小 (2MB = 2 * 1024 * 1024 bytes)
    file_size = 0
    content = await file.read()
    file_size = len(content)
    
    if file_size > 2 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="文件大小不能超过2MB")
    
    # 生成唯一文件名
    file_extension = os.path.splitext(file.filename)[1].lower()
    if file_extension not in ['.jpg', '.jpeg', '.png']:
        raise HTTPException(status_code=400, detail="只支持 JPG/PNG 格式")
    
    unique_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = os.path.join(TEST_UPLOAD_DIR, unique_filename)
    
    # 保存文件
    with open(file_path, "wb") as f:
        f.write(content)
    
    # 返回文件URL - 测试环境使用 /test/uploads/ 路径
    file_url = f"/test/uploads/{unique_filename}"
    
    return {
        "filename": unique_filename,
        "url": file_url,
        "size": file_size,
        "content_type": file.content_type
    }

@router.get("/upload/{filename}")
async def get_file(filename: str):
    """
    获取上传的文件（测试环境）
    """
    file_path = os.path.join(TEST_UPLOAD_DIR, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="文件不存在")
    
    return FileResponse(file_path)

# 其他API路由，使用真实的CRUD操作
@router.post("/company/")
def create_company_info(company_data: dict, db: Session = Depends(get_test_session)):
    """创建公司信息（测试环境）"""
    return crud.create_company_info(db, company_data)

@router.put("/company/{company_id}")
def update_company_info(company_id: int, company_data: dict, db: Session = Depends(get_test_session)):
    """更新公司信息（测试环境）"""
    return crud.update_company_info(db, company_id, company_data)

@router.post("/category/")
def create_category(category_data: dict, db: Session = Depends(get_test_session)):
    """创建分类（测试环境）"""
    return crud.create_category(db, category_data)

@router.put("/category/{category_id}")
def update_category(category_id: int, category_data: dict, db: Session = Depends(get_test_session)):
    """更新分类（测试环境）"""
    return crud.update_category(db, category_id, category_data)

@router.delete("/category/{category_id}")
def delete_category(category_id: int, db: Session = Depends(get_test_session)):
    """删除分类（测试环境）"""
    return crud.delete_category(db, category_id)

@router.post("/product/")
def create_product(product_data: dict, db: Session = Depends(get_test_session)):
    """创建产品（测试环境）"""
    return crud.create_product(db, product_data)

@router.put("/product/{product_id}")
def update_product(product_id: int, product_data: dict, db: Session = Depends(get_test_session)):
    """更新产品（测试环境）"""
    return crud.update_product(db, product_id, product_data)

@router.delete("/product/{product_id}")
def delete_product(product_id: int, db: Session = Depends(get_test_session)):
    """删除产品（测试环境）"""
    return crud.delete_product(db, product_id)

@router.post("/carousel/")
def create_carousel(carousel_data: dict, db: Session = Depends(get_test_session)):
    """创建轮播图（测试环境）"""
    return crud.create_carousel(db, carousel_data)

@router.put("/carousel/{carousel_id}")
def update_carousel(carousel_id: int, carousel_data: dict, db: Session = Depends(get_test_session)):
    """更新轮播图（测试环境）"""
    return crud.update_carousel(db, carousel_id, carousel_data)

@router.delete("/carousel/{carousel_id}")
def delete_carousel(carousel_id: int, db: Session = Depends(get_test_session)):
    """删除轮播图（测试环境）"""
    return crud.delete_carousel(db, carousel_id)

@router.post("/service/")
def create_service(service_data: dict, db: Session = Depends(get_test_session)):
    """创建服务（测试环境）"""
    return crud.create_service(db, service_data)

@router.put("/service/{service_id}")
def update_service(service_id: int, service_data: dict, db: Session = Depends(get_test_session)):
    """更新服务（测试环境）"""
    return crud.update_service(db, service_id, service_data)

@router.delete("/service/{service_id}")
def delete_service(service_id: int, db: Session = Depends(get_test_session)):
    """删除服务（测试环境）"""
    return crud.delete_service(db, service_id)

# 客户端用户相关API
@router.post("/client-user/register")
def register_client_user(user_data: dict, db: Session = Depends(get_test_session)):
    """注册客户端用户（测试环境）"""
    return crud.register_client_user(db, user_data)

@router.post("/client-user/login")
def login_client_user(login_data: dict, db: Session = Depends(get_test_session)):
    """客户端用户登录（测试环境）"""
    user = crud.authenticate_client_user(db, login_data.get("username"), login_data.get("password"))
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="用户名或密码错误"
        )
    
    access_token_expires = timedelta(minutes=1440)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email
        }
    }

@router.get("/client-user/profile")
def get_client_user_profile(db: Session = Depends(get_test_session)):
    """获取客户端用户资料（测试环境）"""
    return crud.get_client_user_profile(db)

@router.put("/client-user/profile")
def update_client_user_profile(profile_data: dict, db: Session = Depends(get_test_session)):
    """更新客户端用户资料（测试环境）"""
    return crud.update_client_user_profile(db, profile_data)

@router.get("/client-user/inquiries")
def get_client_user_inquiries(db: Session = Depends(get_test_session)):
    """获取客户端用户询价（测试环境）"""
    return crud.get_client_user_inquiries(db)

@router.get("/client-user/consultations")
def get_client_user_consultations(db: Session = Depends(get_test_session)):
    """获取客户端用户咨询（测试环境）"""
    return crud.get_client_user_consultations(db)

# 联系消息相关API
@router.post("/contact-message/")
def create_contact_message(message_data: dict, db: Session = Depends(get_test_session)):
    """创建联系消息（测试环境）"""
    return crud.create_contact_message(db, message_data)

@router.post("/contact-message/with-user")
def create_contact_message_with_user(message_data: dict, db: Session = Depends(get_test_session)):
    """创建带用户的联系消息（测试环境）"""
    return crud.create_contact_message_with_user(db, message_data)

@router.delete("/contact-message/{message_id}")
def delete_contact_message(message_id: int, db: Session = Depends(get_test_session)):
    """删除联系消息（测试环境）"""
    return crud.delete_contact_message(db, message_id)

# 询价相关API
@router.post("/inquiry/")
def create_inquiry(inquiry_data: dict, db: Session = Depends(get_test_session)):
    """创建询价（测试环境）"""
    return crud.create_inquiry(db, inquiry_data)

@router.post("/inquiry/with-user")
def create_inquiry_with_user(inquiry_data: dict, db: Session = Depends(get_test_session)):
    """创建带用户的询价（测试环境）"""
    return crud.create_inquiry_with_user(db, inquiry_data)

@router.delete("/inquiry/{inquiry_id}")
def delete_inquiry(inquiry_id: int, db: Session = Depends(get_test_session)):
    """删除询价（测试环境）"""
    return crud.delete_inquiry(db, inquiry_id)

# 联系字段相关API
@router.post("/contact-field/")
def create_contact_field(field_data: dict, db: Session = Depends(get_test_session)):
    """创建联系字段（测试环境）"""
    return crud.create_contact_field(db, field_data)

@router.get("/contact-field/{field_id}")
def get_contact_field(field_id: int, db: Session = Depends(get_test_session)):
    """获取联系字段（测试环境）"""
    return crud.get_contact_field(db, field_id)

@router.put("/contact-field/{field_id}")
def update_contact_field(field_id: int, field_data: dict, db: Session = Depends(get_test_session)):
    """更新联系字段（测试环境）"""
    return crud.update_contact_field(db, field_id, field_data)

@router.delete("/contact-field/{field_id}")
def delete_contact_field(field_id: int, db: Session = Depends(get_test_session)):
    """删除联系字段（测试环境）"""
    return crud.delete_contact_field(db, field_id)

# 轮播图相关API
@router.get("/carousel/{image_id}")
def get_carousel_image(image_id: int, db: Session = Depends(get_test_session)):
    """获取轮播图（测试环境）"""
    return crud.get_carousel_image(db, image_id)

# 产品相关API
@router.post("/product/{product_id}/copy")
def copy_product(product_id: int, db: Session = Depends(get_test_session)):
    """复制产品（测试环境）"""
    return crud.copy_product(db, product_id)

# 用户管理相关API
@router.post("/user/register")
def register_user(user_data: dict, db: Session = Depends(get_test_session)):
    """注册用户（测试环境）"""
    return crud.register_user(db, user_data)

@router.post("/user/wx-login")
def wx_login(wx_data: dict, db: Session = Depends(get_test_session)):
    """微信登录（测试环境）"""
    return crud.wx_login(db, wx_data)

@router.post("/user/app-login")
def app_login(app_data: dict, db: Session = Depends(get_test_session)):
    """APP登录（测试环境）"""
    return crud.app_login(db, app_data)

@router.post("/user/refresh-token")
def refresh_token(db: Session = Depends(get_test_session)):
    """刷新令牌（测试环境）"""
    return crud.refresh_token(db)

@router.get("/user/me")
def get_current_user_me(db: Session = Depends(get_test_session)):
    """获取当前用户（测试环境）"""
    return crud.get_current_user_me(db)

@router.post("/user/change-password")
def change_password(password_data: dict, db: Session = Depends(get_test_session)):
    """修改密码（测试环境）"""
    return crud.change_password(db, password_data)

@router.post("/user/admin/change-password")
def admin_change_password(password_data: dict, db: Session = Depends(get_test_session)):
    """管理员修改密码（测试环境）"""
    return crud.admin_change_password(db, password_data)

@router.put("/user/{user_id}")
def update_user(user_id: int, user_data: dict, db: Session = Depends(get_test_session)):
    """更新用户（测试环境）"""
    return crud.update_user(db, user_id, user_data)

@router.delete("/user/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_test_session)):
    """删除用户（测试环境）"""
    return crud.delete_user(db, user_id) 