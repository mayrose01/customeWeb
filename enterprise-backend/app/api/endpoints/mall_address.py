from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import schemas, crud
from app.database import SessionLocal
from typing import List

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 获取用户收货地址列表
@router.get("/", response_model=List[schemas.MallAddressOut])
def get_user_addresses(user_id: int, db: Session = Depends(get_db)):
    """获取用户收货地址列表"""
    addresses = crud.get_user_addresses(db, user_id)
    return [schemas.MallAddressOut.model_validate(addr, from_attributes=True) for addr in addresses]

# 创建收货地址
@router.post("/", response_model=schemas.MallAddressOut)
def create_address(
    user_id: int,
    data: schemas.MallAddressCreate,
    db: Session = Depends(get_db)
):
    """创建收货地址"""
    try:
        address = crud.create_mall_address(db, user_id, data)
        return schemas.MallAddressOut.model_validate(address, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# 更新收货地址
@router.put("/{address_id}", response_model=schemas.MallAddressOut)
def update_address(
    address_id: int,
    user_id: int,
    data: schemas.MallAddressUpdate,
    db: Session = Depends(get_db)
):
    """更新收货地址"""
    try:
        address = crud.update_mall_address(db, address_id, user_id, data)
        if not address:
            raise HTTPException(status_code=404, detail="收货地址不存在")
        return schemas.MallAddressOut.model_validate(address, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# 删除收货地址
@router.delete("/{address_id}")
def delete_address(address_id: int, user_id: int, db: Session = Depends(get_db)):
    """删除收货地址"""
    success = crud.delete_mall_address(db, address_id, user_id)
    if not success:
        raise HTTPException(status_code=404, detail="收货地址不存在")
    return {"ok": True, "message": "收货地址删除成功"}

# 设置默认收货地址
@router.put("/{address_id}/set-default")
def set_default_address(address_id: int, user_id: int, db: Session = Depends(get_db)):
    """设置默认收货地址"""
    try:
        success = crud.set_default_mall_address(db, address_id, user_id)
        if not success:
            raise HTTPException(status_code=404, detail="收货地址不存在")
        return {"ok": True, "message": "默认地址设置成功"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
