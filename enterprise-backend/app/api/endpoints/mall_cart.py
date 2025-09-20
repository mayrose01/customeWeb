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

# 获取当前用户的购物车
@router.get("/", response_model=schemas.MallCartOut)
def get_cart(user_id: int, db: Session = Depends(get_db)):
    """获取用户的购物车"""
    cart = crud.get_user_cart(db, user_id)
    if not cart:
        # 如果用户没有购物车，创建一个
        cart = crud.create_user_cart(db, user_id)
    return schemas.MallCartOut.model_validate(cart, from_attributes=True)

# 添加商品到购物车
@router.post("/items", response_model=schemas.MallCartItemOut)
def add_to_cart(
    user_id: int,
    data: schemas.MallCartItemCreate,
    db: Session = Depends(get_db)
):
    """添加商品到购物车"""
    try:
        # 确保用户有购物车
        cart = crud.get_user_cart(db, user_id)
        if not cart:
            cart = crud.create_user_cart(db, user_id)
        
        # 设置购物车ID
        data.cart_id = cart.id
        
        # 添加商品到购物车
        cart_item = crud.add_to_cart(db, data)
        return schemas.MallCartItemOut.model_validate(cart_item, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# 更新购物车商品数量
@router.put("/items/{item_id}", response_model=schemas.MallCartItemOut)
def update_cart_item(
    item_id: int,
    data: schemas.MallCartItemUpdate,
    db: Session = Depends(get_db)
):
    """更新购物车商品数量"""
    try:
        cart_item = crud.update_cart_item(db, item_id, data)
        if not cart_item:
            raise HTTPException(status_code=404, detail="购物车商品不存在")
        return schemas.MallCartItemOut.model_validate(cart_item, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# 从购物车删除商品
@router.delete("/items/{item_id}")
def remove_from_cart(item_id: int, db: Session = Depends(get_db)):
    """从购物车删除商品"""
    success = crud.remove_from_cart(db, item_id)
    if not success:
        raise HTTPException(status_code=404, detail="购物车商品不存在")
    return {"ok": True, "message": "商品已从购物车删除"}

# 清空购物车
@router.delete("/")
def clear_cart(user_id: int, db: Session = Depends(get_db)):
    """清空用户购物车"""
    success = crud.clear_user_cart(db, user_id)
    return {"ok": True, "message": "购物车已清空"}
