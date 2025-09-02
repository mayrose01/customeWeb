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

# SKU管理
@router.post("/", response_model=schemas.ProductSKUOut)
def create_sku(data: schemas.ProductSKUCreate, db: Session = Depends(get_db)):
    sku = crud.create_product_sku(db, data)
    return schemas.ProductSKUOut.model_validate(sku, from_attributes=True)

@router.get("/product/{product_id}", response_model=List[schemas.ProductSKUOut])
def get_product_skus(product_id: int, db: Session = Depends(get_db)):
    skus = crud.get_product_skus(db, product_id)
    return [schemas.ProductSKUOut.model_validate(sku, from_attributes=True) for sku in skus]

@router.put("/{sku_id}", response_model=schemas.ProductSKUOut)
def update_sku(sku_id: int, data: schemas.ProductSKUUpdate, db: Session = Depends(get_db)):
    sku = crud.update_product_sku(db, sku_id, data)
    if not sku:
        raise HTTPException(status_code=404, detail="SKU不存在")
    return schemas.ProductSKUOut.model_validate(sku, from_attributes=True)

@router.delete("/{sku_id}")
def delete_sku(sku_id: int, db: Session = Depends(get_db)):
    success = crud.delete_product_sku(db, sku_id)
    if not success:
        raise HTTPException(status_code=404, detail="SKU不存在")
    return {"message": "SKU删除成功"}

@router.get("/{sku_id}", response_model=schemas.ProductSKUOut)
def get_sku(sku_id: int, db: Session = Depends(get_db)):
    sku = crud.get_product_sku(db, sku_id)
    if not sku:
        raise HTTPException(status_code=404, detail="SKU不存在")
    return schemas.ProductSKUOut.model_validate(sku, from_attributes=True) 