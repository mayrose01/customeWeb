from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional
from ... import crud, schemas
from ...database import get_db
from ...core.security import create_access_token, get_current_user
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.post("/register", response_model=schemas.ClientUserOut)
def register_client_user(user: schemas.ClientUserRegister, db: Session = Depends(get_db)):
    """客户端用户注册"""
    try:
        db_user = crud.create_client_user(db, user)
        return db_user
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"用户注册失败: {str(e)}")
        raise HTTPException(status_code=500, detail="注册失败，请稍后重试")

@router.post("/login")
def login_client_user(user_credentials: schemas.ClientUserLogin, db: Session = Depends(get_db)):
    """客户端用户登录"""
    user = crud.authenticate_client_user(db, user_credentials.username, user_credentials.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="用户名或密码错误",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # 创建访问令牌，有效期24小时
    access_token_expires = timedelta(minutes=1440)  # 24小时
    access_token = create_access_token(
        data={"sub": str(user.id), "role": user.role}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "phone": user.phone,
            "avatar_url": user.avatar_url
        }
    }

@router.get("/profile", response_model=schemas.ClientUserOut)
def get_client_user_profile(current_user: schemas.UserOut = Depends(get_current_user), db: Session = Depends(get_db)):
    """获取客户端用户信息"""
    if current_user.role != "customer":
        raise HTTPException(status_code=403, detail="权限不足")
    
    user = crud.get_user_by_id(db, current_user.id)
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    
    return user

@router.put("/profile", response_model=schemas.ClientUserOut)
def update_client_user_profile(
    user_update: schemas.ClientUserProfileUpdate,
    current_user: schemas.UserOut = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """更新客户端用户信息"""
    if current_user.role != "customer":
        raise HTTPException(status_code=403, detail="权限不足")
    
    try:
        user = crud.update_client_user_profile(db, current_user.id, user_update)
        if not user:
            raise HTTPException(status_code=404, detail="用户不存在")
        return user
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/inquiries", response_model=schemas.UserInquiryList)
def get_user_inquiries(
    page: int = 1,
    page_size: int = 10,
    current_user: schemas.UserOut = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """获取用户的询价列表"""
    if current_user.role != "customer":
        raise HTTPException(status_code=403, detail="权限不足")
    
    skip = (page - 1) * page_size
    inquiries, total = crud.get_user_inquiries(db, current_user.id, skip, page_size)
    
    total_pages = (total + page_size - 1) // page_size
    
    return {
        "items": inquiries,
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": total_pages
    }

@router.get("/consultations", response_model=schemas.UserConsultationList)
def get_user_consultations(
    page: int = 1,
    page_size: int = 10,
    current_user: schemas.UserOut = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """获取用户的咨询列表"""
    if current_user.role != "customer":
        raise HTTPException(status_code=403, detail="权限不足")
    
    skip = (page - 1) * page_size
    consultations, total = crud.get_user_consultations(db, current_user.id, skip, page_size)
    
    total_pages = (total + page_size - 1) // page_size
    
    return {
        "items": consultations,
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": total_pages
    } 