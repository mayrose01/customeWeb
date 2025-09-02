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

@router.get("/", response_model=List[schemas.ProductOut])
def get_all_products_for_client(
    category_id: Optional[int] = Query(None, description="按产品分类筛选"),
    search: Optional[str] = Query(None, description="搜索关键词"),
    db: Session = Depends(get_db)
):
    """
    获取所有产品（客户端专用API）
    返回所有产品，不分页，用于客户端产品列表页面
    """
    try:
        # 获取所有产品，包含分类信息
        products = crud.get_all_products_for_client(db, category_id=category_id, search=search)
        
        # 转换为响应模型
        result = []
        for product in products:
            product_out = schemas.ProductOut.model_validate(product, from_attributes=True)
            result.append(product_out)
        
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"获取产品列表失败: {str(e)}")

@router.get("/{product_id}", response_model=schemas.ProductOut)
def get_product_for_client(product_id: int, db: Session = Depends(get_db)):
    """
    获取单个产品详情（客户端专用API）
    """
    product = crud.get_product(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return schemas.ProductOut.model_validate(product, from_attributes=True) 