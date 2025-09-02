<template>
  <div class="consultations-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 页面标题 -->
        <div class="page-header">
          <h1>我的咨询记录</h1>
          <p>查看您提交的所有在线咨询</p>
        </div>

        <!-- 咨询列表 -->
        <div class="consultations-content">
          <div v-if="loading" class="loading-section">
            <div class="loading-spinner"></div>
            <p>正在加载咨询记录...</p>
          </div>
          
          <div v-else-if="consultations.length === 0" class="empty-state">
            <div class="empty-icon">💬</div>
            <h3>暂无咨询记录</h3>
            <p>您还没有提交过任何在线咨询</p>
            <router-link to="/contact" class="contact-btn">联系我们</router-link>
          </div>
          
          <div v-else class="consultations-list">
            <div 
              v-for="consultation in consultations" 
              :key="consultation.id" 
              class="consultation-item"
            >
              <div class="consultation-header">
                <div class="consultation-info">
                  <h3>{{ consultation.subject || '在线咨询' }}</h3>
                  <p class="consultation-date">
                    提交时间: {{ formatDate(consultation.created_at) }}
                  </p>
                </div>
                <div class="consultation-status">
                  <span class="status-badge">已提交</span>
                </div>
              </div>
              
              <div class="consultation-content">
                <div class="consultation-details">
                  <div class="detail-item">
                    <span class="label">姓名:</span>
                    <span class="value">{{ consultation.name }}</span>
                  </div>
                  <div class="detail-item">
                    <span class="label">邮箱:</span>
                    <span class="value">{{ consultation.email }}</span>
                  </div>
                  <div class="detail-item" v-if="consultation.phone">
                    <span class="label">电话:</span>
                    <span class="value">{{ consultation.phone }}</span>
                  </div>
                </div>
                
                <div class="consultation-message">
                  <h4>咨询内容:</h4>
                  <p>{{ consultation.message }}</p>
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
import axios from '@/api/axios'

const router = useRouter()
const loading = ref(true)
const consultations = ref([])
const currentPage = ref(1)
const totalPages = ref(1)

const loadConsultations = async (page = 1) => {
  try {
    loading.value = true
    const token = localStorage.getItem('client_token')
    
    if (!token) {
      router.push('/')
      return
    }

    const response = await axios.get(`/client-user/consultations?page=${page}&page_size=10`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })

    const data = response.data
    consultations.value = data.items || []
    currentPage.value = data.page || 1
    totalPages.value = data.total_pages || 1
  } catch (error) {
    console.error('加载咨询列表失败:', error)
  } finally {
    loading.value = false
  }
}

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    loadConsultations(page)
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
  loadConsultations()
})
</script>

<style scoped>
.consultations-page {
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

.contact-btn {
  display: inline-block;
  padding: 12px 24px;
  background-color: #3b82f6;
  color: white;
  text-decoration: none;
  border-radius: 6px;
  font-weight: 500;
  transition: background-color 0.2s;
}

.contact-btn:hover {
  background-color: #2563eb;
}

.consultations-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.consultation-item {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  border: 1px solid #e9ecef;
}

.consultation-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}

.consultation-info {
  flex: 1;
}

.consultation-info h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  color: #333;
  font-weight: 600;
}

.consultation-date {
  margin: 0;
  font-size: 12px;
  color: #999;
}

.consultation-status {
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

.consultation-content {
  border-top: 1px solid #e9ecef;
  padding-top: 20px;
}

.consultation-details {
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

.consultation-message h4 {
  margin: 0 0 10px 0;
  font-size: 16px;
  color: #333;
  font-weight: 600;
}

.consultation-message p {
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
  
  .consultation-header {
    flex-direction: column;
    gap: 15px;
  }
  
  .consultation-details {
    grid-template-columns: 1fr;
  }
  
  .pagination {
    flex-direction: column;
    gap: 15px;
  }
}
</style> 