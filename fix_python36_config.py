import os
from typing import Optional

class Settings:
    # 基础配置
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    
    # 数据库配置
    DATABASE_URL: str = os.getenv("DATABASE_URL", "mysql://enterprise_user:YOUR_DATABASE_PASSWORD_HERE@localhost:3306/enterprise_prod")
    
    # JWT配置
    SECRET_KEY: str = os.getenv("SECRET_KEY", "catusfoto_enterprise_secret_key_2024")
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "1440"))
    
    # CORS配置
    CORS_ORIGINS: list = eval(os.getenv("CORS_ORIGINS", '["https://catusfoto.top", "http://catusfoto.top", "https://www.catusfoto.top", "http://www.catusfoto.top"]'))
    
    # 邮件配置
    SMTP_SERVER: str = os.getenv("SMTP_SERVER", "smtp.gmail.com")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
    SMTP_USERNAME: str = os.getenv("SMTP_USERNAME", "your-email@gmail.com")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "your-app-password")
    
    # 文件上传配置
    UPLOAD_DIR: str = os.getenv("UPLOAD_DIR", "uploads")
    MAX_FILE_SIZE: int = int(os.getenv("MAX_FILE_SIZE", "2097152"))
    
    # 日志配置
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_FILE: str = os.getenv("LOG_FILE", "logs/app.log")
    
    def __init__(self):
        # 从环境变量文件加载配置
        env_file = os.getenv("ENV_FILE", "production.env")
        if os.path.exists(env_file):
            with open(env_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, value = line.split('=', 1)
                        key = key.strip()
                        value = value.strip()
                        
                        # 设置环境变量
                        if key == "DATABASE_URL":
                            self.DATABASE_URL = value
                        elif key == "SECRET_KEY":
                            self.SECRET_KEY = value
                        elif key == "ALGORITHM":
                            self.ALGORITHM = value
                        elif key == "ACCESS_TOKEN_EXPIRE_MINUTES":
                            self.ACCESS_TOKEN_EXPIRE_MINUTES = int(value)
                        elif key == "CORS_ORIGINS":
                            self.CORS_ORIGINS = eval(value)
                        elif key == "SMTP_SERVER":
                            self.SMTP_SERVER = value
                        elif key == "SMTP_PORT":
                            self.SMTP_PORT = int(value)
                        elif key == "SMTP_USERNAME":
                            self.SMTP_USERNAME = value
                        elif key == "SMTP_PASSWORD":
                            self.SMTP_PASSWORD = value
                        elif key == "UPLOAD_DIR":
                            self.UPLOAD_DIR = value
                        elif key == "MAX_FILE_SIZE":
                            self.MAX_FILE_SIZE = int(value)
                        elif key == "LOG_LEVEL":
                            self.LOG_LEVEL = value
                        elif key == "LOG_FILE":
                            self.LOG_FILE = value

# 创建全局设置实例
settings = Settings()
