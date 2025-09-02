from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ... import crud, schemas
from ...database import get_db

router = APIRouter()

@router.get("/", response_model=List[schemas.ServiceOut])
def get_services(active_only: bool = False, db: Session = Depends(get_db)):
    """获取主营业务列表"""
    return crud.get_services(db, active_only=active_only)

@router.get("/client", response_model=List[schemas.ServiceOut])
def get_services_for_client(db: Session = Depends(get_db)):
    """获取客户端主营业务列表（只返回启用的）"""
    return crud.get_services(db, active_only=True)

@router.post("/", response_model=schemas.ServiceOut)
def create_service(data: schemas.ServiceCreate, db: Session = Depends(get_db)):
    """创建主营业务"""
    return crud.create_service(db, data)

@router.get("/{service_id}", response_model=schemas.ServiceOut)
def get_service(service_id: int, db: Session = Depends(get_db)):
    """获取单个主营业务"""
    service = crud.get_service(db, service_id)
    if not service:
        raise HTTPException(status_code=404, detail="主营业务不存在")
    return service

@router.put("/{service_id}", response_model=schemas.ServiceOut)
def update_service(service_id: int, data: schemas.ServiceUpdate, db: Session = Depends(get_db)):
    """更新主营业务"""
    service = crud.update_service(db, service_id, data)
    if not service:
        raise HTTPException(status_code=404, detail="主营业务不存在")
    return service

@router.delete("/{service_id}")
def delete_service(service_id: int, db: Session = Depends(get_db)):
    """删除主营业务"""
    success = crud.delete_service(db, service_id)
    if not success:
        raise HTTPException(status_code=404, detail="主营业务不存在")
    return {"message": "删除成功"} 