<template>
  <div class="inquiries-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 页面标题 -->
        <div class="page-header">
          <h1>我的询价记录</h1>
          <p>查看您提交的所有产品询价</p>
        </div>

        <!-- 询价列表 -->
        <div class="inquiries-content">
          <div v-if="loading" class="loading-section">
            <div class="loading-spinner"></div>
            <p>正在加载询价记录...</p>
          </div>
          
          <div v-else-if="inquiries.length === 0" class="empty-state">
            <div class="empty-icon">📋</div>
            <h3>暂无询价记录</h3>
            <p>您还没有提交过任何产品询价</p>
            <router-link to="/all-products" class="browse-btn">浏览产品</router-link>
          </div>
          
          <div v-else class="inquiries-list">
            <div 
              v-for="inquiry in inquiries" 
              :key="inquiry.id" 
              class="inquiry-item"
            >
              <div class="inquiry-header">
                <div class="product-info">
                  <img 
                    v-if="inquiry.product_image" 
                    :src="getImageUrl(inquiry.product_image)" 
                    :alt="inquiry.product_name"
                    class="product-image"
                  />
                  <div class="product-details">
                    <h3>{{ inquiry.product_title }}</h3>
                    <p v-if="inquiry.product_model" class="product-model">
                      型号: {{ inquiry.product_model }}
                    </p>
                    <p class="inquiry-date">
                      提交时间: {{ formatDate(inquiry.created_at) }}
                    </p>
                  </div>
                </div>
                <div class="inquiry-status">
                  <span class="status-badge">已提交</span>
                </div>
              </div>
              
              <div class="inquiry-content">
                <div class="inquiry-details">
                  <div class="detail-item">
                    <span class="label">姓名:</span>
                    <span class="value">{{ inquiry.customer_name }}</span>
                  </div>
                  <div class="detail-item">
                    <span class="label">邮箱:</span>
                    <span class="value">{{ inquiry.customer_email }}</span>
                  </div>
                  <div class="detail-item" v-if="inquiry.customer_phone">
                    <span class="label">电话:</span>
                    <span class="value">{{ inquiry.customer_phone }}</span>
                  </div>
                </div>
                
                <div class="inquiry-message">
                  <h4>询价内容:</h4>
                  <p>{{ inquiry.inquiry_content }}</p>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 分页 -->
          <div v-if="totalPages > 1" class="pagination">
            <button 
              @click="changePage(currentPage - 1)" 
              :disabled="currentPage === 1"
              class="page-btn"
            >
              上一页
            </button>
            
            <span class="page-info">
              第 {{ currentPage }} 页，共 {{ totalPages }} 页
            </span>
            
            <button 
              @click="changePage(currentPage + 1)" 
              :disabled="currentPage === totalPages"
              class="page-btn"
            >
              下一页
            </button>
          </div>
        </div>
      </div>
    </main>
    
    <ClientFooter />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { userStore } from '@/store/user'
import { getImageUrl } from '@/utils/imageUtils'
import axios from '@/api/axios'

const router = useRouter()
const loading = ref(true)
const inquiries = ref([])
const currentPage = ref(1)
const totalPages = ref(1)

const loadInquiries = async (page = 1) => {
  try {
    loading.value = true
    const token = localStorage.getItem('client_token')
    
    if (!token) {
      router.push('/')
      return
    }

    const response = await axios.get(`/client-user/inquiries?page=${page}&page_size=10`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })

    const data = response.data
    inquiries.value = data.items || []
    currentPage.value = data.page || 1
    totalPages.value = data.total_pages || 1
  } catch (error) {
    console.error('加载询价列表失败:', error)
  } finally {
    loading.value = false
  }
}

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    loadInquiries(page)
  }
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  if (!userStore.isLoggedIn) {
    router.push('/')
    return
  }
  loadInquiries()
})
</script>

<style scoped>
.inquiries-page {
  min-height: 100vh;
  background: #f8f9fa;
  padding-top: 80px;
}

.main-content {
  padding: 40px 0;
  min-height: calc(100vh - 80px - 200px);
}

.container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 0 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h1 {
  color: #333;
  font-size: 32px;
  font-weight: 600;
  margin-bottom: 10px;
}

.page-header p {
  color: #666;
  font-size: 16px;
}

.loading-section {
  text-align: center;
  padding: 60px 0;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e5e7eb;
  border-top: 4px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #666;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
}

.empty-state h3 {
  color: #333;
  font-size: 24px;
  margin-bottom: 10px;
}

.empty-state p {
  color: #666;
  font-size: 16px;
  margin-bottom: 20px;
}

.browse-btn {
  display: inline-block;
  padding: 12px 24px;
  background-color: #3b82f6;
  color: white;
  text-decoration: none;
  border-radius: 6px;
  font-weight: 500;
  transition: background-color 0.2s;
}

.browse-btn:hover {
  background-color: #2563eb;
}

.inquiries-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.inquiry-item {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  border: 1px solid #e9ecef;
}

.inquiry-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}

.product-info {
  display: flex;
  gap: 15px;
  align-items: center;
  flex: 1;
}

.product-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #e9ecef;
}

.product-details h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  color: #333;
  font-weight: 600;
}

.product-model {
  margin: 0 0 5px 0;
  font-size: 14px;
  color: #666;
}

.inquiry-date {
  margin: 0;
  font-size: 12px;
  color: #999;
}

.inquiry-status {
  flex-shrink: 0;
}

.status-badge {
  background: #10b981;
  color: white;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.inquiry-content {
  border-top: 1px solid #e9ecef;
  padding-top: 20px;
}

.inquiry-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
  margin-bottom: 20px;
}

.detail-item {
  display: flex;
  gap: 8px;
}

.detail-item .label {
  font-weight: 500;
  color: #666;
  min-width: 60px;
}

.detail-item .value {
  color: #333;
}

.inquiry-message h4 {
  margin: 0 0 10px 0;
  font-size: 16px;
  color: #333;
  font-weight: 600;
}

.inquiry-message p {
  margin: 0;
  line-height: 1.6;
  color: #666;
  white-space: pre-wrap;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  margin-top: 40px;
  padding: 20px 0;
}

.page-btn {
  padding: 8px 16px;
  border: 1px solid #ddd;
  background: white;
  color: #333;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.page-btn:hover:not(:disabled) {
  background: #f8f9fa;
  border-color: #3b82f6;
  color: #3b82f6;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  color: #666;
  font-size: 14px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 15px;
  }
  
  .page-header h1 {
    font-size: 24px;
  }
  
  .inquiry-header {
    flex-direction: column;
    gap: 15px;
  }
  
  .product-info {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .product-image {
    width: 60px;
    height: 60px;
  }
  
  .inquiry-details {
    grid-template-columns: 1fr;
  }
  
  .pagination {
    flex-direction: column;
    gap: 15px;
  }
}
</style> 