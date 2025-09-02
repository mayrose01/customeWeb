# 邮件发送功能配置说明

## 功能概述

系统已实现邮件发送功能，包括：

1. **产品询价邮件**：客户在产品详情页提交询价时，自动发送邮件到公司邮箱
2. **联系咨询邮件**：客户在联系页面提交咨询时，自动发送邮件到公司邮箱

## 邮件内容

### 产品询价邮件
- **邮件标题**：`产品询价 - 客户姓名 - 产品型号 - 产品标题`
- **邮件内容包含**：
  - 产品ID、产品标题、产品型号、产品主图
  - 客户姓名、手机号、邮箱
  - 询价内容、提交时间

### 联系咨询邮件
- **邮件标题**：`在线咨询 - 咨询主题`
- **邮件内容包含**：
  - 客户姓名、邮箱、电话
  - 咨询主题、咨询内容
  - 提交时间

## 配置步骤

### 1. 获取QQ邮箱授权码

1. 登录QQ邮箱网页版
2. 进入"设置" -> "账户"
3. 找到"POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务"
4. 开启"POP3/SMTP服务"
5. 按照提示获取授权码（不是QQ密码）

### 2. 设置环境变量

在系统环境变量中设置：

```bash
# Linux/Mac
export SENDER_EMAIL="your-email@qq.com"
export SENDER_PASSWORD="your-authorization-code"

# Windows
set SENDER_EMAIL=your-email@qq.com
set SENDER_PASSWORD=your-authorization-code
```

或者在项目根目录创建 `.env` 文件：

```
SENDER_EMAIL=your-email@qq.com
SENDER_PASSWORD=your-authorization-code
```

### 3. 配置公司邮箱

在后台管理系统的"公司信息"页面中设置公司邮箱地址，邮件将发送到此邮箱。

## 邮件服务器配置

当前配置使用QQ邮箱SMTP服务器：
- SMTP服务器：smtp.qq.com
- 端口：587
- 加密方式：TLS

如需使用其他邮箱服务商，请修改 `app/utils/email.py` 中的配置。

## 测试邮件发送

1. 确保环境变量已正确设置
2. 确保公司信息中已设置邮箱地址
3. 在前台页面提交询价或咨询
4. 检查公司邮箱是否收到邮件

## 故障排除

### 邮件发送失败
1. 检查环境变量是否正确设置
2. 检查QQ邮箱授权码是否正确
3. 检查网络连接是否正常
4. 查看后端日志文件 `logs/app_YYYYMMDD.log`

### 常见错误及解决方案

#### 1. 配置未设置错误
**错误信息**: `邮件配置未设置，无法发送邮件`
**解决方案**: 
```bash
# 设置环境变量
export SENDER_EMAIL="your-email@qq.com"
export SENDER_PASSWORD="your-authorization-code"
```

#### 2. SMTP认证失败
**错误信息**: `SMTPAuthenticationError: (535, b'Error: authentication failed')`
**解决方案**:
- 确认邮箱地址正确
- 确认使用的是授权码而不是QQ密码
- 重新获取授权码

#### 3. 连接被拒绝
**错误信息**: `Connection unexpectedly closed`
**解决方案**:
- 检查网络连接
- 确认防火墙没有阻止SMTP连接
- 尝试使用其他网络环境

#### 4. 授权码错误
**错误信息**: `SMTPAuthenticationError: (535, b'Error: authentication failed')`
**解决方案**:
1. 登录QQ邮箱网页版
2. 进入"设置" -> "账户"
3. 找到"POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务"
4. 重新开启"POP3/SMTP服务"
5. 重新获取授权码

### 测试邮件功能
运行以下命令测试邮件配置：
```bash
# 设置环境变量后
python3 -c "
import os
import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

sender_email = os.getenv('SENDER_EMAIL')
sender_password = os.getenv('SENDER_PASSWORD')

if not sender_email or not sender_password:
    print('❌ 环境变量未设置')
    exit(1)

try:
    server = smtplib.SMTP('smtp.qq.com', 587)
    server.starttls()
    server.login(sender_email, sender_password)
    print('✅ 邮件配置测试通过')
    server.quit()
except Exception as e:
    print(f'❌ 邮件配置测试失败: {e}')
"
```

## 安全注意事项

1. 不要在代码中硬编码邮箱密码
2. 使用环境变量或配置文件存储敏感信息
3. 定期更换邮箱授权码
4. 监控邮件发送日志

## 日志查看

邮件发送日志会记录在 `logs/app_YYYYMMDD.log` 文件中，包括：
- 邮件发送成功/失败状态
- 发送的邮件主题和收件人
- 错误信息和异常堆栈 