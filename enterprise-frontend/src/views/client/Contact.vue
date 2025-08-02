<template>
  <div class="contact-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 页面标题 -->
        <div class="page-header">
          <h1>联系我们</h1>
          <p>我们随时为您提供专业的服务和支持</p>
        </div>

        <div class="contact-content">
          <!-- 联系信息 -->
          <div class="contact-info-section">
            <h2>联系信息</h2>
            <div class="contact-grid">
              <div class="contact-item">
                <div class="contact-icon">📍</div>
                <h3>公司地址</h3>
                <p>{{ companyInfo.address || '地址信息待完善' }}</p>
              </div>
              <div class="contact-item">
                <div class="contact-icon">📧</div>
                <h3>邮箱地址</h3>
                <p>{{ companyInfo.email || '邮箱信息待完善' }}</p>
              </div>
              <div class="contact-item">
                <div class="contact-icon">📞</div>
                <h3>联系电话</h3>
                <p>{{ companyInfo.phone || '电话信息待完善' }}</p>
              </div>
              <div class="contact-item">
                <div class="contact-icon">🕒</div>
                <h3>工作时间</h3>
                <p>{{ companyInfo.working_hours || '周一至周五: 9:00-18:00' }}</p>
              </div>
            </div>
          </div>

          <!-- 咨询表单 -->
          <div class="inquiry-form-section">
            <h2>在线咨询</h2>
            <form @submit.prevent="submitInquiry" class="inquiry-form">
              <div class="form-row">
                <div class="form-group">
                  <label for="name">姓名 *</label>
                  <input 
                    type="text" 
                    id="name" 
                    v-model="inquiryForm.name" 
                    required
                    placeholder="请输入您的姓名"
                  />
                </div>
                <div class="form-group">
                  <label for="email">邮箱 *</label>
                  <input 
                    type="email" 
                    id="email" 
                    v-model="inquiryForm.email" 
                    required
                    placeholder="请输入您的邮箱地址"
                  />
                </div>
              </div>

              <div class="form-group">
                <label for="phone">联系电话</label>
                <input 
                  type="tel" 
                  id="phone" 
                  v-model="inquiryForm.phone" 
                  placeholder="请输入您的联系电话"
                />
              </div>

              <div class="form-group">
                <label for="subject">咨询主题 *</label>
                <input 
                  type="text" 
                  id="subject" 
                  v-model="inquiryForm.subject" 
                  required
                  placeholder="请输入咨询主题"
                />
              </div>

              <div class="form-group">
                <label for="message">咨询内容 *</label>
                <textarea 
                  id="message" 
                  v-model="inquiryForm.message" 
                  required
                  rows="6"
                  placeholder="请详细描述您的需求或问题"
                ></textarea>
              </div>

              <div class="form-actions">
                <button type="submit" class="submit-btn" :disabled="submitting">
                  {{ submitting ? '提交中...' : '提交咨询' }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </main>
    
    <ClientFooter />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getCompanyInfo } from '@/api/client'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { userStore } from '@/store/user'
import { useRouter } from 'vue-router'
import { API_BASE_URL } from '../../../env.config.js'

const router = useRouter()
const companyInfo = ref({})
const submitting = ref(false)

const inquiryForm = reactive({
  name: '',
  email: '',
  phone: '',
  subject: '',
  message: ''
})

const loadCompanyInfo = async () => {
  try {
    const response = await getCompanyInfo()
    companyInfo.value = response.data
  } catch (error) {
    console.error('加载公司信息失败:', error)
  }
}

// 自动填充用户信息
const fillUserInfo = () => {
  if (userStore.isLoggedIn && userStore.userInfo) {
    inquiryForm.email = userStore.userInfo.email || ''
    inquiryForm.phone = userStore.userInfo.phone || ''
  }
}

const submitInquiry = async () => {
  if (submitting.value) return
  
  submitting.value = true
  try {
    const inquiryData = {
      name: inquiryForm.name,
      email: inquiryForm.email,
      phone: inquiryForm.phone,
      subject: inquiryForm.subject,
      message: inquiryForm.message
    }

    // 使用支持用户关联的API
    const response = await fetch(`${API_BASE_URL}/contact-message/with-user`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('client_token')}`
      },
      body: JSON.stringify(inquiryData)
    })

    if (response.ok) {
      alert('咨询提交成功！我们会尽快与您联系。')
      // 重置表单
      inquiryForm.name = ''
      inquiryForm.email = ''
      inquiryForm.phone = ''
      inquiryForm.subject = ''
      inquiryForm.message = ''
      // 重新填充用户信息
      fillUserInfo()
      
      // 如果用户已登录，跳转到咨询列表页面
      if (userStore.isLoggedIn) {
        router.push('/consultations')
      }
    } else {
      const error = await response.json()
      alert(error.detail || '提交失败，请稍后重试')
    }
  } catch (error) {
    console.error('提交咨询失败:', error)
    alert('提交失败，请稍后重试')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadCompanyInfo()
  fillUserInfo()
})
</script>

<style scoped>
.contact-page {
  min-height: 100vh;
  background: #f8f9fa;
  padding-top: 80px;
}

.main-content {
  padding: 40px 0;
  min-height: calc(100vh - 80px - 200px);
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h1 {
  color: #333;
  font-size: 36px;
  font-weight: 600;
  margin-bottom: 10px;
}

.page-header p {
  color: #666;
  font-size: 18px;
}

.contact-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
  align-items: start;
}

.contact-info-section,
.inquiry-form-section {
  background: white;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.contact-info-section h2,
.inquiry-form-section h2 {
  color: #333;
  font-size: 24px;
  margin-bottom: 20px;
  font-weight: 600;
}

.contact-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.contact-item {
  text-align: center;
  padding: 20px;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  background: #f8f9fa;
}

.contact-icon {
  font-size: 32px;
  margin-bottom: 10px;
}

.contact-item h3 {
  color: #333;
  font-size: 16px;
  margin-bottom: 8px;
  font-weight: 600;
}

.contact-item p {
  color: #666;
  font-size: 14px;
  line-height: 1.5;
  margin: 0;
}

.inquiry-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 8px;
  color: #333;
  font-weight: 500;
  font-size: 14px;
}

.form-group input,
.form-group textarea {
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  transition: border-color 0.2s;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
}

.form-group textarea {
  resize: vertical;
  min-height: 120px;
}

.form-actions {
  margin-top: 10px;
}

.submit-btn {
  width: 100%;
  padding: 14px;
  background-color: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.submit-btn:hover:not(:disabled) {
  background-color: #2563eb;
}

.submit-btn:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .contact-content {
    grid-template-columns: 1fr;
    gap: 30px;
  }
  
  .contact-grid {
    grid-template-columns: 1fr;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .page-header h1 {
    font-size: 28px;
  }
  
  .page-header p {
    font-size: 16px;
  }
  
  .contact-info-section,
  .inquiry-form-section {
    padding: 20px;
  }
}
</style> 