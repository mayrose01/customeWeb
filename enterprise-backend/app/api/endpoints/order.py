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

# 通用订单列表接口（兼容前端调用）
@router.get("/", response_model=schemas.OrderListWithUserResponse)
def list_orders(
    page: int = Query(1, ge=1, description="页码，从1开始"),
    page_size: int = Query(10, ge=1, le=100, description="每页数量"),
    order_no: Optional[str] = Query(None, description="按订单号搜索"),
    user_id: Optional[str] = Query(None, description="按用户ID筛选"),
    status: Optional[str] = Query(None, description="按订单状态筛选"),
    payment_status: Optional[str] = Query(None, description="按支付状态筛选"),
    db: Session = Depends(get_db)
):
    """获取订单列表（管理员用）"""
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
        
        # 构建查询
        query = db.query(models.Order).options(
            joinedload(models.Order.user),  # 预加载用户信息
            joinedload(models.Order.items).joinedload(models.OrderItem.product)  # 预加载订单项和产品信息
        )
        
        # 应用筛选条件
        if status:
            query = query.filter(models.Order.status == status)
        
        if payment_status:
            query = query.filter(models.Order.payment_status == payment_status)
        
        if user_id:
            query = query.filter(models.Order.user_id == user_id)
        
        # 获取总数
        total = query.count()
        
        # 应用分页和排序
        orders = query.order_by(models.Order.created_at.desc()).offset(skip).limit(page_size).all()
        
        # 如果有订单号筛选，在内存中处理（因为可能包含模糊搜索）
        if order_no:
            orders = [order for order in orders if order_no.lower() in order.order_no.lower()]
            total = len(orders)
        
        total_pages = (total + page_size - 1) // page_size
        
        print(f"查询订单: 总数={total}, 当前页={page}, 每页={page_size}, 筛选条件: status={status}, payment_status={payment_status}, user_id={user_id}")
        
        return schemas.OrderListWithUserResponse(
            items=[schemas.OrderWithUserOut.model_validate(order, from_attributes=True) for order in orders],
            total=total,
            page=page,
            page_size=page_size,
            total_pages=total_pages
        )
    except Exception as e:
        print(f"获取订单列表失败: {e}")
        # 如果出现错误，返回空列表而不是报错
        return schemas.OrderListWithUserResponse(
            items=[],
            total=0,
            page=page,
            page_size=page_size,
            total_pages=0
        )

# 订单管理
@router.post("/create", response_model=schemas.OrderOut)
def create_order(user_id: int, data: schemas.OrderCreate, db: Session = Depends(get_db)):
    order = crud.create_order(db, user_id, data)
    return schemas.OrderOut.model_validate(order, from_attributes=True)

@router.get("/user/{user_id}", response_model=schemas.OrderListResponse)
def get_user_orders(
    user_id: int,
    page: int = Query(1, ge=1, description="页码，从1开始"),
    page_size: int = Query(10, ge=1, le=100, description="每页数量"),
    db: Session = Depends(get_db)
):
    skip = (page - 1) * page_size
    orders, total = crud.get_user_orders(db, user_id, skip=skip, limit=page_size)
    total_pages = (total + page_size - 1) // page_size
    
    return schemas.OrderListResponse(
        items=[schemas.OrderOut.model_validate(order, from_attributes=True) for order in orders],
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )

@router.get("/{order_id}", response_model=schemas.OrderOut)
def get_order(order_id: int, db: Session = Depends(get_db)):
    order = crud.get_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="订单不存在")
    return schemas.OrderOut.model_validate(order, from_attributes=True)

@router.get("/no/{order_no}", response_model=schemas.OrderOut)
def get_order_by_no(order_no: str, db: Session = Depends(get_db)):
    order = crud.get_order_by_no(db, order_no)
    if not order:
        raise HTTPException(status_code=404, detail="订单不存在")
    return schemas.OrderOut.model_validate(order, from_attributes=True)

@router.put("/{order_id}", response_model=schemas.OrderOut)
def update_order(order_id: int, data: schemas.OrderUpdate, db: Session = Depends(get_db)):
    order = crud.update_order(db, order_id, data)
    if not order:
        raise HTTPException(status_code=404, detail="订单不存在")
    return schemas.OrderOut.model_validate(order, from_attributes=True)

# 管理员订单管理
@router.get("/admin/all", response_model=schemas.OrderListResponse)
def get_all_orders(
    page: int = Query(1, ge=1, description="页码，从1开始"),
    page_size: int = Query(10, ge=1, le=100, description="每页数量"),
    status: Optional[str] = Query(None, description="订单状态筛选"),
    db: Session = Depends(get_db)
):
    skip = (page - 1) * page_size
    orders, total = crud.get_all_orders(db, skip=skip, limit=page_size, status=status)
    total_pages = (total + page_size - 1) // page_size
    
    return schemas.OrderListResponse(
        items=[schemas.OrderOut.model_validate(order, from_attributes=True) for order in orders],
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )

# 支付相关
@router.post("/{order_id}/pay", response_model=schemas.PaymentResponse)
def create_payment(order_id: int, payment_method: str, db: Session = Depends(get_db)):
    order = crud.get_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="订单不存在")
    
    if order.payment_status == "paid":
        raise HTTPException(status_code=400, detail="订单已支付")
    
    # 这里应该集成真实的支付接口
    # 目前返回模拟的支付信息
    if payment_method == "wechat":
        return schemas.PaymentResponse(
            order_id=order_id,
            payment_url=f"weixin://wxpay/bizpayurl?pr={order.order_no}",
            qr_code="模拟的微信支付二维码"
        )
    elif payment_method == "alipay":
        return schemas.PaymentResponse(
            order_id=order_id,
            payment_url=f"alipayqr://platformapi/startapp?saId=10000007&qrcode={order.order_no}",
            qr_code=None
        )
    else:
        raise HTTPException(status_code=400, detail="不支持的支付方式")

@router.post("/{order_id}/payment-callback")
def payment_callback(order_id: int, payment_status: str, db: Session = Depends(get_db)):
    """支付回调接口"""
    order = crud.update_payment_status(db, order_id, payment_status)
    if not order:
        raise HTTPException(status_code=404, detail="订单不存在")
    
    return {"message": "支付状态更新成功", "order_id": order_id, "status": payment_status}

# 便于本地测试：支持GET方式触发支付回调
@router.get("/{order_id}/payment-callback")
def payment_callback_get(order_id: int, payment_status: str, db: Session = Depends(get_db)):
    order = crud.update_payment_status(db, order_id, payment_status)
    if not order:
        raise HTTPException(status_code=404, detail="订单不存在")
    return {"message": "支付状态更新成功", "order_id": order_id, "status": payment_status}

@router.get("/{order_id}/payment-status")
def get_payment_status(order_id: int, db: Session = Depends(get_db)):
    """获取订单支付状态"""
    order = crud.get_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="订单不存在")
    
    return {
        "order_id": order_id,
        "payment_status": order.payment_status,
        "status": order.status,
        "payment_time": order.payment_time
    } 