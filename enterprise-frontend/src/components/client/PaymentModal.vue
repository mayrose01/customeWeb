<template>
  <el-dialog
    title="订单支付"
    :visible="visible"
    width="500px"
    @close="handleClose"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <div class="payment-content">
      <!-- 订单信息 -->
      <div class="order-info">
        <h3>订单信息</h3>
        <div class="info-item">
          <span class="label">订单号:</span>
          <span class="value">{{ order?.order_no }}</span>
        </div>
        <div class="info-item">
          <span class="label">支付金额:</span>
          <span class="value amount">¥{{ order?.total_amount }}</span>
        </div>
        <div class="info-item">
          <span class="label">支付方式:</span>
          <span class="value">{{ getPaymentMethodName() }}</span>
        </div>
      </div>

      <!-- 支付二维码 -->
      <div class="payment-qr" v-if="!paymentSuccess">
        <div class="qr-title">
          <i :class="getPaymentIcon()"></i>
          {{ getPaymentMethodName() }}
        </div>
        
        <div class="qr-code-container">
          <div class="qr-code" v-if="qrCodeUrl">
            <img :src="qrCodeUrl" alt="支付二维码" />
          </div>
          <div class="qr-placeholder" v-else>
            <div class="loading-spinner"></div>
            <p>正在生成支付二维码...</p>
          </div>
        </div>
        
        <div class="payment-tips">
          <p>请使用{{ getPaymentMethodName() }}扫描二维码完成支付</p>
          <p class="warning">支付完成后请勿关闭此页面</p>
        </div>
        <div class="test-actions">
          <el-button size="small" @click="mockPaySuccess">模拟支付成功</el-button>
          <el-button size="small" @click="mockPayFailed">模拟支付失败</el-button>
        </div>
      </div>

      <!-- 支付成功 -->
      <div class="payment-success" v-else>
        <div class="success-icon">✅</div>
        <h3>支付成功！</h3>
        <p>您的订单已支付成功，我们将尽快为您发货</p>
        <div class="success-actions">
          <el-button type="primary" @click="viewOrder">
            查看订单
          </el-button>
          <el-button @click="continueShopping">
            继续购物
          </el-button>
        </div>
      </div>

      <!-- 支付状态检查 -->
      <div class="payment-status" v-if="!paymentSuccess">
        <div class="status-info">
          <span>支付状态: {{ paymentStatusText }}</span>
          <el-button 
            type="text" 
            @click="checkPaymentStatus"
            :loading="checkingStatus"
            size="small"
          >
            刷新状态
          </el-button>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer" v-if="!paymentSuccess">
        <el-button @click="handleClose" :disabled="checkingStatus">
          取消支付
        </el-button>
        <el-button type="primary" @click="checkPaymentStatus" :loading="checkingStatus">
          检查支付状态
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script>
import { ref, computed, watch, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { checkPaymentStatus as checkPaymentStatusAPI } from '@/api/order'
import request from '@/api/axios'

export default {
  name: 'PaymentModal',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    order: {
      type: Object,
      default: null
    },
    paymentMethod: {
      type: String,
      default: 'wechat'
    }
  },
  emits: ['close', 'success'],
  setup(props, { emit }) {
    const router = useRouter()
    
    // 响应式数据
    const paymentSuccess = ref(false)
    const qrCodeUrl = ref('')
    const paymentPageUrl = ref('')
    const paymentStatus = ref('pending') // pending, paid, failed
    const checkingStatus = ref(false)
    
    // 定时器
    let statusCheckTimer = null
    
    // 获取支付方式名称
    const getPaymentMethodName = () => {
      return props.paymentMethod === 'wechat' ? '微信支付' : '支付宝'
    }
    
    // 获取支付方式图标
    const getPaymentIcon = () => {
      return props.paymentMethod === 'wechat' ? 'icon-wechat' : 'icon-alipay'
    }
    
    // 获取支付状态文本
    const paymentStatusText = computed(() => {
      switch (paymentStatus.value) {
        case 'pending':
          return '等待支付'
        case 'paid':
          return '支付成功'
        case 'failed':
          return '支付失败'
        default:
          return '未知状态'
      }
    })
    
    // 生成支付二维码
    const generateQRCode = async () => {
      try {
        // 调用后端支付接口，获取支付链接或二维码
        if (!props.order?.id) return
        const payRes = await request({
          url: `/order/${props.order.id}/pay`,
          method: 'post',
          params: { payment_method: props.paymentMethod }
        })
        paymentPageUrl.value = payRes.data.payment_url || ''
        if (paymentPageUrl.value) {
          qrCodeUrl.value = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(paymentPageUrl.value)}`
        }
      } catch (error) {
        console.error('生成支付二维码失败:', error)
        ElMessage.error('生成支付二维码失败')
      }
    }
    
    // 检查支付状态
    const checkPaymentStatus = async () => {
      if (!props.order?.id) return
      
      try {
        checkingStatus.value = true
        
        // 调用后端API检查支付状态
        const response = await checkPaymentStatusAPI(props.order.id)
        const status = response.data.payment_status
        
        if (status === 'paid') {
          paymentSuccess.value = true
          paymentStatus.value = 'paid'
          ElMessage.success('支付成功！')
          emit('success')
          
          // 清除定时器
          if (statusCheckTimer) {
            clearInterval(statusCheckTimer)
            statusCheckTimer = null
          }
        } else if (status === 'failed') {
          paymentStatus.value = 'failed'
          ElMessage.error('支付失败，请重试')
        }
        
      } catch (error) {
        console.error('检查支付状态失败:', error)
        ElMessage.error('检查支付状态失败')
      } finally {
        checkingStatus.value = false
      }
    }
    
    // 查看订单
    const viewOrder = () => {
      router.push(`/orders/${props.order.id}`)
      handleClose()
    }
    
    // 继续购物
    const continueShopping = () => {
      router.push('/categories')
      handleClose()
    }
    
    // 关闭弹窗
    const handleClose = () => {
      // 清除定时器
      if (statusCheckTimer) {
        clearInterval(statusCheckTimer)
        statusCheckTimer = null
      }
      emit('close')
    }
    
    // 开始定时检查支付状态
    const startStatusCheck = () => {
      // 每3秒检查一次支付状态
      statusCheckTimer = setInterval(() => {
        checkPaymentStatus()
      }, 3000)
    }
    
    // 监听弹窗显示状态
    watch(() => props.visible, (newVal) => {
      if (newVal && props.order) {
        // 弹窗显示时，生成二维码并开始检查状态
        generateQRCode()
        startStatusCheck()
      } else {
        // 弹窗关闭时，清除定时器
        if (statusCheckTimer) {
          clearInterval(statusCheckTimer)
          statusCheckTimer = null
        }
      }
    })
    
    // 组件卸载时清理定时器
    onUnmounted(() => {
      if (statusCheckTimer) {
        clearInterval(statusCheckTimer)
      }
    })
    
    const mockPaySuccess = async () => {
      if (!props.order?.id) return
      try {
        await request({ url: `/order/${props.order.id}/payment-callback`, method: 'get', params: { payment_status: 'paid' } })
        await checkPaymentStatus()
      } catch (e) {
        ElMessage.error('模拟支付失败')
      }
    }
    const mockPayFailed = async () => {
      if (!props.order?.id) return
      try {
        await request({ url: `/order/${props.order.id}/payment-callback`, method: 'get', params: { payment_status: 'failed' } })
        await checkPaymentStatus()
      } catch (e) {
        ElMessage.error('模拟支付失败')
      }
    }

    return {
      paymentSuccess,
      qrCodeUrl,
      paymentPageUrl,
      paymentStatus,
      checkingStatus,
      paymentStatusText,
      getPaymentMethodName,
      getPaymentIcon,
      checkPaymentStatus,
      mockPaySuccess,
      mockPayFailed,
      viewOrder,
      continueShopping,
      handleClose
    }
  }
}
</script>

<style scoped>
.payment-content {
  text-align: center;
}

/* 订单信息 */
.order-info {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 30px;
  text-align: left;
}

.order-info h3 {
  margin: 0 0 15px 0;
  color: var(--color-text-primary);
  font-size: 1.2rem;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.info-item:last-child {
  margin-bottom: 0;
}

.info-item .label {
  color: var(--color-text-muted);
  font-size: 14px;
}

.info-item .value {
  color: var(--color-text-primary);
  font-weight: 500;
}

.info-item .amount {
  color: var(--color-primary);
  font-size: 1.2rem;
  font-weight: 600;
}

/* 支付二维码 */
.payment-qr {
  margin-bottom: 30px;
}

.qr-title {
  font-size: 1.3rem;
  color: var(--color-text-primary);
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.qr-title i {
  font-size: 1.5rem;
}

.qr-code-container {
  margin-bottom: 20px;
}

.qr-code {
  display: inline-block;
  padding: 20px;
  background: white;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
}

.qr-code img {
  width: 200px;
  height: 200px;
  display: block;
}

.qr-placeholder {
  padding: 40px;
  color: var(--color-text-muted);
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e5e7eb;
  border-top: 4px solid var(--color-primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.payment-tips {
  color: var(--color-text-secondary);
  font-size: 14px;
}

.payment-tips p {
  margin: 5px 0;
}

.payment-tips .warning {
  color: #f56c6c;
  font-weight: 500;
}

/* 支付成功 */
.payment-success {
  padding: 40px 20px;
}

.success-icon {
  font-size: 4rem;
  margin-bottom: 20px;
}

.payment-success h3 {
  color: #67c23a;
  margin-bottom: 15px;
  font-size: 1.5rem;
}

.payment-success p {
  color: var(--color-text-secondary);
  margin-bottom: 30px;
}

.success-actions {
  display: flex;
  gap: 15px;
  justify-content: center;
}

/* 支付状态 */
.payment-status {
  border-top: 1px solid #e5e7eb;
  padding-top: 20px;
  margin-top: 20px;
}

.status-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: var(--color-text-secondary);
  font-size: 14px;
}

/* 图标样式 */
.icon-wechat::before {
  content: '💬';
}

.icon-alipay::before {
  content: '💰';
}

/* 响应式设计 */
@media (max-width: 768px) {
  .qr-code img {
    width: 150px;
    height: 150px;
  }
  
  .success-actions {
    flex-direction: column;
    gap: 10px;
  }
  
  .status-info {
    flex-direction: column;
    gap: 10px;
    text-align: center;
  }
}
</style> 