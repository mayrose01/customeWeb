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
@router.get("/user/{user_id}", response_model=List[schemas.UserAddressOut])
def get_user_addresses(user_id: int, db: Session = Depends(get_db)):
    try:
        addresses = crud.get_user_addresses(db, user_id)
        return [schemas.UserAddressOut.model_validate(address, from_attributes=True) for address in addresses] if addresses is not None else []
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"查询地址失败: {str(e)}")

# 获取单个地址详情
@router.get("/{address_id}", response_model=schemas.UserAddressOut)
def get_address(address_id: int, db: Session = Depends(get_db)):
    address = crud.get_user_address(db, address_id)
    if not address:
        raise HTTPException(status_code=404, detail="地址不存在")
    return schemas.UserAddressOut.model_validate(address, from_attributes=True)

# 新增收货地址
@router.post("/", response_model=schemas.UserAddressOut)
def create_address(data: schemas.UserAddressCreate, db: Session = Depends(get_db)):
    address = crud.create_user_address(db, data)
    return schemas.UserAddressOut.model_validate(address, from_attributes=True)

# 更新收货地址
@router.put("/{address_id}", response_model=schemas.UserAddressOut)
def update_address(address_id: int, data: schemas.UserAddressUpdate, db: Session = Depends(get_db)):
    address = crud.update_user_address(db, address_id, data)
    if not address:
        raise HTTPException(status_code=404, detail="地址不存在")
    return schemas.UserAddressOut.model_validate(address, from_attributes=True)

# 删除收货地址
@router.delete("/{address_id}")
def delete_address(address_id: int, db: Session = Depends(get_db)):
    success = crud.delete_user_address(db, address_id)
    if not success:
        raise HTTPException(status_code=404, detail="地址不存在")
    return {"message": "地址删除成功"}

# 设置默认地址
@router.put("/{address_id}/default", response_model=schemas.UserAddressOut)
def set_default_address(address_id: int, db: Session = Depends(get_db)):
    address = crud.set_default_user_address(db, address_id)
    if not address:
        raise HTTPException(status_code=404, detail="地址不存在")
    return schemas.UserAddressOut.model_validate(address, from_attributes=True)