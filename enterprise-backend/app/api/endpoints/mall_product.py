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

@router.get("/", response_model=schemas.MallProductListResponse)
def list_mall_products(
    page: int = Query(1, ge=1, description="页码，从1开始"),
    page_size: int = Query(10, ge=1, le=100, description="每页数量"),
    title: Optional[str] = Query(None, description="按产品标题搜索"),
    category_id: Optional[int] = Query(None, description="按产品分类筛选"),
    status: Optional[str] = Query(None, description="按产品状态筛选"),
    db: Session = Depends(get_db)
):
    """获取商城产品列表"""
    skip = (page - 1) * page_size
    products, total = crud.get_mall_products_with_count(
        db, skip=skip, limit=page_size, 
        title=title, category_id=category_id, status=status
    )
    
    total_pages = (total + page_size - 1) // page_size
    
    return schemas.MallProductListResponse(
        items=[schemas.MallProductOut.model_validate(p, from_attributes=True) for p in products],
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )

@router.post("/", response_model=schemas.MallProductOut)
def create_mall_product(data: schemas.MallProductCreate, db: Session = Depends(get_db)):
    """创建商城产品"""
    try:
        product = crud.create_mall_product(db, data)
        return schemas.MallProductOut.model_validate(product, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{product_id}", response_model=schemas.MallProductOut)
def get_mall_product(product_id: int, db: Session = Depends(get_db)):
    """获取商城产品详情"""
    product = crud.get_mall_product(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="商城产品不存在")
    return schemas.MallProductOut.model_validate(product, from_attributes=True)

@router.put("/{product_id}", response_model=schemas.MallProductOut)
def update_mall_product(product_id: int, data: schemas.MallProductUpdate, db: Session = Depends(get_db)):
    """更新商城产品"""
    try:
        product = crud.update_mall_product(db, product_id, data)
        if not product:
            raise HTTPException(status_code=404, detail="商城产品不存在")
        return schemas.MallProductOut.model_validate(product, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{product_id}")
def delete_mall_product(product_id: int, db: Session = Depends(get_db)):
    """删除商城产品"""
    success = crud.delete_mall_product(db, product_id)
    if not success:
        raise HTTPException(status_code=404, detail="商城产品不存在")
    return {"ok": True, "message": "商城产品删除成功"}

@router.post("/{product_id}/copy", response_model=schemas.MallProductOut)
def copy_mall_product(product_id: int, db: Session = Depends(get_db)):
    """复制商城产品"""
    try:
        product = crud.copy_mall_product(db, product_id)
        return schemas.MallProductOut.model_validate(product, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/{product_id}/status")
def update_mall_product_status(product_id: int, data: schemas.MallProductStatusUpdate, db: Session = Depends(get_db)):
    """更新商城产品状态（上架/下架）"""
    try:
        product = crud.update_mall_product_status(db, product_id, data.status)
        if not product:
            raise HTTPException(status_code=404, detail="商城产品不存在")
        return {"ok": True, "message": "产品状态更新成功"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{product_id}/best-sku", response_model=schemas.MallProductSKUOut)
def get_best_sku_for_product(product_id: int, db: Session = Depends(get_db)):
    """获取产品中价格最高且有库存的SKU（用于快速加购）"""
    sku = crud.get_highest_priced_sku_with_stock(db, product_id)
    if not sku:
        raise HTTPException(status_code=404, detail="产品暂无可用库存")
    return schemas.MallProductSKUOut.model_validate(sku, from_attributes=True)
