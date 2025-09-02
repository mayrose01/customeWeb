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

# 商城产品规格管理
@router.post("/", response_model=schemas.MallProductSpecificationOut)
def create_mall_specification(data: schemas.MallProductSpecificationCreate, db: Session = Depends(get_db)):
    """创建商城产品规格"""
    spec = crud.create_mall_product_specification(db, data)
    return schemas.MallProductSpecificationOut.model_validate(spec, from_attributes=True)

@router.get("/product/{product_id}", response_model=List[schemas.MallProductSpecificationOut])
def get_mall_product_specifications(product_id: int, db: Session = Depends(get_db)):
    """获取商城产品的规格列表"""
    specs = crud.get_mall_product_specifications(db, product_id)
    return [schemas.MallProductSpecificationOut.model_validate(spec, from_attributes=True) for spec in specs]

@router.put("/{spec_id}", response_model=schemas.MallProductSpecificationOut)
def update_mall_specification(spec_id: int, data: schemas.MallProductSpecificationUpdate, db: Session = Depends(get_db)):
    """更新商城产品规格"""
    spec = crud.update_mall_product_specification(db, spec_id, data)
    if not spec:
        raise HTTPException(status_code=404, detail="商城规格不存在")
    return schemas.MallProductSpecificationOut.model_validate(spec, from_attributes=True)

@router.delete("/{spec_id}")
def delete_mall_specification(spec_id: int, db: Session = Depends(get_db)):
    """删除商城产品规格"""
    success = crud.delete_mall_product_specification(db, spec_id)
    if not success:
        raise HTTPException(status_code=404, detail="商城规格不存在")
    return {"message": "商城规格删除成功"}

# 商城规格值管理
@router.post("/values/", response_model=schemas.MallProductSpecificationValueOut)
def create_mall_specification_value(data: schemas.MallProductSpecificationValueCreate, db: Session = Depends(get_db)):
    """创建商城规格值"""
    value = crud.create_mall_product_specification_value(db, data)
    return schemas.MallProductSpecificationValueOut.model_validate(value, from_attributes=True)

@router.get("/values/{specification_id}", response_model=List[schemas.MallProductSpecificationValueOut])
def get_mall_specification_values(specification_id: int, db: Session = Depends(get_db)):
    """获取商城规格值列表"""
    values = crud.get_mall_product_specification_values(db, specification_id)
    return [schemas.MallProductSpecificationValueOut.model_validate(value, from_attributes=True) for value in values]

@router.put("/values/{value_id}", response_model=schemas.MallProductSpecificationValueOut)
def update_mall_specification_value(value_id: int, data: schemas.MallProductSpecificationValueUpdate, db: Session = Depends(get_db)):
    """更新商城规格值"""
    value = crud.update_mall_product_specification_value(db, value_id, data)
    if not value:
        raise HTTPException(status_code=404, detail="商城规格值不存在")
    return schemas.MallProductSpecificationValueOut.model_validate(value, from_attributes=True)

@router.delete("/values/{value_id}")
def delete_mall_specification_value(value_id: int, db: Session = Depends(get_db)):
    """删除商城规格值"""
    success = crud.delete_mall_product_specification_value(db, value_id)
    if not success:
        raise HTTPException(status_code=404, detail="商城规格值不存在")
    return {"message": "商城规格值删除成功"}

# 商城SKU管理（基于规格组合）
@router.get("/sku/product/{product_id}", response_model=List[schemas.MallProductSKUOut])
def get_mall_product_skus(product_id: int, db: Session = Depends(get_db)):
    """获取商城产品的SKU列表"""
    skus = crud.get_mall_product_skus(db, product_id)
    return [schemas.MallProductSKUOut.model_validate(sku, from_attributes=True) for sku in skus]

@router.post("/sku/", response_model=schemas.MallProductSKUOut)
def create_mall_sku(data: schemas.MallProductSKUCreate, db: Session = Depends(get_db)):
    """创建商城产品SKU"""
    sku = crud.create_mall_product_sku(db, data)
    return schemas.MallProductSKUOut.model_validate(sku, from_attributes=True)

@router.put("/sku/{sku_id}", response_model=schemas.MallProductSKUOut)
def update_mall_sku(sku_id: int, data: schemas.MallProductSKUUpdate, db: Session = Depends(get_db)):
    """更新商城产品SKU"""
    sku = crud.update_mall_product_sku(db, sku_id, data)
    if not sku:
        raise HTTPException(status_code=404, detail="商城SKU不存在")
    return schemas.MallProductSKUOut.model_validate(sku, from_attributes=True)

@router.delete("/sku/{sku_id}")
def delete_mall_sku(sku_id: int, db: Session = Depends(get_db)):
    """删除商城产品SKU"""
    success = crud.delete_mall_product_sku(db, sku_id)
    if not success:
        raise HTTPException(status_code=404, detail="商城SKU不存在")
    return {"message": "商城SKU删除成功"}
