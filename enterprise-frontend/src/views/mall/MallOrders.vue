<template>
  <div class="mall-orders-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 面包屑导航 -->
        <div class="breadcrumb">
          <router-link :to="getClientPath('/mall')">商城首页</router-link>
          <span class="separator">/</span>
          <span>我的订单</span>
        </div>

        <div class="orders-content" v-if="!loading">
          <div class="orders-header">
            <h1>我的订单</h1>
            <div class="order-filters">
              <button 
                class="filter-btn"
                :class="{ active: currentFilter === 'all' }"
                @click="setFilter('all')"
              >
                全部订单
              </button>
              <button 
                class="filter-btn"
                :class="{ active: currentFilter === 'pending' }"
                @click="setFilter('pending')"
              >
                待付款
              </button>
              <button 
                class="filter-btn"
                :class="{ active: currentFilter === 'paid' }"
                @click="setFilter('paid')"
              >
                已付款
              </button>
              <button 
                class="filter-btn"
                :class="{ active: currentFilter === 'shipped' }"
                @click="setFilter('shipped')"
              >
                已发货
              </button>
              <button 
                class="filter-btn"
                :class="{ active: currentFilter === 'completed' }"
                @click="setFilter('completed')"
              >
                已完成
              </button>
            </div>
          </div>

          <!-- 订单列表 -->
          <div class="orders-list" v-if="orders.length > 0">
            <div class="order-item" v-for="order in orders" :key="order.id">
              <div class="order-header">
                <div class="order-info">
                  <span class="order-no">订单号：{{ order.order_no }}</span>
                  <span class="order-time">{{ formatDate(order.created_at) }}</span>
                </div>
                <div class="order-status">
                  <span class="status-badge" :class="getStatusClass(order.status)">
                    {{ getStatusText(order.status) }}
                  </span>
                </div>
              </div>

              <div class="order-items">
                <div class="order-item-product" v-for="item in order.items" :key="item.id">
                  <div class="product-image">
                    <img 
                      v-if="item.product && item.product.images && item.product.images.length > 0"
                      :src="getImageUrl(item.product.images[0])" 
                      :alt="item.product.title"
                      @error="handleImageError"
                    />
                    <div v-else class="image-placeholder">
                      <span>📦</span>
                    </div>
                  </div>
                  
                  <div class="product-info">
                    <h3 class="product-title">{{ item.product_name }}</h3>
                    <p class="product-specs" v-if="item.sku_specifications">
                      {{ formatSpecifications(item.sku_specifications) }}
                    </p>
                    <div class="product-price">¥{{ parseFloat(item.price).toFixed(2) }}</div>
                  </div>
                  
                  <div class="product-quantity">
                    <span class="quantity-label">数量：</span>
                    <span class="quantity-value">{{ item.quantity }}</span>
                  </div>
                  
                  <div class="product-subtotal">
                    ¥{{ parseFloat(item.subtotal).toFixed(2) }}
                  </div>
                </div>
              </div>

              <div class="order-footer">
                <div class="order-total">
                  <span class="total-label">订单总额：</span>
                  <span class="total-amount">¥{{ parseFloat(order.total_amount).toFixed(2) }}</span>
                </div>
                
                <div class="order-actions">
                  <button 
                    class="action-btn secondary"
                    @click="viewOrderDetail(order)"
                  >
                    查看详情
                  </button>
                  
                  <button 
                    v-if="order.status === 'pending'"
                    class="action-btn primary"
                    @click="payOrder(order)"
                  >
                    立即付款
                  </button>
                  
                  <button 
                    v-if="order.status === 'shipped'"
                    class="action-btn success"
                    @click="confirmOrder(order)"
                  >
                    确认收货
                  </button>
                  
                  <button 
                    v-if="['pending', 'paid'].includes(order.status)"
                    class="action-btn danger"
                    @click="cancelOrder(order)"
                  >
                    取消订单
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- 空状态 -->
          <div v-else class="empty-orders">
            <div class="empty-icon">📦</div>
            <h3>暂无订单</h3>
            <p>您还没有任何订单，快去选购心仪的商品吧！</p>
            <router-link :to="getClientPath('/mall/products')" class="go-shopping-btn">
              去购物
            </router-link>
          </div>

          <!-- 分页 -->
          <div v-if="totalPages > 1" class="pagination">
            <button 
              class="page-btn"
              :disabled="currentPage <= 1"
              @click="changePage(currentPage - 1)"
            >
              上一页
            </button>
            
            <span class="page-info">
              第 {{ currentPage }} 页，共 {{ totalPages }} 页
            </span>
            
            <button 
              class="page-btn"
              :disabled="currentPage >= totalPages"
              @click="changePage(currentPage + 1)"
            >
              下一页
            </button>
          </div>
        </div>

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载订单...</p>
        </div>
      </div>
    </main>

    <ClientFooter />
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getClientPath } from '@/utils/pathUtils'
import { getImageUrl } from '@/utils/imageUtils'
import { userStore } from '@/store/user'
import { getUserOrders, cancelOrder as cancelOrderAPI, confirmOrder } from '@/api/mall_order'

