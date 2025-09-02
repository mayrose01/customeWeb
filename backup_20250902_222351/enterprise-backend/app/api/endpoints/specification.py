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

# 产品规格管理
@router.post("/", response_model=schemas.ProductSpecificationOut)
def create_specification(data: schemas.ProductSpecificationCreate, db: Session = Depends(get_db)):
    spec = crud.create_product_specification(db, data)
    return schemas.ProductSpecificationOut.model_validate(spec, from_attributes=True)

@router.get("/product/{product_id}", response_model=List[schemas.ProductSpecificationOut])
def get_product_specifications(product_id: int, db: Session = Depends(get_db)):
    specs = crud.get_product_specifications(db, product_id)
    return [schemas.ProductSpecificationOut.model_validate(spec, from_attributes=True) for spec in specs]

@router.put("/{spec_id}", response_model=schemas.ProductSpecificationOut)
def update_specification(spec_id: int, data: schemas.ProductSpecificationUpdate, db: Session = Depends(get_db)):
    spec = crud.update_product_specification(db, spec_id, data)
    if not spec:
        raise HTTPException(status_code=404, detail="规格不存在")
    return schemas.ProductSpecificationOut.model_validate(spec, from_attributes=True)

@router.delete("/{spec_id}")
def delete_specification(spec_id: int, db: Session = Depends(get_db)):
    success = crud.delete_product_specification(db, spec_id)
    if not success:
        raise HTTPException(status_code=404, detail="规格不存在")
    return {"message": "规格删除成功"}

# 规格值管理
@router.post("/values/", response_model=schemas.ProductSpecificationValueOut)
def create_specification_value(data: schemas.ProductSpecificationValueCreate, db: Session = Depends(get_db)):
    value = crud.create_product_specification_value(db, data)
    return schemas.ProductSpecificationValueOut.model_validate(value, from_attributes=True)

@router.get("/values/{specification_id}", response_model=List[schemas.ProductSpecificationValueOut])
def get_specification_values(specification_id: int, db: Session = Depends(get_db)):
    values = crud.get_product_specification_values(db, specification_id)
    return [schemas.ProductSpecificationValueOut.model_validate(value, from_attributes=True) for value in values]

@router.put("/values/{value_id}", response_model=schemas.ProductSpecificationValueOut)
def update_specification_value(value_id: int, data: schemas.ProductSpecificationValueUpdate, db: Session = Depends(get_db)):
    value = crud.update_product_specification_value(db, value_id, data)
    if not value:
        raise HTTPException(status_code=404, detail="规格值不存在")
    return schemas.ProductSpecificationValueOut.model_validate(value, from_attributes=True)

@router.delete("/values/{value_id}")
def delete_specification_value(value_id: int, db: Session = Depends(get_db)):
    success = crud.delete_product_specification_value(db, value_id)
    if not success:
        raise HTTPException(status_code=404, detail="规格值不存在")
    return {"message": "规格值删除成功"} 