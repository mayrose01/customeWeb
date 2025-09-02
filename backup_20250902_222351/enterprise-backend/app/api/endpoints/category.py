from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import schemas, crud
from app.database import SessionLocal
from typing import List

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/", response_model=List[schemas.CategoryOut])
def list_categories(db: Session = Depends(get_db)):
    categories = crud.get_categories(db)
    return [schemas.CategoryOut.model_validate(c, from_attributes=True) for c in categories]

@router.get("/tree", response_model=List[schemas.CategoryOut])
def get_categories_tree(db: Session = Depends(get_db)):
    cats = crud.get_categories_tree(db)
    return [schemas.CategoryOut.model_validate(c, from_attributes=True) for c in cats]

@router.get("/{parent_id}/subcategories", response_model=List[schemas.CategoryOut])
def get_subcategories(parent_id: int, db: Session = Depends(get_db)):
    subs = crud.get_subcategories(db, parent_id)
    return [schemas.CategoryOut.model_validate(c, from_attributes=True) for c in subs]

@router.post("/", response_model=schemas.CategoryOut)
def create_category(data: schemas.CategoryCreate, db: Session = Depends(get_db)):
    cat = crud.create_category(db, data)
    return schemas.CategoryOut.model_validate(cat, from_attributes=True)

@router.get("/{category_id}", response_model=schemas.CategoryOut)
def get_category(category_id: int, db: Session = Depends(get_db)):
    category = crud.get_category(db, category_id)
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return schemas.CategoryOut.model_validate(category, from_attributes=True)

@router.put("/{category_id}", response_model=schemas.CategoryOut)
def update_category(category_id: int, data: schemas.CategoryCreate, db: Session = Depends(get_db)):
    try:
        category = crud.update_category(db, category_id, data)
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")
        return schemas.CategoryOut.model_validate(category, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{category_id}")
def delete_category(category_id: int, db: Session = Depends(get_db)):
    try:
        success = crud.delete_category(db, category_id)
        if not success:
            raise HTTPException(status_code=404, detail="Category not found")
        return {"ok": True}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) 