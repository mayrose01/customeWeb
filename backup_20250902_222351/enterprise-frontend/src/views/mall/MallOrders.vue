<template>
  <div class="mall-orders-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <div class="orders-header">
          <h1>我的订单</h1>
          <p>查看和管理您的所有订单</p>
        </div>

        <!-- 订单筛选 -->
        <div class="orders-filter">
          <div class="filter-tabs">
            <button 
              v-for="tab in filterTabs" 
              :key="tab.value"
              class="filter-tab"
              :class="{ active: activeFilter === tab.value }"
              @click="setFilter(tab.value)"
            >
              {{ tab.label }}
            </button>
          </div>
        </div>

        <!-- 订单列表 -->
        <div class="orders-list">
          <div 
            v-for="order in filteredOrders" 
            :key="order.id"
            class="order-item"
          >
            <div class="order-header">
              <div class="order-info">
                <span class="order-number">订单号：{{ order.order_number }}</span>
                <span class="order-date">{{ formatDate(order.created_at) }}</span>
              </div>
              <div class="order-status">
                <span class="status-tag" :class="getStatusClass(order.status)">
                  {{ getStatusText(order.status) }}
                </span>
              </div>
            </div>
            
            <div class="order-products">
              <div 
                v-for="item in order.items" 
                :key="item.id"
                class="product-item"
              >
                <div class="product-image">
                  <img 
                    v-if="item.product_image" 
                    :src="getImageUrl(item.product_image)" 
                    :alt="item.product_title"
                  />
                  <div v-else class="image-placeholder">
                    <span>📦</span>
                  </div>
                </div>
                <div class="product-info">
                  <h3>{{ item.product_title }}</h3>
                  <div class="product-specs" v-if="item.specifications">
                    <span 
                      v-for="spec in item.specifications" 
                      :key="spec.name"
                      class="spec-tag"
                    >
                      {{ spec.name }}：{{ spec.value }}
                    </span>
                  </div>
                </div>
                <div class="product-price">
                  <span class="price">¥{{ parseFloat(item.price || 0).toFixed(2) }}</span>
                </div>
                <div class="product-quantity">
                  <span>x{{ item.quantity }}</span>
                </div>
              </div>
            </div>
            
            <div class="order-footer">
              <div class="order-total">
                <span>共 {{ order.total_quantity }} 件商品，总计：</span>
                <span class="total-amount">¥{{ parseFloat(order.total_amount || 0).toFixed(2) }}</span>
              </div>
              <div class="order-actions">
                <button 
                  v-if="order.status === 'pending'" 
                  class="pay-btn"
                  @click="payOrder(order.id)"
                >
                  立即支付
                </button>
                <button 
                  v-if="order.status === 'shipped'" 
                  class="confirm-btn"
                  @click="confirmDelivery(order.id)"
                >
                  确认收货
                </button>
                <button 
                  v-if="order.status === 'completed'" 
                  class="review-btn"
                  @click="reviewOrder(order.id)"
                >
                  评价订单
                </button>
                <button 
                  v-if="order.status === 'pending'" 
                  class="cancel-btn"
                  @click="cancelOrder(order.id)"
                >
                  取消订单
                </button>
                <button 
                  class="detail-btn"
                  @click="viewOrderDetail(order.id)"
                >
                  查看详情
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- 空状态 -->
        <div v-if="filteredOrders.length === 0" class="empty-orders">
          <div class="empty-icon">📋</div>
          <h3>暂无订单</h3>
          <p>快去选购心仪的商品吧！</p>
          <router-link :to="getClientPath('/mall/products')" class="start-shopping-btn">
            开始购物
          </router-link>
        </div>
      </div>
    </main>

    <ClientFooter />
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getClientPath } from '@/utils/pathUtils'
import { getImageUrl } from '@/utils/imageUtils'

