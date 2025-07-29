#!/usr/bin/env python3
import os
import sys
sys.path.append('.')

from app.utils.email import email_sender

def test_email_sending():
    print("测试邮件发送功能...")
    
    # 检查环境变量
    sender_email = os.getenv('SENDER_EMAIL')
    sender_password = os.getenv('SENDER_PASSWORD')
    
    print(f"发件人邮箱: {sender_email}")
    print(f"发件人密码: {'已设置' if sender_password else '未设置'}")
    
    if not sender_email or not sender_password:
        print("❌ 邮件配置未设置")
        return False
    
    # 测试邮件发送
    try:
        success = email_sender.send_inquiry_email(
            company_email="915356588@qq.com",  # 使用相同的邮箱作为测试
            product_id=16,
            product_title="品牌策划",
            product_model="PL3",
            product_image="http://localhost:8000/uploads/test.jpg",
            customer_name="测试用户",
            customer_phone="13800138000",
            customer_email="test@example.com",
            inquiry_content="这是一条测试询价内容",
            created_at="2025-07-29 20:15:00"
        )
        
        if success:
            print("✅ 邮件发送测试成功！")
            return True
        else:
            print("❌ 邮件发送测试失败")
            return False
            
    except Exception as e:
        print(f"❌ 邮件发送测试出错: {e}")
        return False

if __name__ == "__main__":
    test_email_sending() 