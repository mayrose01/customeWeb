import os
from typing import Optional
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # 基础配置
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    
    # 数据库配置
    DATABASE_URL: str = "sqlite:///./test.db"
    
    # JWT配置
    SECRET_KEY: str = "your-secret-key-here"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440
    
    # CORS配置
    CORS_ORIGINS: list = ["http://localhost:3000", "http://localhost:3001", "http://localhost:3002"]
    
    # 邮件配置
    SMTP_SERVER: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USERNAME: str = "your-email@gmail.com"
    SMTP_PASSWORD: str = "your-app-password"
    
    # 文件上传配置
    UPLOAD_DIR: str = "uploads"
    MAX_FILE_SIZE: int = 2097152  # 2MB
    
    # 日志配置
    LOG_LEVEL: str = "INFO"
    LOG_FILE: str = "logs/app.log"
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

# 环境特定的配置
def get_settings() -> Settings:
    """根据环境获取配置"""
    environment = os.getenv("ENVIRONMENT", "development")
    
    if environment == "development":
        return DevelopmentSettings()
    elif environment == "testing":
        return TestingSettings()
    elif environment == "production":
        return ProductionSettings()
    else:
        return Settings()

class DevelopmentSettings(Settings):
    """开发环境配置"""
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    
    # 本地开发环境数据库配置
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "mysql+pymysql://root:root@localhost:3306/enterprise_dev"
    )
    
    # 本地开发环境CORS
    CORS_ORIGINS: list = [
        "http://localhost:3000",
        "http://localhost:3001", 
        "http://localhost:3002",
        "http://dev.yourdomain.com:8080"
    ]
    
    # 本地开发环境日志
    LOG_LEVEL: str = "DEBUG"
    LOG_FILE: str = "logs/app_dev.log"

class TestingSettings(Settings):
    """测试环境配置"""
    ENVIRONMENT: str = "testing"
    DEBUG: bool = False
    
    # 测试环境数据库配置 - 优先使用环境变量，否则使用本地配置
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "mysql+pymysql://test_user:test_password@localhost:3307/enterprise_test"
    )
    
    # 测试环境CORS
    CORS_ORIGINS: list = [
        "http://localhost:3001",
        "http://test.yourdomain.com:8080"
    ]
    
    # 测试环境日志
    LOG_LEVEL: str = "INFO"
    LOG_FILE: str = "logs/app_test.log"

class ProductionSettings(Settings):
    """生产环境配置"""
    ENVIRONMENT: str = "production"
    DEBUG: bool = False
    
    # 生产环境数据库配置
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "mysql://prod_user:prod_password@mysql_prod:3306/enterprise_pro"
    )
    
    # 生产环境CORS
    CORS_ORIGINS: list = [
        "https://yourdomain.com",
        "https://www.yourdomain.com"
    ]
    
    # 生产环境日志
    LOG_LEVEL: str = "INFO"
    LOG_FILE: str = "logs/app_prod.log"

# 全局设置实例
settings = get_settings() 