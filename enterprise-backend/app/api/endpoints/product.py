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

@router.get("/", response_model=schemas.ProductListResponse)
def list_products(
    page: int = Query(1, ge=1, description="页码，从1开始"),
    page_size: int = Query(10, ge=1, le=100, description="每页数量"),
    title: Optional[str] = Query(None, description="按产品标题搜索"),
    product_id: Optional[int] = Query(None, description="按产品ID搜索"),
    model: Optional[str] = Query(None, description="按产品型号搜索"),
    category_id: Optional[int] = Query(None, description="按产品分类筛选"),
    db: Session = Depends(get_db)
):
    skip = (page - 1) * page_size
    products, total = crud.get_products_with_count(db, skip=skip, limit=page_size, title=title, product_id=product_id, model=model, category_id=category_id)
    
    total_pages = (total + page_size - 1) // page_size
    
    return schemas.ProductListResponse(
        items=[schemas.ProductOut.model_validate(p, from_attributes=True) for p in products],
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )

@router.post("/", response_model=schemas.ProductOut)
def create_product(data: schemas.ProductCreate, db: Session = Depends(get_db)):
    try:
        product = crud.create_product(db, data)
        return schemas.ProductOut.model_validate(product, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{product_id}", response_model=schemas.ProductOut)
def get_product(product_id: int, db: Session = Depends(get_db)):
    product = crud.get_product(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return schemas.ProductOut.model_validate(product, from_attributes=True)

@router.put("/{product_id}", response_model=schemas.ProductOut)
def update_product(product_id: int, data: schemas.ProductUpdate, db: Session = Depends(get_db)):
    try:
        product = crud.update_product(db, product_id, data)
        if not product:
            raise HTTPException(status_code=404, detail="Product not found")
        return schemas.ProductOut.model_validate(product, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{product_id}")
def delete_product(product_id: int, db: Session = Depends(get_db)):
    success = crud.delete_product(db, product_id)
    if not success:
        raise HTTPException(status_code=404, detail="Product not found")
    return {"ok": True}

@router.post("/{product_id}/copy", response_model=schemas.ProductOut)
def copy_product(product_id: int, db: Session = Depends(get_db)):
    try:
        product = crud.copy_product(db, product_id)
        return schemas.ProductOut.model_validate(product, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) 