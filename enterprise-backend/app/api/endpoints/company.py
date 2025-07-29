from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import schemas, models, crud
from app.database import SessionLocal
from typing import List

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/", response_model=schemas.CompanyInfoOut)
def get_company_info(db: Session = Depends(get_db)):
    info = crud.get_company_info(db)
    if not info:
        raise HTTPException(status_code=404, detail="Company info not found")
    return info

@router.post("/", response_model=schemas.CompanyInfoOut)
def create_company_info(data: schemas.CompanyInfoCreate, db: Session = Depends(get_db)):
    info = crud.get_company_info(db)
    if info:
        raise HTTPException(status_code=400, detail="Company info already exists")
    new_info = models.CompanyInfo(**data.dict())
    db.add(new_info)
    db.commit()
    db.refresh(new_info)
    return new_info

@router.put("/", response_model=schemas.CompanyInfoOut)
def update_company_info(data: schemas.CompanyInfoUpdate, db: Session = Depends(get_db)):
    info = crud.update_company_info(db, data)
    return info

@router.delete("/", response_model=dict)
def delete_company_info(db: Session = Depends(get_db)):
    info = crud.get_company_info(db)
    if not info:
        raise HTTPException(status_code=404, detail="Company info not found")
    db.delete(info)
    db.commit()
    return {"ok": True} 