export default {
  name: 'MallOrders',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    
    const loading = ref(true)
    const orders = ref([])
    const currentFilter = ref('all')
    const currentPage = ref(1)
    const pageSize = ref(10)
    const total = ref(0)
    
    // 总页数
    const totalPages = computed(() => {
      return Math.ceil(total.value / pageSize.value)
    })
    
    // 加载订单列表
    const loadOrders = async () => {
      try {
        loading.value = true
        
        if (!userStore.isLoggedIn) {
          ElMessage.warning('请先登录')
          router.push(getClientPath('/login'))
          return
        }
        
        const params = {
          page: currentPage.value,
          page_size: pageSize.value
        }
        
        if (currentFilter.value !== 'all') {
          params.status = currentFilter.value
        }
        
        const response = await getUserOrders(userStore.userInfo.id, params)
        if (response.data) {
          orders.value = response.data.items || []
          total.value = response.data.total || 0
        }
      } catch (err) {
        console.error('加载订单失败:', err)
        ElMessage.error('加载订单失败')
      } finally {
        loading.value = false
      }
    }
    
    // 设置筛选条件
    const setFilter = (filter) => {
      currentFilter.value = filter
      currentPage.value = 1
      loadOrders()
    }
    
    // 切换页面
    const changePage = (page) => {
      currentPage.value = page
      loadOrders()
    }
    
    // 查看订单详情
    const viewOrderDetail = (order) => {
      router.push(getClientPath(`/mall/order/${order.id}`))
    }
    
    // 支付订单
    const payOrder = (order) => {
      ElMessage.info('请联系客服完成付款')
    }
    
    // 确认收货
    const confirmOrder = async (order) => {
      try {
        await ElMessageBox.confirm(
          '确认已收到商品吗？',
          '确认收货',
          {
            confirmButtonText: '确认',
            cancelButtonText: '取消',
            type: 'warning',
          }
        )
        
        await confirmOrder(order.id, userStore.userInfo.id)
        ElMessage.success('确认收货成功')
        loadOrders()
      } catch (err) {
        if (err !== 'cancel') {
          ElMessage.error('确认收货失败')
        }
      }
    }
    
    // 取消订单
    const cancelOrder = async (order) => {
      try {
        await ElMessageBox.confirm(
          '确定要取消这个订单吗？',
          '取消订单',
          {
            confirmButtonText: '确认取消',
            cancelButtonText: '不取消',
            type: 'warning',
          }
        )
        
        await cancelOrderAPI(order.id, userStore.userInfo.id)
        ElMessage.success('订单已取消')
        loadOrders()
      } catch (err) {
        if (err !== 'cancel') {
          console.error('取消订单失败:', err)
          ElMessage.error('取消订单失败')
        }
      }
    }
    
    // 获取状态文本
    const getStatusText = (status) => {
      const statusMap = {
        'pending': '待付款',
        'paid': '已付款',
        'shipped': '已发货',
        'completed': '已完成',
        'cancelled': '交易关闭'
      }
      return statusMap[status] || status
    }
    
    // 获取状态样式类
    const getStatusClass = (status) => {
      const classMap = {
        'pending': 'status-pending',
        'paid': 'status-paid',
        'shipped': 'status-shipped',
        'completed': 'status-completed',
        'cancelled': 'status-cancelled'
      }
      return classMap[status] || ''
    }
    
    // 格式化日期
    const formatDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleString('zh-CN')
    }
    
    // 格式化规格信息
    const formatSpecifications = (specs) => {
      if (!specs || typeof specs !== 'object') return ''
      return Object.entries(specs).map(([key, value]) => `${key}: ${value}`).join(', ')
    }
    
    // 图片处理
    const handleImageError = (event) => {
      event.target.style.display = 'none'
      const placeholder = event.target.parentElement.querySelector('.image-placeholder')
      if (placeholder) {
        placeholder.style.display = 'flex'
      }
    }
    
    onMounted(() => {
      loadOrders()
    })
    
    return {
      loading,
      orders,
      currentFilter,
      currentPage,
      totalPages,
      setFilter,
      changePage,
      viewOrderDetail,
      payOrder,
      confirmOrder,
      cancelOrder,
      getStatusText,
      getStatusClass,
      formatDate,
      formatSpecifications,
      handleImageError,
      getClientPath,
      getImageUrl
    }
  }
}
</script>

