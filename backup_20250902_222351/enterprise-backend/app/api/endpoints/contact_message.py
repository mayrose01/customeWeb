from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from ... import crud, schemas
from ...database import get_db
from ...core.security import get_current_user_optional
from ...utils.email import email_sender
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.post("/", response_model=schemas.ContactMessageOut)
def create_contact_message(data: schemas.ContactMessageCreate, db: Session = Depends(get_db)):
    """创建联系我们提交（兼容旧版本）"""
    # 创建联系消息记录
    contact_message = crud.create_contact_message(db, data)
    
    # 获取公司邮箱
    company_info = crud.get_company_info(db)
    if company_info and company_info.email:
        try:
            # 发送邮件
            email_success = email_sender.send_contact_email(
                company_email=company_info.email,
                customer_name=data.name,
                customer_email=data.email,
                customer_phone=data.phone,
                subject=data.subject or "在线咨询",
                message=data.message,
                created_at=contact_message.created_at.strftime('%Y-%m-%d %H:%M:%S')
            )
            
            if email_success:
                logger.info(f"联系咨询邮件发送成功: 客户={data.name}, 主题={data.subject}")
            else:
                logger.warning(f"联系咨询邮件发送失败: 客户={data.name}, 主题={data.subject}")
                
        except Exception as e:
            logger.error(f"发送联系咨询邮件时出错: {e}")
    
    return contact_message

@router.post("/with-user", response_model=schemas.ContactMessageOut)
def create_contact_message_with_user(
    data: schemas.ContactMessageCreate, 
    current_user: Optional[schemas.UserOut] = Depends(get_current_user_optional),
    db: Session = Depends(get_db)
):
    """创建联系我们提交（支持用户关联）"""
    user_id = current_user.id if current_user else None
    
    # 创建联系消息记录
    contact_message = crud.create_contact_message_with_user(db, data, user_id)
    
    # 获取公司邮箱
    company_info = crud.get_company_info(db)
    if company_info and company_info.email:
        try:
            # 发送邮件
            email_success = email_sender.send_contact_email(
                company_email=company_info.email,
                customer_name=data.name,
                customer_email=data.email,
                customer_phone=data.phone,
                subject=data.subject or "在线咨询",
                message=data.message,
                created_at=contact_message.created_at.strftime('%Y-%m-%d %H:%M:%S')
            )
            
            if email_success:
                logger.info(f"联系咨询邮件发送成功: 客户={data.name}, 主题={data.subject}, 用户ID={user_id}")
            else:
                logger.warning(f"联系咨询邮件发送失败: 客户={data.name}, 主题={data.subject}, 用户ID={user_id}")
                
        except Exception as e:
            logger.error(f"发送联系咨询邮件时出错: {e}")
    
    return contact_message

@router.get("/", response_model=List[schemas.ContactMessageOut])
def get_contact_messages(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """获取联系我们提交列表"""
    return crud.get_contact_messages(db, skip=skip, limit=limit)

@router.get("/{message_id}", response_model=schemas.ContactMessageOut)
def get_contact_message(message_id: int, db: Session = Depends(get_db)):
    """获取单个联系我们提交"""
    contact_message = crud.get_contact_message(db, message_id)
    if not contact_message:
        raise HTTPException(status_code=404, detail="联系我们提交不存在")
    return contact_message

@router.delete("/{message_id}")
def delete_contact_message(message_id: int, db: Session = Depends(get_db)):
    """删除联系我们提交"""
    success = crud.delete_contact_message(db, message_id)
    if not success:
        raise HTTPException(status_code=404, detail="联系我们提交不存在")
    return {"message": "删除成功"} 