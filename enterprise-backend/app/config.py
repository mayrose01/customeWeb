import os
import json
from typing import Optional, List
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # 基础配置
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    DEBUG: bool = os.getenv("DEBUG", "true").lower() == "true"
    
    # 数据库配置 - 优先使用环境变量
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./test.db")
    
    # JWT配置 - 生产环境必须设置强密钥
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-here-change-in-production")
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "1440"))
    
    # CORS配置 - 从环境变量读取，支持JSON格式
    CORS_ORIGINS: List[str] = json.loads(os.getenv("CORS_ORIGINS", '["http://localhost:3000", "http://localhost:3001", "http://localhost:3002"]'))
    
    # 邮件配置
    SMTP_SERVER: str = os.getenv("SMTP_SERVER", "smtp.gmail.com")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
    SMTP_USERNAME: str = os.getenv("SMTP_USERNAME", "your-email@gmail.com")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "your-app-password")
    SMTP_USE_TLS: bool = os.getenv("SMTP_USE_TLS", "true").lower() == "true"
    
    # 文件上传配置
    UPLOAD_DIR: str = os.getenv("UPLOAD_DIR", "uploads")
    MAX_FILE_SIZE: int = int(os.getenv("MAX_FILE_SIZE", "2097152"))  # 2MB
    ALLOWED_EXTENSIONS: str = os.getenv("ALLOWED_EXTENSIONS", "jpg,jpeg,png,gif,pdf,doc,docx")
    
    # 文件访问URL配置 - 根据环境动态设置
    FILE_BASE_URL: str = os.getenv("FILE_BASE_URL", "http://localhost:8000")
    
    # 日志配置
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_FILE: str = os.getenv("LOG_FILE", "")  # 空字符串表示不使用文件日志
    
    class Config:
        # 不再依赖 .env 文件，所有配置通过环境变量注入
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
    CORS_ORIGINS: List[str] = json.loads(os.getenv(
        "CORS_ORIGINS",
        '["http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://dev.yourdomain.com:8080"]'
    ))
    
    # 本地开发环境日志
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "DEBUG")
    LOG_FILE: str = os.getenv("LOG_FILE", "logs/app_dev.log")

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
    CORS_ORIGINS: List[str] = json.loads(os.getenv(
        "CORS_ORIGINS",
        '["http://localhost:3001", "http://test.yourdomain.com:8080"]'
    ))
    
    # 测试环境日志
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_FILE: str = os.getenv("LOG_FILE", "logs/app_test.log")
    
    # 测试环境文件访问URL
    FILE_BASE_URL: str = os.getenv("FILE_BASE_URL", "http://localhost:8001")

class ProductionSettings(Settings):
    """生产环境配置"""
    ENVIRONMENT: str = "production"
    DEBUG: bool = False
    
    # 生产环境数据库配置 - 必须通过环境变量设置
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "mysql://prod_user:prod_password@mysql_prod:3306/enterprise_prod"
    )
    
    # 生产环境CORS
    CORS_ORIGINS: List[str] = json.loads(os.getenv(
        "CORS_ORIGINS",
        '["https://yourdomain.com", "https://www.yourdomain.com"]'
    ))
    
    # 生产环境日志
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_FILE: str = os.getenv("LOG_FILE", "logs/app_prod.log")

# 全局设置实例
settings = get_settings() 