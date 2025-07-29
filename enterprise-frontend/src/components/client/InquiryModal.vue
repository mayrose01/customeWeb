<template>
  <div v-if="visible" class="inquiry-modal" @click="handleModalClick">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h3>产品询价</h3>
        <button class="close-btn" @click="handleClose">×</button>
      </div>
      <div class="modal-body">
        <div class="product-info">
          <img 
            v-if="product.images && product.images.length > 0" 
            :src="getImageUrl(product.images[0])" 
            :alt="product.title"
            class="product-thumbnail"
          />
          <div class="product-details">
            <h4>{{ product.title }}</h4>
            <p v-if="product.model">型号: {{ product.model }}</p>
          </div>
        </div>
        <form @submit.prevent="handleSubmit" class="inquiry-form">
          <div class="form-group">
            <label for="name">姓名 *</label>
            <input 
              type="text" 
              id="name" 
              v-model="form.name" 
              required
              placeholder="请输入您的姓名"
            />
          </div>
          <div class="form-group">
            <label for="email">邮箱 *</label>
            <input 
              type="email" 
              id="email" 
              v-model="form.email" 
              required
              placeholder="请输入您的邮箱"
            />
          </div>
          <div class="form-group">
            <label for="phone">手机号 *</label>
            <input 
              type="tel" 
              id="phone" 
              v-model="form.phone" 
              required
              placeholder="请输入您的手机号"
            />
          </div>
          <div class="form-group">
            <label for="message">询价内容 *</label>
            <textarea 
              id="message" 
              v-model="form.message" 
              required
              rows="4"
              placeholder="请详细描述您的需求..."
            ></textarea>
          </div>
          <div class="form-actions">
            <button type="button" @click="handleClose" class="cancel-btn">取消</button>
            <button type="submit" class="submit-btn" :disabled="submitting">
              {{ submitting ? '提交中...' : '提交询价' }}
            </button>
          </div>
        </form>
      </div>
    </div>
    

  </div>
</template>

<script>
import { ref, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { createInquiry } from '@/api/inquiry'
import { getImageUrl } from '@/utils/imageUtils'
import { userStore } from '@/store/user'

export default {
  name: 'InquiryModal',

  props: {
    visible: {
      type: Boolean,
      default: false
    },
    product: {
      type: Object,
      default: () => ({})
    }
  },
  emits: ['close', 'success'],
  setup(props, { emit }) {
    const router = useRouter()
    const submitting = ref(false)
    const form = ref({
      name: '',
      email: '',
      phone: '',
      message: ''
    })

    // 监听弹窗显示状态
    watch(() => props.visible, (newVisible) => {
      if (newVisible) {
        // 检查用户登录状态
        if (!userStore.isLoggedIn) {
          // 未登录，跳转到登录页面
          router.push('/login?redirect=' + encodeURIComponent(window.location.pathname))
          emit('close')
          return
        } else {
          // 已登录，只自动填充邮箱和手机号，不填充姓名
          fillUserInfo()
        }
      }
    })

    // 自动填充用户信息（只填充邮箱和手机号）
    const fillUserInfo = () => {
      if (userStore.userInfo) {
        // 不自动填充姓名
        // form.value.name = userStore.userInfo.username || ''
        form.value.email = userStore.userInfo.email || ''
        form.value.phone = userStore.userInfo.phone || ''
      }
    }



    // 处理弹窗点击（点击空白区域不关闭）
    const handleModalClick = (event) => {
      // 点击空白区域时不关闭弹窗
      // 只有点击右上角的X按钮才会关闭
    }

    // 处理关闭弹窗
    const handleClose = () => {
      emit('close')
      // 重置表单
      form.value = {
        name: '',
        email: '',
        phone: '',
        message: ''
      }
    }

    const handleSubmit = async () => {
      if (submitting.value) return
      
      submitting.value = true
      try {
        const inquiryData = {
          product_id: props.product.id,
          product_name: props.product.title,
          product_model: props.product.model,
          product_image: props.product.images && props.product.images.length > 0 ? props.product.images[0] : null,
          name: form.value.name,
          email: form.value.email,
          phone: form.value.phone,
          content: form.value.message
        }

        // 使用支持用户关联的API
        const response = await fetch('http://localhost:8000/api/inquiry/with-user', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('client_token')}`
          },
          body: JSON.stringify(inquiryData)
        })

        if (response.ok) {
          const result = await response.json()
          emit('success', result)
          handleClose()
          alert('询价提交成功！我们会尽快与您联系。')
          
          // 如果用户已登录，跳转到询价列表页面
          if (userStore.isLoggedIn) {
            router.push('/inquiries')
          }
        } else {
          const error = await response.json()
          alert(error.detail || '提交失败，请稍后重试')
        }
      } catch (error) {
        console.error('提交询价失败:', error)
        alert('提交失败，请稍后重试')
      } finally {
        submitting.value = false
      }
    }

    return {
      submitting,
      form,
      handleClose,
      handleSubmit,
      getImageUrl,
      fillUserInfo,
      handleModalClick
    }
  }
}
</script>

<style scoped>
.inquiry-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #eee;
}

.modal-header h3 {
  margin: 0;
  color: #333;
  font-size: 18px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #999;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  color: #333;
}

.modal-body {
  padding: 20px;
}

.product-info {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
  padding: 15px;
  background-color: #f8f9fa;
  border-radius: 6px;
}

.product-thumbnail {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 4px;
}

.product-details h4 {
  margin: 0 0 8px 0;
  color: #333;
  font-size: 16px;
}

.product-details p {
  margin: 0;
  color: #666;
  font-size: 14px;
}

.inquiry-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 5px;
  color: #333;
  font-weight: 500;
  font-size: 14px;
}

.form-group input,
.form-group textarea {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
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
  min-height: 80px;
}

.form-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.cancel-btn,
.submit-btn {
  flex: 1;
  padding: 12px;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.cancel-btn {
  background-color: #f3f4f6;
  color: #374151;
}

.cancel-btn:hover {
  background-color: #e5e7eb;
}

.submit-btn {
  background-color: #3b82f6;
  color: white;
}

.submit-btn:hover:not(:disabled) {
  background-color: #2563eb;
}

.submit-btn:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}

@media (max-width: 480px) {
  .modal-content {
    width: 95%;
    margin: 10px;
  }
  
  .modal-header,
  .modal-body {
    padding: 15px;
  }
  
  .product-info {
    flex-direction: column;
    text-align: center;
  }
  
  .product-thumbnail {
    width: 100px;
    height: 100px;
    margin: 0 auto;
  }
}
</style> 