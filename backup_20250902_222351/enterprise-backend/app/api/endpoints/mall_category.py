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

@router.get("/", response_model=List[schemas.MallCategoryOut])
def list_mall_categories(db: Session = Depends(get_db)):
    """获取商城分类列表"""
    categories = crud.get_mall_categories(db)
    return [schemas.MallCategoryOut.model_validate(c, from_attributes=True) for c in categories]

@router.get("/tree", response_model=List[schemas.MallCategoryOut])
def get_mall_categories_tree(db: Session = Depends(get_db)):
    """获取商城分类树形结构"""
    cats = crud.get_mall_categories_tree(db)
    return [schemas.MallCategoryOut.model_validate(c, from_attributes=True) for c in cats]

@router.get("/{parent_id}/subcategories", response_model=List[schemas.MallCategoryOut])
def get_mall_subcategories(parent_id: int, db: Session = Depends(get_db)):
    """获取商城子分类"""
    subs = crud.get_mall_subcategories(db, parent_id)
    return [schemas.MallCategoryOut.model_validate(c, from_attributes=True) for c in subs]

@router.post("/", response_model=schemas.MallCategoryOut)
def create_mall_category(data: schemas.MallCategoryCreate, db: Session = Depends(get_db)):
    """创建商城分类"""
    cat = crud.create_mall_category(db, data)
    return schemas.MallCategoryOut.model_validate(cat, from_attributes=True)

@router.get("/{category_id}", response_model=schemas.MallCategoryOut)
def get_mall_category(category_id: int, db: Session = Depends(get_db)):
    """获取商城分类详情"""
    category = crud.get_mall_category(db, category_id)
    if not category:
        raise HTTPException(status_code=404, detail="商城分类不存在")
    return schemas.MallCategoryOut.model_validate(category, from_attributes=True)

@router.put("/{category_id}", response_model=schemas.MallCategoryOut)
def update_mall_category(category_id: int, data: schemas.MallCategoryCreate, db: Session = Depends(get_db)):
    """更新商城分类"""
    try:
        category = crud.update_mall_category(db, category_id, data)
        if not category:
            raise HTTPException(status_code=404, detail="商城分类不存在")
        return schemas.MallCategoryOut.model_validate(category, from_attributes=True)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{category_id}")
def delete_mall_category(category_id: int, db: Session = Depends(get_db)):
    """删除商城分类"""
    try:
        success = crud.delete_mall_category(db, category_id)
        if not success:
            raise HTTPException(status_code=404, detail="商城分类不存在")
        return {"ok": True, "message": "商城分类删除成功"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
