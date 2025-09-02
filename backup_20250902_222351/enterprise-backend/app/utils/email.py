import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.image import MIMEImage
import logging
from typing import Optional, List
import os

logger = logging.getLogger(__name__)

class EmailSender:
    def __init__(self):
        # 邮件服务器配置
        self.smtp_server = "smtp.qq.com"  # QQ邮箱SMTP服务器
        self.smtp_port = 587  # TLS端口
        self.sender_email = os.getenv("SENDER_EMAIL", "your-email@qq.com")  # 发件人邮箱
        self.sender_password = os.getenv("SENDER_PASSWORD", "your-app-password")  # 发件人密码（应用专用密码）
        
        # 检查配置
        if self.sender_email == "your-email@qq.com" or self.sender_password == "your-app-password":
            logger.warning("邮件配置未设置！请在环境变量中设置 SENDER_EMAIL 和 SENDER_PASSWORD")
            logger.warning("当前配置: SENDER_EMAIL=%s, SENDER_PASSWORD=%s", 
                         self.sender_email, "***" if self.sender_password != "your-app-password" else "未设置")
        
    def send_inquiry_email(self, 
                          company_email: str,
                          product_id: int,
                          product_title: str,
                          product_model: Optional[str],
                          product_image: Optional[str],
                          customer_name: str,
                          customer_phone: Optional[str],
                          customer_email: str,
                          inquiry_content: str,
                          created_at: str) -> bool:
        """
        发送产品询价邮件
        
        Args:
            company_email: 公司邮箱
            product_id: 产品ID
            product_title: 产品标题
            product_model: 产品型号
            product_image: 产品主图URL
            customer_name: 客户姓名
            customer_phone: 客户手机号
            customer_email: 客户邮箱
            inquiry_content: 询价内容
            created_at: 提交时间
            
        Returns:
            bool: 发送是否成功
        """
        try:
            # 邮件主题
            subject = f"产品询价 - {customer_name} - {product_model or '无型号'} - {product_title}"
            
            # 邮件内容
            html_content = f"""
            <html>
            <head>
                <meta charset="utf-8">
                <style>
                    body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                    .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                    .header {{ background: #3b82f6; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }}
                    .content {{ background: #f8fafc; padding: 20px; border-radius: 0 0 8px 8px; }}
                    .section {{ margin-bottom: 20px; }}
                    .section h3 {{ color: #3b82f6; border-bottom: 2px solid #3b82f6; padding-bottom: 5px; }}
                    .info-row {{ display: flex; margin-bottom: 10px; }}
                    .label {{ font-weight: bold; width: 120px; }}
                    .value {{ flex: 1; }}
                    .product-image {{ max-width: 200px; max-height: 150px; border-radius: 8px; }}
                    .inquiry-content {{ background: white; padding: 15px; border-radius: 6px; border-left: 4px solid #3b82f6; }}
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>产品询价通知</h1>
                        <p>收到新的产品询价请求</p>
                    </div>
                    
                    <div class="content">
                        <div class="section">
                            <h3>产品信息</h3>
                            <div class="info-row">
                                <span class="label">产品ID:</span>
                                <span class="value">{product_id}</span>
                            </div>
                            <div class="info-row">
                                <span class="label">产品标题:</span>
                                <span class="value">{product_title}</span>
                            </div>
                            <div class="info-row">
                                <span class="label">产品型号:</span>
                                <span class="value">{product_model or '无型号'}</span>
                            </div>
                            {f'<div class="info-row"><span class="label">产品主图:</span><span class="value"><img src="{product_image}" class="product-image" alt="产品图片" /></span></div>' if product_image else ''}
                        </div>
                        
                        <div class="section">
                            <h3>客户信息</h3>
                            <div class="info-row">
                                <span class="label">客户姓名:</span>
                                <span class="value">{customer_name}</span>
                            </div>
                            <div class="info-row">
                                <span class="label">客户邮箱:</span>
                                <span class="value">{customer_email}</span>
                            </div>
                            <div class="info-row">
                                <span class="label">客户手机:</span>
                                <span class="value">{customer_phone or '未填写'}</span>
                            </div>
                        </div>
                        
                        <div class="section">
                            <h3>询价内容</h3>
                            <div class="inquiry-content">
                                {inquiry_content.replace(chr(10), '<br>')}
                            </div>
                        </div>
                        
                        <div class="section">
                            <h3>提交时间</h3>
                            <div class="info-row">
                                <span class="label">提交时间:</span>
                                <span class="value">{created_at}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """
            
            return self._send_email(company_email, subject, html_content)
            
        except Exception as e:
            logger.error(f"发送询价邮件失败: {e}")
            return False
    
    def send_contact_email(self,
                          company_email: str,
                          customer_name: str,
                          customer_email: str,
                          customer_phone: Optional[str],
                          subject: str,
                          message: str,
                          created_at: str) -> bool:
        """
        发送联系咨询邮件
        
        Args:
            company_email: 公司邮箱
            customer_name: 客户姓名
            customer_email: 客户邮箱
            customer_phone: 客户电话
            subject: 咨询主题
            message: 咨询内容
            created_at: 提交时间
            
        Returns:
            bool: 发送是否成功
        """
        try:
            # 邮件主题
            email_subject = f"在线咨询 - {subject}"
            
            # 邮件内容
            html_content = f"""
            <html>
            <head>
                <meta charset="utf-8">
                <style>
                    body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                    .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                    .header {{ background: #3b82f6; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }}
                    .content {{ background: #f8fafc; padding: 20px; border-radius: 0 0 8px 8px; }}
                    .section {{ margin-bottom: 20px; }}
                    .section h3 {{ color: #3b82f6; border-bottom: 2px solid #3b82f6; padding-bottom: 5px; }}
                    .info-row {{ display: flex; margin-bottom: 10px; }}
                    .label {{ font-weight: bold; width: 120px; }}
                    .value {{ flex: 1; }}
                    .message-content {{ background: white; padding: 15px; border-radius: 6px; border-left: 4px solid #3b82f6; }}
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>在线咨询通知</h1>
                        <p>收到新的在线咨询请求</p>
                    </div>
                    
                    <div class="content">
                        <div class="section">
                            <h3>客户信息</h3>
                            <div class="info-row">
                                <span class="label">客户姓名:</span>
                                <span class="value">{customer_name}</span>
                            </div>
                            <div class="info-row">
                                <span class="label">客户邮箱:</span>
                                <span class="value">{customer_email}</span>
                            </div>
                            <div class="info-row">
                                <span class="label">客户电话:</span>
                                <span class="value">{customer_phone or '未填写'}</span>
                            </div>
                        </div>
                        
                        <div class="section">
                            <h3>咨询信息</h3>
                            <div class="info-row">
                                <span class="label">咨询主题:</span>
                                <span class="value">{subject}</span>
                            </div>
                            <div class="section">
                                <h3>咨询内容</h3>
                                <div class="message-content">
                                    {message.replace(chr(10), '<br>')}
                                </div>
                            </div>
                        </div>
                        
                        <div class="section">
                            <h3>提交时间</h3>
                            <div class="info-row">
                                <span class="label">提交时间:</span>
                                <span class="value">{created_at}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """
            
            return self._send_email(company_email, email_subject, html_content)
            
        except Exception as e:
            logger.error(f"发送联系咨询邮件失败: {e}")
            return False
    
    def _send_email(self, to_email: str, subject: str, html_content: str) -> bool:
        """
        发送邮件
        
        Args:
            to_email: 收件人邮箱
            subject: 邮件主题
            html_content: HTML邮件内容
            
        Returns:
            bool: 发送是否成功
        """
        try:
            # 检查配置
            if self.sender_email == "your-email@qq.com" or self.sender_password == "your-app-password":
                logger.error("邮件配置未设置，无法发送邮件")
                return False
            
            # 创建邮件对象
            msg = MIMEMultipart('alternative')
            msg['From'] = self.sender_email
            msg['To'] = to_email
            msg['Subject'] = subject
            
            # 添加HTML内容
            html_part = MIMEText(html_content, 'html', 'utf-8')
            msg.attach(html_part)
            
            logger.info(f"尝试发送邮件到: {to_email}, 主题: {subject}")
            logger.info(f"使用SMTP服务器: {self.smtp_server}:{self.smtp_port}")
            
            # 连接SMTP服务器并发送
            context = ssl.create_default_context()
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                logger.info("SMTP连接建立成功")
                server.starttls(context=context)
                logger.info("TLS加密启动成功")
                server.login(self.sender_email, self.sender_password)
                logger.info("SMTP登录成功")
                server.send_message(msg)
                logger.info("邮件发送成功")
            
            logger.info(f"邮件发送成功: {to_email}, 主题: {subject}")
            return True
            
        except smtplib.SMTPAuthenticationError as e:
            logger.error(f"SMTP认证失败: {e}")
            logger.error("请检查邮箱地址和授权码是否正确")
            return False
        except smtplib.SMTPConnectError as e:
            logger.error(f"SMTP连接失败: {e}")
            logger.error("请检查网络连接和SMTP服务器配置")
            return False
        except smtplib.SMTPException as e:
            logger.error(f"SMTP错误: {e}")
            return False
        except Exception as e:
            logger.error(f"邮件发送失败: {e}")
            return False

# 创建全局邮件发送器实例
email_sender = EmailSender() 