<style scoped>
.mall-orders-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  padding-top: 120px;
  padding-bottom: 60px;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.breadcrumb {
  margin-bottom: 30px;
  font-size: 18px;
  color: var(--color-text-muted);
  white-space: nowrap;
  overflow-x: auto;
  overflow-y: hidden;
  padding: 10px 0;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.breadcrumb::-webkit-scrollbar {
  display: none;
}

.breadcrumb a {
  color: var(--color-primary);
  text-decoration: none;
}

.breadcrumb a:hover {
  text-decoration: underline;
}

.breadcrumb .separator {
  margin: 0 8px;
}

.orders-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #f0f0f0;
}

.orders-header h1 {
  font-size: 2rem;
  color: var(--color-text-primary);
  margin: 0;
}

.order-filters {
  display: flex;
  gap: 10px;
}

.filter-btn {
  padding: 8px 16px;
  border: 1px solid #e5e7eb;
  background: white;
  color: var(--color-text-secondary);
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.filter-btn:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.filter-btn.active {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
}

.orders-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.order-item {
  background: white;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #f0f0f0;
}

.order-info {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.order-no {
  font-weight: 600;
  color: var(--color-text-primary);
}

.order-time {
  font-size: 0.9rem;
  color: var(--color-text-secondary);
}

.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 500;
}

.status-pending {
  background: #fff3cd;
  color: #856404;
}

.status-paid {
  background: #d1ecf1;
  color: #0c5460;
}

.status-shipped {
  background: #d4edda;
  color: #155724;
}

.status-completed {
  background: #e2e3e5;
  color: #383d41;
}

.status-cancelled {
  background: #f8d7da;
  color: #721c24;
}

.order-items {
  margin-bottom: 20px;
}

.order-item-product {
  display: grid;
  grid-template-columns: 80px 1fr 100px 120px;
  gap: 20px;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid #f8f9fa;
}

.order-item-product:last-child {
  border-bottom: none;
}

.product-image {
  width: 60px;
  height: 60px;
  border-radius: 6px;
  overflow: hidden;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;
  font-size: 1.2rem;
}

.product-info {
  min-width: 0;
}

.product-title {
  margin: 0 0 8px 0;
  font-size: 1rem;
  color: var(--color-text-primary);
}

.product-specs {
  margin: 0 0 8px 0;
  font-size: 0.9rem;
  color: var(--color-text-secondary);
}

.product-price {
  font-size: 1rem;
  color: #ff4757;
  font-weight: 600;
}

.product-quantity {
  text-align: center;
}

.quantity-label {
  color: var(--color-text-secondary);
}

.quantity-value {
  font-weight: 600;
  color: var(--color-text-primary);
}

.product-subtotal {
  text-align: right;
  font-size: 1.1rem;
  color: #ff4757;
  font-weight: 600;
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 1px solid #f0f0f0;
}

.order-total {
  display: flex;
  align-items: center;
  gap: 10px;
}

.total-label {
  color: var(--color-text-secondary);
}

.total-amount {
  font-size: 1.2rem;
  color: #ff4757;
  font-weight: 700;
}

.order-actions {
  display: flex;
  gap: 10px;
}

.action-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s;
}

.action-btn.primary {
  background: #ff4757;
  color: white;
}

.action-btn.primary:hover {
  background: #ff3742;
}

.action-btn.secondary {
  background: #f8f9fa;
  color: var(--color-text-secondary);
  border: 1px solid #e5e7eb;
}

.action-btn.secondary:hover {
  background: #e9ecef;
}

.action-btn.success {
  background: #28a745;
  color: white;
}

.action-btn.success:hover {
  background: #218838;
}

.action-btn.danger {
  background: #dc3545;
  color: white;
}

.action-btn.danger:hover {
  background: #c82333;
}

.empty-orders {
  text-align: center;
  padding: 80px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 20px;
}

.empty-orders h3 {
  color: var(--color-text-primary);
  margin-bottom: 10px;
}

.empty-orders p {
  color: var(--color-text-secondary);
  margin-bottom: 30px;
}

.go-shopping-btn {
  display: inline-block;
  padding: 12px 24px;
  background: var(--color-primary);
  color: white;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 600;
  transition: background-color 0.3s;
}

.go-shopping-btn:hover {
  background: var(--color-primary-hover);
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  margin-top: 40px;
}

.page-btn {
  padding: 8px 16px;
  border: 1px solid #e5e7eb;
  background: white;
  color: var(--color-text-secondary);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s;
}

.page-btn:hover:not(:disabled) {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  color: var(--color-text-secondary);
  font-size: 0.9rem;
}

.loading-section {
  text-align: center;
  padding: 100px 0;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 5px solid #e5e7eb;
  border-top: 5px solid var(--color-primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .orders-header {
    flex-direction: column;
    gap: 20px;
    align-items: stretch;
  }
  
  .order-filters {
    justify-content: center;
    flex-wrap: wrap;
  }
  
  .order-item-product {
    grid-template-columns: 1fr;
    gap: 15px;
    text-align: center;
  }
  
  .order-footer {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }
  
  .order-actions {
    justify-content: center;
    flex-wrap: wrap;
  }
}
</style>