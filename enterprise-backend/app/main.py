import logging
import os
from datetime import datetime
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

# 导入配置
from app.config import settings

# 导入路由
from app.api.endpoints import (
    company, category, product, inquiry, 
    user, upload, contact_field, contact_message,
    carousel, service, client_product, client_user
)

# 导入数据库
from app.database import engine, Base

# 创建logs目录
os.makedirs("logs", exist_ok=True)

# 创建数据库表
Base.metadata.create_all(bind=engine)

# 配置日志
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(settings.LOG_FILE),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

# 创建FastAPI应用
app = FastAPI(
    title="Enterprise Website API",
    description="企业官网后端API",
    version="1.0.0",
    debug=settings.DEBUG
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 挂载静态文件
if os.path.exists(settings.UPLOAD_DIR):
    app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")

# 健康检查接口
@app.get("/api/health")
async def health_check():
    """健康检查接口"""
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT,
        "timestamp": datetime.now().isoformat(),
        "database_url": settings.DATABASE_URL.split("@")[0] + "@***" if "@" in settings.DATABASE_URL else "***"
    }

# 环境信息接口
@app.get("/api/environment")
async def get_environment_info():
    """获取环境信息"""
    return {
        "environment": settings.ENVIRONMENT,
        "debug": settings.DEBUG,
        "cors_origins": settings.CORS_ORIGINS,
        "log_level": settings.LOG_LEVEL
    }

# 包含路由
app.include_router(company.router, prefix="/api/company", tags=["company"])
app.include_router(category.router, prefix="/api/category", tags=["category"])
app.include_router(product.router, prefix="/api/product", tags=["product"])
app.include_router(inquiry.router, prefix="/api/inquiry", tags=["inquiry"])
app.include_router(user.router, prefix="/api/user", tags=["user"])
app.include_router(upload.router, prefix="/api/upload", tags=["upload"])
app.include_router(contact_field.router, prefix="/api/contact-field", tags=["contact_field"])
app.include_router(contact_message.router, prefix="/api/contact-message", tags=["contact_message"])
app.include_router(carousel.router, prefix="/api/carousel", tags=["carousel"])
app.include_router(service.router, prefix="/api/service", tags=["service"])
app.include_router(client_product.router, prefix="/api/client-product", tags=["client-product"])
app.include_router(client_user.router, prefix="/api/client-user", tags=["client-user"])

# 启动事件
@app.on_event("startup")
async def startup_event():
    """应用启动时的初始化"""
    logger.info(f"Starting application in {settings.ENVIRONMENT} environment")
    logger.info(f"Database URL: {settings.DATABASE_URL.split('@')[0]}@***")
    logger.info(f"CORS Origins: {settings.CORS_ORIGINS}")

# 关闭事件
@app.on_event("shutdown")
async def shutdown_event():
    """应用关闭时的清理"""
    logger.info("Shutting down application")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower()
    ) 