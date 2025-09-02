<template>
  <div class="mall-order-detail-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <div class="order-detail-header">
          <h1>订单详情</h1>
          <p>订单号：{{ order.order_number }}</p>
        </div>

        <div class="order-detail-content">
          <!-- 订单状态 -->
          <div class="order-status-section">
            <h2>订单状态</h2>
            <div class="status-timeline">
              <div 
                v-for="(step, index) in statusSteps" 
                :key="index"
                class="status-step"
                :class="{ 
                  'completed': index <= currentStepIndex,
                  'current': index === currentStepIndex
                }"
              >
                <div class="step-icon">{{ step.icon }}</div>
                <div class="step-info">
                  <div class="step-title">{{ step.title }}</div>
                  <div class="step-time" v-if="step.time">{{ step.time }}</div>
                </div>
              </div>
            </div>
          </div>

          <!-- 收货信息 -->
          <div class="delivery-section">
            <h2>收货信息</h2>
            <div class="delivery-info">
              <div class="contact-info">
                <span class="name">{{ order.delivery?.name }}</span>
                <span class="phone">{{ order.delivery?.phone }}</span>
              </div>
              <div class="address">
                {{ order.delivery?.address }}
              </div>
            </div>
          </div>

          <!-- 商品信息 -->
          <div class="products-section">
            <h2>商品信息</h2>
            <div class="products-list">
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
                <div class="product-total">
                  <span class="total">¥{{ (parseFloat(item.price || 0) * item.quantity).toFixed(2) }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 订单信息 -->
          <div class="order-info-section">
            <h2>订单信息</h2>
            <div class="order-info-grid">
              <div class="info-item">
                <span class="label">订单号：</span>
                <span class="value">{{ order.order_number }}</span>
              </div>
              <div class="info-item">
                <span class="label">下单时间：</span>
                <span class="value">{{ formatDate(order.created_at) }}</span>
              </div>
              <div class="info-item">
                <span class="label">支付方式：</span>
                <span class="value">{{ getPaymentMethodText(order.payment_method) }}</span>
              </div>
              <div class="info-item">
                <span class="label">订单备注：</span>
                <span class="value">{{ order.remark || '无' }}</span>
              </div>
            </div>
          </div>

          <!-- 费用明细 -->
          <div class="cost-section">
            <h2>费用明细</h2>
            <div class="cost-breakdown">
              <div class="cost-item">
                <span>商品总价：</span>
                <span class="amount">¥{{ totalAmount.toFixed(2) }}</span>
              </div>
              <div class="cost-item">
                <span>运费：</span>
                <span class="amount">¥{{ shippingFee.toFixed(2) }}</span>
              </div>
              <div class="cost-item total">
                <span>应付总额：</span>
                <span class="final-amount">¥{{ finalAmount.toFixed(2) }}</span>
              </div>
            </div>
          </div>

          <!-- 操作按钮 -->
          <div class="actions-section">
            <div class="action-buttons">
              <button 
                v-if="order.status === 'pending'" 
                class="pay-btn"
                @click="payOrder"
              >
                立即支付
              </button>
              <button 
                v-if="order.status === 'shipped'" 
                class="confirm-btn"
                @click="confirmDelivery"
              >
                确认收货
              </button>
              <button 
                v-if="order.status === 'completed'" 
                class="review-btn"
                @click="reviewOrder"
              >
                评价订单
              </button>
              <button 
                v-if="order.status === 'pending'" 
                class="cancel-btn"
                @click="cancelOrder"
              >
                取消订单
              </button>
              <button class="back-btn" @click="goBack">
                返回订单列表
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <ClientFooter />
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getClientPath } from '@/utils/pathUtils'
import { getImageUrl } from '@/utils/imageUtils'

