from fastapi import APIRouter, Depends, HTTPException, Query
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

# 创建订单
@router.post("/", response_model=schemas.MallOrderOut)
def create_order(
    user_id: int,
    data: schemas.MallOrderCreate,
    db: Session = Depends(get_db)
):
    """创建订单"""
    try:
        order = crud.create_mall_order(db, user_id, data)
        return schemas.MallOrderOut.model_validate(order, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# 获取用户订单列表
@router.get("/", response_model=schemas.MallOrderListResponse)
def get_user_orders(
    user_id: int,
    page: int = Query(1, ge=1, description="页码，从1开始"),
    page_size: int = Query(10, ge=1, le=100, description="每页数量"),
    status: Optional[str] = Query(None, description="按订单状态筛选"),
    db: Session = Depends(get_db)
):
    """获取用户订单列表"""
    skip = (page - 1) * page_size
    orders, total = crud.get_user_orders_with_count(
        db, user_id=user_id, skip=skip, limit=page_size, status=status
    )
    
    total_pages = (total + page_size - 1) // page_size
    
    return schemas.MallOrderListResponse(
        items=[schemas.MallOrderOut.model_validate(o, from_attributes=True) for o in orders],
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )

# 获取订单详情
@router.get("/{order_id}", response_model=schemas.MallOrderOut)
def get_order(order_id: int, user_id: int, db: Session = Depends(get_db)):
    """获取订单详情"""
    order = crud.get_user_order(db, order_id, user_id)
    if not order:
        raise HTTPException(status_code=404, detail="订单不存在")
    return schemas.MallOrderOut.model_validate(order, from_attributes=True)

# 取消订单
@router.put("/{order_id}/cancel")
def cancel_order(order_id: int, user_id: int, db: Session = Depends(get_db)):
    """取消订单"""
    try:
        success = crud.cancel_mall_order(db, order_id, user_id)
        if not success:
            raise HTTPException(status_code=404, detail="订单不存在或无法取消")
        return {"ok": True, "message": "订单已取消"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# 确认收货
@router.put("/{order_id}/confirm")
def confirm_order(order_id: int, user_id: int, db: Session = Depends(get_db)):
    """确认收货"""
    try:
        success = crud.confirm_mall_order(db, order_id, user_id)
        if not success:
            raise HTTPException(status_code=404, detail="订单不存在或无法确认收货")
        return {"ok": True, "message": "订单已确认收货"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# 管理员获取所有订单列表
@router.get("/admin/all", response_model=schemas.MallOrderListResponse)
def get_all_orders(
    page: int = Query(1, ge=1, description="页码，从1开始"),
    page_size: int = Query(10, ge=1, le=100, description="每页数量"),
    status: Optional[str] = Query(None, description="按订单状态筛选"),
    payment_status: Optional[str] = Query(None, description="按支付状态筛选"),
    db: Session = Depends(get_db)
):
    """管理员获取所有订单列表"""
    skip = (page - 1) * page_size
    orders, total = crud.get_all_orders_with_count(
        db, skip=skip, limit=page_size, status=status, payment_status=payment_status
    )
    
    total_pages = (total + page_size - 1) // page_size
    
    return schemas.MallOrderListResponse(
        items=[schemas.MallOrderOut.model_validate(o, from_attributes=True) for o in orders],
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )

# 管理员获取订单详情
@router.get("/admin/{order_id}", response_model=schemas.MallOrderOut)
def get_order_detail_admin(order_id: int, db: Session = Depends(get_db)):
    """管理员获取订单详情"""
    order = crud.get_mall_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="订单不存在")
    return schemas.MallOrderOut.model_validate(order, from_attributes=True)

# 管理员更新订单状态
@router.put("/admin/{order_id}/status")
def update_order_status(
    order_id: int,
    data: schemas.MallOrderUpdate,
    db: Session = Depends(get_db)
):
    """管理员更新订单状态"""
    try:
        order = crud.update_mall_order(db, order_id, data)
        if not order:
            raise HTTPException(status_code=404, detail="订单不存在")
        return {"ok": True, "message": "订单状态更新成功"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# 管理员更新订单支付状态
@router.put("/admin/{order_id}/payment-status")
def update_payment_status(
    order_id: int,
    payment_status: str,
    db: Session = Depends(get_db)
):
    """管理员更新订单支付状态"""
    try:
        success = crud.update_mall_order_payment_status(db, order_id, payment_status)
        if not success:
            raise HTTPException(status_code=404, detail="订单不存在")
        return {"ok": True, "message": "支付状态更新成功"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# 管理员更新物流信息
@router.put("/admin/{order_id}/shipping")
def update_shipping_info(
    order_id: int,
    shipping_company: str,
    tracking_number: str,
    db: Session = Depends(get_db)
):
    """管理员更新物流信息"""
    try:
        success = crud.update_mall_order_shipping(db, order_id, shipping_company, tracking_number)
        if not success:
            raise HTTPException(status_code=404, detail="订单不存在")
        return {"ok": True, "message": "物流信息更新成功"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))