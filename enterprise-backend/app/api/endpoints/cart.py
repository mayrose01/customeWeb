from fastapi import APIRouter, Depends, HTTPException, Query, Body
from sqlalchemy.orm import Session
from app import schemas, crud
from app.database import SessionLocal
from typing import List, Optional

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 购物车管理
@router.get("/", response_model=schemas.CartOut)
def get_cart(user_id: int = Query(...), db: Session = Depends(get_db)):
    cart = crud.get_cart(db, user_id)
    if not cart:
        raise HTTPException(status_code=404, detail="购物车不存在")
    return schemas.CartOut.model_validate(cart, from_attributes=True)

@router.post("/add", response_model=schemas.CartItemOut)
def add_to_cart(
    user_id: int = Body(...),
    sku_id: int = Body(...),
    quantity: int = Body(1),
    db: Session = Depends(get_db)
):
    cart_item = crud.add_to_cart(db, user_id, sku_id, quantity)
    return schemas.CartItemOut.model_validate(cart_item, from_attributes=True)

@router.put("/update/{item_id}", response_model=schemas.CartItemOut)
def update_cart_item(
    item_id: int,
    user_id: int = Body(...),
    quantity: int = Body(...),
    db: Session = Depends(get_db)
):
    cart_item = crud.update_cart_item(db, user_id, item_id, quantity)
    if not cart_item:
        raise HTTPException(status_code=404, detail="购物车商品不存在")
    return schemas.CartItemOut.model_validate(cart_item, from_attributes=True)

@router.delete("/remove/{item_id}")
def remove_from_cart(
    item_id: int,
    user_id: int = Query(...),
    db: Session = Depends(get_db)
):
    success = crud.remove_from_cart(db, user_id, item_id)
    if not success:
        raise HTTPException(status_code=404, detail="购物车商品不存在")
    return {"message": "商品已从购物车移除"}

@router.delete("/clear")
def clear_cart(
    user_id: int = Query(...),
    db: Session = Depends(get_db)
):
    success = crud.clear_cart(db, user_id)
    if not success:
        raise HTTPException(status_code=404, detail="购物车不存在")
    return {"message": "购物车已清空"}

@router.get("/count")
def get_cart_count(user_id: int = Query(...), db: Session = Depends(get_db)):
    """获取购物车商品数量"""
    count = crud.get_cart_item_count(db, user_id)
    return {"count": count} 