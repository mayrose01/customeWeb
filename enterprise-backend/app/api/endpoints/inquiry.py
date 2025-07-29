from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import schemas, crud
from app.database import SessionLocal
from app.utils.email import email_sender
from ...core.security import get_current_user_optional
from typing import List, Optional
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=schemas.InquiryOut)
def create_inquiry(data: schemas.InquiryCreate, db: Session = Depends(get_db)):
    """创建询价记录（兼容旧版本）"""
    # 创建询价记录
    inquiry = crud.create_inquiry(db, data)
    
    # 获取公司邮箱
    company_info = crud.get_company_info(db)
    if company_info and company_info.email:
        try:
            # 获取产品信息
            product = None
            if data.product_id:
                product = crud.get_product(db, data.product_id)
            
            # 获取产品主图
            product_image = None
            if product and product.images and len(product.images) > 0:
                product_image = f"http://localhost:8000{product.images[0]}"
            
            # 发送邮件
            email_success = email_sender.send_inquiry_email(
                company_email=company_info.email,
                product_id=data.product_id or 0,
                product_title=data.product_name or "未知产品",
                product_model=data.product_model,
                product_image=product_image,
                customer_name=data.name,
                customer_phone=data.phone,
                customer_email=data.email,
                inquiry_content=data.content,
                created_at=inquiry.created_at.strftime('%Y-%m-%d %H:%M:%S')
            )
            
            if email_success:
                logger.info(f"询价邮件发送成功: 客户={data.name}, 产品={data.product_name}")
            else:
                logger.warning(f"询价邮件发送失败: 客户={data.name}, 产品={data.product_name}")
                
        except Exception as e:
            logger.error(f"发送询价邮件时出错: {e}")
    
    return inquiry

@router.post("/with-user", response_model=schemas.InquiryOut)
def create_inquiry_with_user(
    data: schemas.InquiryCreateWithUser, 
    current_user: Optional[schemas.UserOut] = Depends(get_current_user_optional),
    db: Session = Depends(get_db)
):
    """创建询价记录（支持用户关联）"""
    user_id = current_user.id if current_user else None
    
    # 创建询价记录
    inquiry = crud.create_inquiry_with_user(db, data, user_id)
    
    # 获取公司邮箱
    company_info = crud.get_company_info(db)
    if company_info and company_info.email:
        try:
            # 获取产品信息
            product = None
            if data.product_id:
                product = crud.get_product(db, data.product_id)
            
            # 获取产品主图
            product_image = None
            if product and product.images and len(product.images) > 0:
                product_image = f"http://localhost:8000{product.images[0]}"
            elif data.product_image:
                product_image = f"http://localhost:8000{data.product_image}"
            
            # 发送邮件
            email_success = email_sender.send_inquiry_email(
                company_email=company_info.email,
                product_id=data.product_id or 0,
                product_title=data.product_name or "未知产品",
                product_model=data.product_model,
                product_image=product_image,
                customer_name=data.name,
                customer_phone=data.phone,
                customer_email=data.email,
                inquiry_content=data.content,
                created_at=inquiry.created_at.strftime('%Y-%m-%d %H:%M:%S')
            )
            
            if email_success:
                logger.info(f"询价邮件发送成功: 客户={data.name}, 产品={data.product_name}")
            else:
                logger.warning(f"询价邮件发送失败: 客户={data.name}, 产品={data.product_name}")
                
        except Exception as e:
            logger.error(f"发送询价邮件时出错: {e}")
    
    return inquiry

@router.get("/", response_model=List[schemas.InquiryOut])
def list_inquiries(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_inquiries(db, skip=skip, limit=limit)

@router.get("/{inquiry_id}", response_model=schemas.InquiryOut)
def get_inquiry(inquiry_id: int, db: Session = Depends(get_db)):
    inquiry = crud.get_inquiry(db, inquiry_id)
    if not inquiry:
        raise HTTPException(status_code=404, detail="Inquiry not found")
    return inquiry

@router.delete("/{inquiry_id}")
def delete_inquiry(inquiry_id: int, db: Session = Depends(get_db)):
    success = crud.delete_inquiry(db, inquiry_id)
    if not success:
        raise HTTPException(status_code=404, detail="Inquiry not found")
    return {"ok": True} 