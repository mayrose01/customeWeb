from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ... import crud, schemas
from ...database import get_db

router = APIRouter()

@router.get("/", response_model=List[schemas.CarouselImageOut])
def get_carousel_images(active_only: bool = False, db: Session = Depends(get_db)):
    """获取轮播图列表"""
    return crud.get_carousel_images(db, active_only=active_only)

@router.get("/client", response_model=List[schemas.CarouselImageOut])
def get_carousel_images_for_client(db: Session = Depends(get_db)):
    """获取客户端轮播图列表（只返回启用的）"""
    return crud.get_carousel_images(db, active_only=True)

@router.post("/", response_model=schemas.CarouselImageOut)
def create_carousel_image(data: schemas.CarouselImageCreate, db: Session = Depends(get_db)):
    """创建轮播图"""
    return crud.create_carousel_image(db, data)

@router.get("/{image_id}", response_model=schemas.CarouselImageOut)
def get_carousel_image(image_id: int, db: Session = Depends(get_db)):
    """获取单个轮播图"""
    carousel_image = crud.get_carousel_image(db, image_id)
    if not carousel_image:
        raise HTTPException(status_code=404, detail="轮播图不存在")
    return carousel_image

@router.put("/{image_id}", response_model=schemas.CarouselImageOut)
def update_carousel_image(image_id: int, data: schemas.CarouselImageUpdate, db: Session = Depends(get_db)):
    """更新轮播图"""
    carousel_image = crud.update_carousel_image(db, image_id, data)
    if not carousel_image:
        raise HTTPException(status_code=404, detail="轮播图不存在")
    return carousel_image

@router.delete("/{image_id}")
def delete_carousel_image(image_id: int, db: Session = Depends(get_db)):
    """删除轮播图"""
    success = crud.delete_carousel_image(db, image_id)
    if not success:
        raise HTTPException(status_code=404, detail="轮播图不存在")
    return {"message": "删除成功"} 