export default {
  name: 'MallOrderDetail',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    const order = ref({})
    const loading = ref(true)
    
    // 状态步骤
    const statusSteps = ref([
      { icon: '📝', title: '订单创建', time: '' },
      { icon: '💳', title: '等待支付', time: '' },
      { icon: '📦', title: '商品发货', time: '' },
      { icon: '🚚', title: '运输中', time: '' },
      { icon: '✅', title: '订单完成', time: '' }
    ])
    
    // 加载订单详情
    const loadOrderDetail = async () => {
      try {
        loading.value = true
        // TODO: 调用API加载订单详情
        // const response = await getMallOrderDetail(route.params.id)
        // order.value = response.data
        
        // 模拟数据
        order.value = {
          id: route.params.id,
          order_number: 'M202409020001',
          status: 'pending',
          created_at: '2024-09-02T10:00:00Z',
          payment_method: 'wechat',
          remark: '请尽快发货',
          total_amount: 3297,
          shipping_fee: 0,
          delivery: {
            name: '张三',
            phone: '13800138000',
            address: '广东省深圳市南山区科技园路123号'
          },
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
        }
        
        // 设置状态时间
        updateStatusTimeline()
      } catch (error) {
        console.error('加载订单详情失败:', error)
        ElMessage.error('加载订单详情失败')
      } finally {
        loading.value = false
      }
    }
    
    // 更新状态时间线
    const updateStatusTimeline = () => {
      const now = new Date()
      const orderTime = new Date(order.value.created_at)
      
      statusSteps.value[0].time = formatDate(orderTime)
      
      if (order.value.status === 'pending') {
        statusSteps.value[1].time = formatDate(orderTime)
      } else if (order.value.status === 'paid') {
        statusSteps.value[1].time = formatDate(orderTime)
        statusSteps.value[2].time = formatDate(new Date(orderTime.getTime() + 24 * 60 * 60 * 1000))
      } else if (order.value.status === 'shipped') {
        statusSteps.value[1].time = formatDate(orderTime)
        statusSteps.value[2].time = formatDate(new Date(orderTime.getTime() + 24 * 60 * 60 * 1000))
        statusSteps.value[3].time = formatDate(new Date(orderTime.getTime() + 48 * 60 * 60 * 1000))
      } else if (order.value.status === 'completed') {
        statusSteps.value[1].time = formatDate(orderTime)
        statusSteps.value[2].time = formatDate(new Date(orderTime.getTime() + 24 * 60 * 60 * 1000))
        statusSteps.value[3].time = formatDate(new Date(orderTime.getTime() + 48 * 60 * 60 * 1000))
        statusSteps.value[4].time = formatDate(new Date(orderTime.getTime() + 72 * 60 * 60 * 1000))
      }
    }
    
    // 计算属性
    const currentStepIndex = computed(() => {
      const statusMap = {
        pending: 1,
        paid: 2,
        shipped: 3,
        completed: 4
      }
      return statusMap[order.value.status] || 0
    })
    
    const totalAmount = computed(() => {
      return order.value.total_amount || 0
    })
    
    const shippingFee = computed(() => {
      return order.value.shipping_fee || 0
    })
    
    const finalAmount = computed(() => {
      return totalAmount.value + shippingFee.value
    })
    
    // 格式化日期
    const formatDate = (date) => {
      if (!date) return ''
      const d = new Date(date)
      return d.toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
    
    // 获取支付方式文本
    const getPaymentMethodText = (method) => {
      const methodMap = {
        wechat: '微信支付',
        alipay: '支付宝'
      }
      return methodMap[method] || '未知'
    }
    
    // 支付订单
    const payOrder = () => {
      router.push({
        path: getClientPath(`/mall/order/${order.value.id}`),
        query: { action: 'pay' }
      })
    }
    
    // 确认收货
    const confirmDelivery = async () => {
      try {
        await ElMessageBox.confirm('确认已收到商品？', '确认收货', {
          type: 'warning'
        })
        
        // TODO: 调用API确认收货
        // await confirmMallOrderDelivery(order.value.id)
        
        ElMessage.success('确认收货成功')
        loadOrderDetail()
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('确认收货失败')
        }
      }
    }
    
    // 评价订单
    const reviewOrder = () => {
      router.push({
        path: getClientPath(`/mall/order/${order.value.id}`),
        query: { action: 'review' }
      })
    }
    
    // 取消订单
    const cancelOrder = async () => {
      try {
        await ElMessageBox.confirm('确定要取消这个订单吗？', '取消订单', {
          type: 'warning'
        })
        
        // TODO: 调用API取消订单
        // await cancelMallOrder(order.value.id)
        
        ElMessage.success('订单已取消')
        router.push(getClientPath('/mall/orders'))
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('取消订单失败')
        }
      }
    }
    
    // 返回订单列表
    const goBack = () => {
      router.push(getClientPath('/mall/orders'))
    }
    
    onMounted(() => {
      loadOrderDetail()
    })
    
    return {
      order,
      loading,
      statusSteps,
      currentStepIndex,
      totalAmount,
      shippingFee,
      finalAmount,
      formatDate,
      getPaymentMethodText,
      payOrder,
      confirmDelivery,
      reviewOrder,
      cancelOrder,
      goBack,
      getClientPath,
      getImageUrl
    }
  }
}
</script>