export default {
  name: 'MallOrders',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    
    const orders = ref([])
    const activeFilter = ref('all')
    
    // 筛选标签
    const filterTabs = ref([
      { label: '全部', value: 'all' },
      { label: '待付款', value: 'pending' },
      { label: '待发货', value: 'paid' },
      { label: '待收货', value: 'shipped' },
      { label: '已完成', value: 'completed' },
      { label: '已取消', value: 'cancelled' }
    ])
    
    // 加载订单数据
    const loadOrders = async () => {
      try {
        // TODO: 调用API加载订单数据
        // const response = await getMallOrders()
        // orders.value = response.data
        
        // 模拟数据
        orders.value = [
          {
            id: 1,
            order_number: 'M202409020001',
            status: 'pending',
            created_at: '2024-09-02T10:00:00Z',
            total_amount: 3297,
            total_quantity: 2,
            items: [
              {
                id: 1,
                product_title: '智能手机',
                product_image: '',
                price: 2999,
                quantity: 1,
                specifications: [
                  { name: '颜色', value: '黑色' },
                  { name: '存储', value: '256GB' }
                ]
              },
              {
                id: 2,
                product_title: '无线耳机',
                product_image: '',
                price: 299,
                quantity: 1,
                specifications: [
                  { name: '颜色', value: '白色' }
                ]
              }
            ]
          },
          {
            id: 2,
            order_number: 'M202409010001',
            status: 'shipped',
            created_at: '2024-09-01T15:30:00Z',
            total_amount: 899,
            total_quantity: 1,
            items: [
              {
                id: 3,
                product_title: '智能手表',
                product_image: '',
                price: 899,
                quantity: 1,
                specifications: [
                  { name: '颜色', value: '深空灰' }
                ]
              }
            ]
          }
        ]
      } catch (error) {
        console.error('加载订单失败:', error)
        ElMessage.error('加载订单失败')
      }
    }
    
    // 筛选订单
    const filteredOrders = computed(() => {
      if (activeFilter.value === 'all') {
        return orders.value
      }
      return orders.value.filter(order => order.status === activeFilter.value)
    })
    
    // 设置筛选
    const setFilter = (filter) => {
      activeFilter.value = filter
    }
    
    // 获取状态样式类
    const getStatusClass = (status) => {
      const statusMap = {
        pending: 'status-pending',
        paid: 'status-paid',
        shipped: 'status-shipped',
        completed: 'status-completed',
        cancelled: 'status-cancelled'
      }
      return statusMap[status] || 'status-default'
    }
    
    // 获取状态文本
    const getStatusText = (status) => {
      const statusMap = {
        pending: '待付款',
        paid: '待发货',
        shipped: '待收货',
        completed: '已完成',
        cancelled: '已取消'
      }
      return statusMap[status] || '未知状态'
    }
    
    // 格式化日期
    const formatDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
    
    // 支付订单
    const payOrder = (orderId) => {
      router.push({
        path: getClientPath(`/mall/order/${orderId}`),
        query: { action: 'pay' }
      })
    }
    
    // 确认收货
    const confirmDelivery = async (orderId) => {
      try {
        await ElMessageBox.confirm('确认已收到商品？', '确认收货', {
          type: 'warning'
        })
        
        // TODO: 调用API确认收货
        // await confirmMallOrderDelivery(orderId)
        
        ElMessage.success('确认收货成功')
        loadOrders()
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('确认收货失败')
        }
      }
    }
    
    // 评价订单
    const reviewOrder = (orderId) => {
      router.push({
        path: getClientPath(`/mall/order/${orderId}`),
        query: { action: 'review' }
      })
    }
    
    // 取消订单
    const cancelOrder = async (orderId) => {
      try {
        await ElMessageBox.confirm('确定要取消这个订单吗？', '取消订单', {
          type: 'warning'
        })
        
        // TODO: 调用API取消订单
        // await cancelMallOrder(orderId)
        
        ElMessage.success('订单已取消')
        loadOrders()
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('取消订单失败')
        }
      }
    }
    
    // 查看订单详情
    const viewOrderDetail = (orderId) => {
      router.push(getClientPath(`/mall/order/${orderId}`))
    }
    
    onMounted(() => {
      loadOrders()
    })
    
    return {
      orders,
      activeFilter,
      filterTabs,
      filteredOrders,
      setFilter,
      getStatusClass,
      getStatusText,
      formatDate,
      payOrder,
      confirmDelivery,
      reviewOrder,
      cancelOrder,
      viewOrderDetail,
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
  max-width: 1000px;
  margin: 0 auto;
  padding: 0 20px;
}

.orders-header {
  text-align: center;
  margin-bottom: 40px;
}

