import logging
import os
from datetime import datetime
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.models import Base
from app.database import engine
from app.api import router as api_router
import time

# 创建logs目录
os.makedirs("logs", exist_ok=True)

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f'logs/app_{datetime.now().strftime("%Y%m%d")}.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

# 从环境变量获取上传目录，默认为uploads
UPLOAD_DIR = os.getenv("UPLOAD_DIR", "uploads")
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="企业网站API")

# 数据库操作监控中间件
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    
    # 记录请求开始
    logger.info(f"API请求开始: {request.method} {request.url.path} - 客户端: {request.client.host if request.client else 'unknown'}")
    
    # 处理请求
    response = await call_next(request)
    
    # 计算处理时间
    process_time = time.time() - start_time
    
    # 记录请求完成
    logger.info(f"API请求完成: {request.method} {request.url.path} - 状态码: {response.status_code} - 处理时间: {process_time:.3f}秒")
    
    return response

# 添加 CORS 中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost", 
        "http://localhost:5173", 
        "http://localhost:5174", 
        "http://localhost:3000", 
        "http://localhost:3001",  # 测试环境前端
        "http://localhost:3002",  # 前端服务端口
        "http://127.0.0.1",
        "http://127.0.0.1:5173",
        "http://127.0.0.1:5174",
        "http://127.0.0.1:3001",  # 测试环境前端
        "http://127.0.0.1:3002",  # 前端服务端口
        "http://test.catusfoto.top",  # 测试环境域名
        "https://catusfoto.top",  # 生产环境
        "https://www.catusfoto.top"  # 生产环境www
    ],  # 允许的前端地址
    allow_credentials=True,
    allow_methods=["*"],  # 允许所有 HTTP 方法
    allow_headers=["*"],  # 允许所有请求头
)

# 开发环境API路由
app.include_router(api_router, prefix="/api")

# 测试环境API路由 - 使用测试数据库
try:
    from app.test_api import router as test_api_router
    app.include_router(test_api_router, prefix="/test/api")
except ImportError:
    # 测试API模块不存在时跳过
    pass

# 挂载静态文件目录 - 使用环境变量
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# 启动日志
logger.info("企业网站API服务启动")
logger.info(f"当前时间: {datetime.now()}")
logger.info(f"当前环境数据库连接: {engine.url}")
logger.info(f"上传目录: {UPLOAD_DIR}")
logger.info("日志系统已启用，所有数据库操作将被记录") 