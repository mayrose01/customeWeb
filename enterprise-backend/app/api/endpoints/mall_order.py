from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload
from app import schemas, crud
from app.database import SessionLocal
from typing import List, Optional
from app import models

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/", response_model=schemas.MallOrderListResponse)
def list_mall_orders(
    page: int = Query(1, ge=1, description="页码，从1开始"),
    page_size: int = Query(10, ge=1, le=100, description="每页数量"),
    order_no: Optional[str] = Query(None, description="按订单号搜索"),
    user_id: Optional[str] = Query(None, description="按用户ID筛选"),
    status: Optional[str] = Query(None, description="按订单状态筛选"),
    payment_status: Optional[str] = Query(None, description="按支付状态筛选"),
    db: Session = Depends(get_db)
):
    """获取商城订单列表（管理员用）"""
    try:
        skip = (page - 1) * page_size
        
        # 处理空字符串参数
        if user_id == "":
            user_id = None
        elif user_id:
            try:
                user_id = int(user_id)
            except ValueError:
                user_id = None
        
        if order_no == "":
            order_no = None
            
        if status == "":
            status = None
            
        if payment_status == "":
            payment_status = None
        
        # 构建查询 - 使用商城订单表
        query = db.query(models.MallOrder).options(
            joinedload(models.MallOrder.user),  # 预加载用户信息
            joinedload(models.MallOrder.items).joinedload(models.MallOrderItem.product)  # 预加载订单项和产品信息
        )
        
        # 应用筛选条件
        if status:
            query = query.filter(models.MallOrder.status == status)
        
        if payment_status:
            query = query.filter(models.MallOrder.payment_status == payment_status)
        
        if user_id:
            query = query.filter(models.MallOrder.user_id == user_id)
        
        # 获取总数
        total = query.count()
        
        # 应用分页和排序
        orders = query.order_by(models.MallOrder.created_at.desc()).offset(skip).limit(page_size).all()
        
        # 如果有订单号筛选，在内存中处理（因为可能包含模糊搜索）
        if order_no:
            orders = [order for order in orders if order_no.lower() in order.order_no.lower()]
            total = len(orders)
        
        total_pages = (total + page_size - 1) // page_size
        
        return schemas.MallOrderListResponse(
            items=[schemas.MallOrderOut.model_validate(order, from_attributes=True) for order in orders],
            total=total,
            page=page,
            page_size=page_size,
            total_pages=total_pages
        )
    except Exception as e:
        print(f"获取商城订单列表失败: {e}")
        # 如果出现错误，返回空列表而不是报错
        return schemas.MallOrderListResponse(
            items=[],
            total=0,
            page=page,
            page_size=page_size,
            total_pages=0
        )

@router.get("/{order_id}", response_model=schemas.MallOrderOut)
def get_mall_order(order_id: int, db: Session = Depends(get_db)):
    """获取商城订单详情"""
    order = crud.get_mall_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="商城订单不存在")
    return schemas.MallOrderOut.model_validate(order, from_attributes=True)

@router.get("/no/{order_no}", response_model=schemas.MallOrderOut)
def get_mall_order_by_no(order_no: str, db: Session = Depends(get_db)):
    """根据订单号获取商城订单"""
    order = crud.get_mall_order_by_no(db, order_no)
    if not order:
        raise HTTPException(status_code=404, detail="商城订单不存在")
    return schemas.MallOrderOut.model_validate(order, from_attributes=True)

@router.put("/{order_id}", response_model=schemas.MallOrderOut)
def update_mall_order(order_id: int, data: schemas.MallOrderUpdate, db: Session = Depends(get_db)):
    """更新商城订单"""
    order = crud.update_mall_order(db, order_id, data)
    if not order:
        raise HTTPException(status_code=404, detail="商城订单不存在")
    return schemas.MallOrderOut.model_validate(order, from_attributes=True)

@router.put("/{order_id}/status")
def update_mall_order_status(order_id: int, status: str, db: Session = Depends(get_db)):
    """更新商城订单状态"""
    try:
        order = crud.update_mall_order_status(db, order_id, status)
        if not order:
            raise HTTPException(status_code=404, detail="商城订单不存在")
        return {"ok": True, "message": "订单状态更新成功"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/{order_id}/shipping")
def update_mall_order_shipping(
    order_id: int, 
    tracking_number: str, 
    shipping_company: str,
    db: Session = Depends(get_db)
):
    """更新商城订单物流信息（发货）"""
    try:
        order = crud.update_mall_order_shipping(
            db, order_id, tracking_number, shipping_company
        )
        if not order:
            raise HTTPException(status_code=404, detail="商城订单不存在")
        return {"ok": True, "message": "物流信息更新成功"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/{order_id}/payment-status")
def update_mall_order_payment_status(
    order_id: int, 
    payment_status: str, 
    db: Session = Depends(get_db)
):
    """更新商城订单支付状态"""
    try:
        order = crud.update_mall_order_payment_status(db, order_id, payment_status)
        if not order:
            raise HTTPException(status_code=404, detail="商城订单不存在")
        return {"ok": True, "message": "支付状态更新成功"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{order_id}")
def delete_mall_order(order_id: int, db: Session = Depends(get_db)):
    """删除商城订单"""
    success = crud.delete_mall_order(db, order_id)
    if not success:
        raise HTTPException(status_code=404, detail="商城订单不存在")
    return {"ok": True, "message": "商城订单删除成功"}

# 商城订单统计
@router.get("/stats/overview")
def get_mall_order_stats(db: Session = Depends(get_db)):
    """获取商城订单统计概览"""
    try:
        stats = crud.get_mall_order_stats(db)
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取订单统计失败: {str(e)}")

@router.get("/stats/daily")
def get_mall_order_daily_stats(
    start_date: str = Query(..., description="开始日期 (YYYY-MM-DD)"),
    end_date: str = Query(..., description="结束日期 (YYYY-MM-DD)"),
    db: Session = Depends(get_db)
):
    """获取商城订单每日统计"""
    try:
        stats = crud.get_mall_order_daily_stats(db, start_date, end_date)
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取每日统计失败: {str(e)}")