.orders-header h1 {
  font-size: 2.5rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.orders-header p {
  color: var(--color-text-secondary);
  font-size: 1.1rem;
}

/* 订单筛选 */
.orders-filter {
  margin-bottom: 30px;
}

.filter-tabs {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  justify-content: center;
}

.filter-tab {
  padding: 10px 20px;
  border: 2px solid #e5e7eb;
  background: white;
  color: var(--color-text-secondary);
  border-radius: 25px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
}

.filter-tab:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.filter-tab.active {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
}

/* 订单列表 */
.orders-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.order-item {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  background: #f8f9fa;
  border-bottom: 1px solid #e5e7eb;
}

.order-info {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.order-number {
  font-weight: 600;
  color: var(--color-text-primary);
  font-size: 1.1rem;
}

.order-date {
  color: var(--color-text-secondary);
  font-size: 0.9rem;
}

.status-tag {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
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
  background: #c3e6cb;
  color: #155724;
}

.status-cancelled {
  background: #f8d7da;
  color: #721c24;
}

/* 订单商品 */
.order-products {
  padding: 20px 30px;
}

.product-item {
  display: grid;
  grid-template-columns: 80px 1fr 120px 100px;
  gap: 20px;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0;
}

.product-item:last-child {
  border-bottom: none;
}

.product-image {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  overflow: hidden;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  color: #999;
  font-size: 1.2rem;
}

.product-info h3 {
  font-size: 1rem;
  color: var(--color-text-primary);
  margin: 0 0 8px 0;
}

.product-specs {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
}

.spec-tag {
  background: #f0f0f0;
  color: var(--color-text-secondary);
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 0.8rem;
}

.product-price,
.product-quantity {
  text-align: center;
}

.price {
  font-size: 1.1rem;
  color: #ff4757;
  font-weight: 600;
}

/* 订单底部 */
.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  background: #f8f9fa;
  border-top: 1px solid #e5e7eb;
}

.order-total {
  font-size: 1.1rem;
  color: var(--color-text-secondary);
}

.total-amount {
  color: #ff4757;
  font-weight: 700;
  font-size: 1.2rem;
}

.order-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.pay-btn,
.confirm-btn,
.review-btn,
.cancel-btn,
.detail-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
}

.pay-btn {
  background: #ff4757;
  color: white;
}

.pay-btn:hover {
  background: #ff3742;
}

.confirm-btn {
  background: var(--color-primary);
  color: white;
}

.confirm-btn:hover {
  background: var(--color-primary-hover);
}

.review-btn {
  background: #28a745;
  color: white;
}

.review-btn:hover {
  background: #218838;
}

.cancel-btn {
  background: #6c757d;
  color: white;
}

.cancel-btn:hover {
  background: #5a6268;
}

.detail-btn {
  background: white;
  color: var(--color-primary);
  border: 1px solid var(--color-primary);
}

.detail-btn:hover {
  background: var(--color-primary);
  color: white;
}

/* 空状态 */
.empty-orders {
  text-align: center;
  padding: 100px 0;
}

.empty-icon {
  font-size: 5rem;
  margin-bottom: 20px;
}

.empty-orders h3 {
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.empty-orders p {
  color: var(--color-text-secondary);
  margin-bottom: 30px;
}

.start-shopping-btn {
  display: inline-block;
  background: var(--color-primary);
  color: white;
  padding: 15px 30px;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
  transition: all 0.3s ease;
}

.start-shopping-btn:hover {
  background: var(--color-primary-hover);
  transform: translateY(-2px);
}

@media (max-width: 768px) {
  .orders-header h1 {
    font-size: 2rem;
  }
  
  .filter-tabs {
    justify-content: stretch;
  }
  
  .filter-tab {
    flex: 1;
    text-align: center;
  }
  
  .order-header {
    flex-direction: column;
    gap: 15px;
    text-align: center;
  }
  
  .product-item {
    grid-template-columns: 1fr;
    gap: 15px;
    text-align: center;
  }
  
  .product-image {
    margin: 0 auto;
  }
  
  .order-footer {
    flex-direction: column;
    gap: 20px;
    text-align: center;
  }
  
  .order-actions {
    justify-content: center;
  }
}
</style>
