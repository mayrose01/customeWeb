from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
import os
import uuid
from datetime import datetime

router = APIRouter()

# 从环境变量获取上传目录，默认为uploads
UPLOAD_DIR = os.getenv("UPLOAD_DIR", "uploads")
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

@router.post("/")
async def upload_file(file: UploadFile = File(...)):
    """
    上传图片文件
    支持 JPG/PNG 格式，大小限制 2MB
    """
    # 检查文件类型
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="只支持图片文件")
    
    # 检查文件大小 (2MB = 2 * 1024 * 1024 bytes)
    file_size = 0
    content = await file.read()
    file_size = len(content)
    
    if file_size > 2 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="文件大小不能超过2MB")
    
    # 生成唯一文件名
    file_extension = os.path.splitext(file.filename)[1].lower()
    if file_extension not in ['.jpg', '.jpeg', '.png']:
        raise HTTPException(status_code=400, detail="只支持 JPG/PNG 格式")
    
    unique_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)
    
    # 保存文件
    with open(file_path, "wb") as f:
        f.write(content)
    
    # 返回文件URL
    file_url = f"/uploads/{unique_filename}"
    
    return {
        "filename": unique_filename,
        "url": file_url,
        "size": file_size,
        "content_type": file.content_type
    }

@router.get("/{filename}")
async def get_file(filename: str):
    """
    获取上传的文件
    """
    file_path = os.path.join(UPLOAD_DIR, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="文件不存在")
    
    return FileResponse(file_path) 