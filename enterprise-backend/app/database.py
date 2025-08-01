import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# 根据环境加载不同的配置文件
env = os.getenv("ENV", "development")
if env == "production":
    load_dotenv("production.env")
elif env == "test":
    # 测试环境使用test.env配置
    load_dotenv("test.env", override=True)
else:
    # 开发环境使用本地配置
    load_dotenv("dev.env", override=True)

# 从环境变量获取数据库URL，如果没有则使用默认值
if env == "production":
    SQLALCHEMY_DATABASE_URL = os.getenv(
        "DATABASE_URL", 
        "mysql+pymysql://enterprise_user:enterprise_password_2024@localhost:3306/enterprise_db"
    )
elif env == "test":
    # 测试环境数据库配置
    SQLALCHEMY_DATABASE_URL = os.getenv(
        "DATABASE_URL", 
        "mysql+pymysql://test_user:test_password@localhost:3307/enterprise_test"
    )
else:
    # 开发环境使用本地MySQL
    SQLALCHEMY_DATABASE_URL = os.getenv(
        "DATABASE_URL", 
        "mysql+pymysql://root:root@localhost:3306/enterprise_dev"
    )

# 根据环境创建数据库引擎
engine = create_engine(SQLALCHEMY_DATABASE_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)



def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

 