<style scoped>
.mall-order-detail-page {
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

.order-detail-header {
  text-align: center;
  margin-bottom: 40px;
}

.order-detail-header h1 {
  font-size: 2.5rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.order-detail-header p {
  color: var(--color-text-secondary);
  font-size: 1.1rem;
}

.order-detail-content {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.order-status-section,
.delivery-section,
.products-section,
.order-info-section,
.cost-section {
  background: white;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.order-status-section h2,
.delivery-section h2,
.products-section h2,
.order-info-section h2,
.cost-section h2 {
  font-size: 1.5rem;
  color: var(--color-text-primary);
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;
}

/* 订单状态时间线 */
.status-timeline {
  display: flex;
  justify-content: space-between;
  position: relative;
  margin-top: 30px;
}

.status-timeline::before {
  content: '';
  position: absolute;
  top: 25px;
  left: 0;
  right: 0;
  height: 2px;
  background: #e5e7eb;
  z-index: 1;
}

.status-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  position: relative;
  z-index: 2;
  flex: 1;
}

.step-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  transition: all 0.3s ease;
}

.status-step.completed .step-icon {
  background: var(--color-primary);
  color: white;
}

.status-step.current .step-icon {
  background: var(--color-primary);
  color: white;
  transform: scale(1.1);
}

.step-info {
  text-align: center;
}

.step-title {
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: 5px;
}

.step-time {
  font-size: 0.9rem;
  color: var(--color-text-secondary);
}

/* 收货信息 */
.delivery-info {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.contact-info {
  display: flex;
  gap: 20px;
}

.contact-info .name {
  font-weight: 600;
  color: var(--color-text-primary);
}

.contact-info .phone {
  color: var(--color-text-secondary);
}

.address {
  color: var(--color-text-secondary);
  line-height: 1.5;
}

/* 商品信息 */
.products-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.product-item {
  display: grid;
  grid-template-columns: 80px 1fr 120px 100px 120px;
  gap: 20px;
  align-items: center;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 12px;
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
  background: #e5e7eb;
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
  background: #e5e7eb;
  color: var(--color-text-secondary);
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 0.8rem;
}

.product-price,
.product-quantity,
.product-total {
  text-align: center;
}

.price {
  font-size: 1.1rem;
  color: #ff4757;
  font-weight: 600;
}

.total {
  font-size: 1.2rem;
  color: #ff4757;
  font-weight: 700;
}

/* 订单信息 */
.order-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
}

.info-item .label {
  color: var(--color-text-secondary);
  font-weight: 500;
}

.info-item .value {
  color: var(--color-text-primary);
  font-weight: 600;
}

/* 费用明细 */
.cost-breakdown {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.cost-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0;
}

.cost-item:last-child {
  border-bottom: none;
}

.cost-item.total {
  font-size: 1.2rem;
  font-weight: 700;
  color: var(--color-text-primary);
  border-top: 2px solid #f0f0f0;
  padding-top: 20px;
  margin-top: 10px;
}

.amount {
  color: var(--color-text-secondary);
}

.final-amount {
  color: #ff4757;
  font-size: 1.5rem;
}

/* 操作按钮 */
.actions-section {
  text-align: center;
}

.action-buttons {
  display: flex;
  gap: 15px;
  justify-content: center;
  flex-wrap: wrap;
}

.pay-btn,
.confirm-btn,
.review-btn,
.cancel-btn,
.back-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.pay-btn {
  background: #ff4757;
  color: white;
}

.pay-btn:hover {
  background: #ff3742;
  transform: translateY(-2px);
}

.confirm-btn {
  background: var(--color-primary);
  color: white;
}

.confirm-btn:hover {
  background: var(--color-primary-hover);
  transform: translateY(-2px);
}

.review-btn {
  background: #28a745;
  color: white;
}

.review-btn:hover {
  background: #218838;
  transform: translateY(-2px);
}

.cancel-btn {
  background: #6c757d;
  color: white;
}

.cancel-btn:hover {
  background: #5a6268;
  transform: translateY(-2px);
}

.back-btn {
  background: white;
  color: var(--color-primary);
  border: 2px solid var(--color-primary);
}

.back-btn:hover {
  background: var(--color-primary);
  color: white;
  transform: translateY(-2px);
}

@media (max-width: 768px) {
  .order-detail-header h1 {
    font-size: 2rem;
  }
  
  .status-timeline {
    flex-direction: column;
    gap: 20px;
  }
  
  .status-timeline::before {
    display: none;
  }
  
  .product-item {
    grid-template-columns: 1fr;
    gap: 15px;
    text-align: center;
  }
  
  .product-image {
    margin: 0 auto;
  }
  
  .order-info-grid {
    grid-template-columns: 1fr;
  }
  
  .action-buttons {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
