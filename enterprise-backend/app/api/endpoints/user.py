from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import schemas, crud
from app.database import SessionLocal
from jose import jwt, JWTError
from datetime import timedelta, datetime
from fastapi.security import OAuth2PasswordRequestForm, HTTPBearer
from typing import Optional, List
from fastapi import Body, Query

SECRET_KEY = "your-secret-key"  # 请替换为安全的密钥
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 1440  # 延长到24小时，减少401问题

router = APIRouter()
security = HTTPBearer()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(token: str = Depends(security), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        role: str = payload.get("role")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = crud.get_user_by_username(db, username)
    if user is None:
        raise credentials_exception
    return user

def get_current_admin_user(current_user: schemas.UserOut = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="需要管理员权限")
    return current_user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

@router.post("/register", response_model=schemas.UserOut)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    # 检查用户名是否已存在
    if user.username:
        db_user = crud.get_user_by_username(db, user.username)
        if db_user:
            raise HTTPException(status_code=400, detail="用户名已存在")
    
    # 检查微信OpenID是否已存在
    if user.wx_openid:
        db_user = crud.get_user_by_wx_openid(db, user.wx_openid)
        if db_user:
            raise HTTPException(status_code=400, detail="微信账号已绑定其他用户")
    
    # 检查App OpenID是否已存在
    if user.app_openid:
        db_user = crud.get_user_by_app_openid(db, user.app_openid)
        if db_user:
            raise HTTPException(status_code=400, detail="App账号已绑定其他用户")
    
    return crud.create_user(db, user)

@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = crud.get_user_by_username(db, form_data.username)
    if not user or not crud.verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=400, detail="用户名或者密码错误")
    
    # 检查用户状态（确保状态为整数1）
    user_status = int(user.status) if user.status is not None else 0
    if user_status != 1:
        raise HTTPException(status_code=400, detail="用户已被禁用")
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "role": user.role}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

# 微信小程序登录
@router.post("/wx-login")
def wx_login(wx_code: str = Body(..., embed=True), db: Session = Depends(get_db)):
    # 这里应该调用微信API获取openid和unionid
    # 简化示例，实际需要调用微信API
    wx_openid = f"wx_openid_{wx_code}"  # 模拟获取openid
    
    user = crud.get_user_by_wx_openid(db, wx_openid)
    if not user:
        # 创建新用户
        user_data = schemas.UserCreate(
            username=f"wx_user_{wx_openid[-8:]}",  # 生成用户名
            wx_openid=wx_openid,
            role="wx_user"
        )
        user = crud.create_user(db, user_data)
    
    # 检查用户状态（确保状态为整数1）
    user_status = int(user.status) if user.status is not None else 0
    if user_status != 1:
        raise HTTPException(status_code=400, detail="用户已被禁用")
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "role": user.role}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

# App端登录
@router.post("/app-login")
def app_login(app_openid: str = Body(..., embed=True), db: Session = Depends(get_db)):
    user = crud.get_user_by_app_openid(db, app_openid)
    if not user:
        # 创建新用户
        user_data = schemas.UserCreate(
            username=f"app_user_{app_openid[-8:]}",  # 生成用户名
            app_openid=app_openid,
            role="app_user"
        )
        user = crud.create_user(db, user_data)
    
    # 检查用户状态（确保状态为整数1）
    user_status = int(user.status) if user.status is not None else 0
    if user_status != 1:
        raise HTTPException(status_code=400, detail="用户已被禁用")
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "role": user.role}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

# Token刷新接口
@router.post("/refresh-token")
def refresh_token(current_user: schemas.UserOut = Depends(get_current_user)):
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": current_user.username, "role": current_user.role}, 
        expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

# 获取当前用户信息
@router.get("/me", response_model=schemas.UserOut)
def get_current_user_info(current_user: schemas.UserOut = Depends(get_current_user)):
    """获取当前登录用户信息"""
    return current_user

@router.post("/change-password")
def change_password(
    username: str = Body(...),
    old_password: str = Body(...),
    new_password: str = Body(...),
    db: Session = Depends(get_db)
):
    user = crud.get_user_by_username(db, username)
    if not user or not crud.verify_password(old_password, user.password_hash):
        raise HTTPException(status_code=400, detail="当前密码错误")
    user.password_hash = crud.get_password_hash(new_password)
    db.commit()
    return {"ok": True}

@router.post("/admin/change-password")
def admin_change_password(
    username: str = Body(...),
    new_password: str = Body(...),
    db: Session = Depends(get_db),
    current_admin: schemas.UserOut = Depends(get_current_admin_user)
):
    """管理员修改用户密码（不需要旧密码验证）"""
    user = crud.get_user_by_username(db, username)
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    user.password_hash = crud.get_password_hash(new_password)
    db.commit()
    return {"ok": True}

# 用户管理接口（需要管理员权限）
@router.get("/", response_model=List[schemas.UserOut])
def get_users(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    role: Optional[str] = Query(None),
    status: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    current_admin: schemas.UserOut = Depends(get_current_admin_user)
):
    """获取用户列表（管理员权限）"""
    users = crud.get_users(db, skip=skip, limit=limit, role=role, status=status)
    return users

@router.get("/{user_id}", response_model=schemas.UserOut)
def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin: schemas.UserOut = Depends(get_current_admin_user)
):
    """获取单个用户信息（管理员权限）"""
    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    return user

@router.put("/{user_id}", response_model=schemas.UserOut)
def update_user(
    user_id: int,
    user_update: schemas.UserUpdate,
    db: Session = Depends(get_db),
    current_admin: schemas.UserOut = Depends(get_current_admin_user)
):
    """更新用户信息（管理员权限）"""
    user = crud.update_user(db, user_id, user_update)
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    return user

@router.delete("/{user_id}")
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin: schemas.UserOut = Depends(get_current_admin_user)
):
    """删除用户（管理员权限）"""
    success = crud.delete_user(db, user_id)
    if not success:
        raise HTTPException(status_code=404, detail="用户不存在")
    return {"ok": True} 