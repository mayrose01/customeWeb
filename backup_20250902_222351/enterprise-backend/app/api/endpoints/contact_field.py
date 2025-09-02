from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ... import crud, schemas
from ...database import get_db

router = APIRouter()

@router.get("/", response_model=List[schemas.ContactFieldOut])
def get_contact_fields(db: Session = Depends(get_db)):
    """获取联系我们字段列表"""
    return crud.get_contact_fields(db)

@router.post("/", response_model=schemas.ContactFieldOut)
def create_contact_field(data: schemas.ContactFieldCreate, db: Session = Depends(get_db)):
    """创建联系我们字段"""
    return crud.create_contact_field(db, data)

@router.get("/{field_id}", response_model=schemas.ContactFieldOut)
def get_contact_field(field_id: int, db: Session = Depends(get_db)):
    """获取单个联系我们字段"""
    contact_field = crud.get_contact_field(db, field_id)
    if not contact_field:
        raise HTTPException(status_code=404, detail="联系我们字段不存在")
    return contact_field

@router.put("/{field_id}", response_model=schemas.ContactFieldOut)
def update_contact_field(field_id: int, data: schemas.ContactFieldUpdate, db: Session = Depends(get_db)):
    """更新联系我们字段"""
    contact_field = crud.update_contact_field(db, field_id, data)
    if not contact_field:
        raise HTTPException(status_code=404, detail="联系我们字段不存在")
    return contact_field

@router.delete("/{field_id}")
def delete_contact_field(field_id: int, db: Session = Depends(get_db)):
    """删除联系我们字段"""
    success = crud.delete_contact_field(db, field_id)
    if not success:
        raise HTTPException(status_code=404, detail="联系我们字段不存在")
    return {"message": "删除成功"} 