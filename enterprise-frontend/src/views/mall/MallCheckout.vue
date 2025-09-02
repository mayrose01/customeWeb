<template>
  <div class="mall-checkout-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <div class="checkout-header">
          <h1>订单结算</h1>
          <p>请确认订单信息并完成支付</p>
        </div>

        <div class="checkout-content">
          <!-- 收货地址 -->
          <div class="address-section">
            <h2>收货地址</h2>
            <div class="address-list">
              <div 
                v-for="address in addresses" 
                :key="address.id"
                class="address-item"
                :class="{ active: selectedAddress === address.id }"
                @click="selectAddress(address.id)"
              >
                <div class="address-info">
                  <div class="contact-info">
                    <span class="name">{{ address.name }}</span>
                    <span class="phone">{{ address.phone }}</span>
                  </div>
                  <div class="address-detail">
                    {{ address.province }} {{ address.city }} {{ address.district }} {{ address.detail }}
                  </div>
                </div>
                <div class="address-actions">
                  <button class="edit-btn" @click.stop="editAddress(address)">编辑</button>
                  <button class="delete-btn" @click.stop="deleteAddress(address.id)">删除</button>
                </div>
              </div>
              <div class="add-address" @click="showAddressModal = true">
                <span class="add-icon">+</span>
                <span>添加新地址</span>
              </div>
            </div>
          </div>

          <!-- 商品信息 -->
          <div class="products-section">
            <h2>商品信息</h2>
            <div class="products-list">
              <div 
                v-for="item in orderItems" 
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
                  <div class="product-specs" v-if="item.specificationsList">
                    <span 
                      v-for="spec in item.specificationsList" 
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

          <!-- 订单备注 -->
          <div class="remark-section">
            <h2>订单备注</h2>
            <textarea 
              v-model="orderRemark" 
              placeholder="请输入订单备注（选填）"
              class="remark-input"
              rows="3"
            ></textarea>
          </div>

          <!-- 支付方式 -->
          <div class="payment-section">
            <h2>支付方式</h2>
            <div class="payment-methods">
              <div 
                v-for="method in paymentMethods" 
                :key="method.id"
                class="payment-method"
                :class="{ active: selectedPayment === method.id }"
                @click="selectPayment(method.id)"
              >
                <div class="method-icon">{{ method.icon }}</div>
                <div class="method-info">
                  <div class="method-name">{{ method.name }}</div>
                  <div class="method-desc">{{ method.description }}</div>
                </div>
                <div class="method-radio">
                  <input 
                    type="radio" 
                    :name="'payment'" 
                    :value="method.id"
                    v-model="selectedPayment"
                  />
                </div>
              </div>
            </div>
          </div>

          <!-- 订单总计 -->
          <div class="order-summary">
            <div class="summary-item">
              <span>商品总价：</span>
              <span class="amount">¥{{ totalAmount.toFixed(2) }}</span>
            </div>
            <div class="summary-item">
              <span>运费：</span>
              <span class="amount">¥{{ shippingFee.toFixed(2) }}</span>
            </div>
            <div class="summary-item total">
              <span>应付总额：</span>
              <span class="final-amount">¥{{ finalAmount.toFixed(2) }}</span>
            </div>
          </div>

          <!-- 提交订单 -->
          <div class="submit-section">
            <button 
              class="submit-btn" 
              @click="submitOrder"
              :disabled="!canSubmit"
            >
              提交订单
            </button>
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
  name: 'MallCheckout',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    const addresses = ref([])
    const orderItems = ref([])
    const selectedAddress = ref(null)
    const orderRemark = ref('')
    const selectedPayment = ref('wechat')
    const showAddressModal = ref(false)
    
    // 支付方式
    const paymentMethods = ref([
      { id: 'wechat', name: '微信支付', description: '推荐使用微信扫码支付', icon: '💬' },
      { id: 'alipay', name: '支付宝', description: '使用支付宝扫码支付', icon: '💰' }
    ])
    
    // 加载数据
    const loadData = async () => {
      try {
        // 加载收货地址
        // TODO: 调用API加载地址
        addresses.value = [
          {
            id: 1,
            name: '张三',
            phone: '13800138000',
            province: '广东省',
            city: '深圳市',
            district: '南山区',
            detail: '科技园路123号'
          }
        ]
        
        if (addresses.value.length > 0) {
          selectedAddress.value = addresses.value[0].id
        }
        
        // 加载订单商品
        // TODO: 根据路由参数加载商品
        orderItems.value = [
          {
            id: 1,
            product_title: '智能手机',
            product_image: '',
            price: 2999,
            quantity: 1,
            specificationsList: [
              { name: '颜色', value: '黑色' },
              { name: '存储', value: '256GB' }
            ]
          }
        ]
      } catch (error) {
        console.error('加载数据失败:', error)
        ElMessage.error('加载数据失败')
      }
    }
    
    // 计算属性
    const totalAmount = computed(() => {
      return orderItems.value.reduce((total, item) => {
        return total + (parseFloat(item.price || 0) * item.quantity)
      }, 0)
    })
    
    const shippingFee = computed(() => {
      return totalAmount.value > 99 ? 0 : 10
    })
    
    const finalAmount = computed(() => {
      return totalAmount.value + shippingFee.value
    })
    
    const canSubmit = computed(() => {
      return selectedAddress.value && selectedPayment.value
    })
    
    // 选择地址
    const selectAddress = (addressId) => {
      selectedAddress.value = addressId
    }
    
    // 编辑地址
    const editAddress = (address) => {
      // TODO: 打开地址编辑弹窗
      console.log('编辑地址:', address)
    }
    
    // 删除地址
    const deleteAddress = async (addressId) => {
      try {
        await ElMessageBox.confirm('确定要删除这个地址吗？', '提示', {
          type: 'warning'
        })
        
        // TODO: 调用API删除地址
        addresses.value = addresses.value.filter(addr => addr.id !== addressId)
        
        if (selectedAddress.value === addressId) {
          selectedAddress.value = addresses.value.length > 0 ? addresses.value[0].id : null
        }
        
        ElMessage.success('地址已删除')
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('删除失败')
        }
      }
    }
    
    // 选择支付方式
    const selectPayment = (paymentId) => {
      selectedPayment.value = paymentId
    }
    
    // 提交订单
    const submitOrder = async () => {
      try {
        if (!canSubmit.value) {
          ElMessage.warning('请完善订单信息')
          return
        }
        
        // TODO: 调用API提交订单
        const orderData = {
          address_id: selectedAddress.value,
          payment_method: selectedPayment.value,
          remark: orderRemark.value,
          items: orderItems.value.map(item => ({
            product_id: item.product_id,
            quantity: item.quantity,
            specifications: item.specificationsList
          }))
        }
        
        // const response = await createMallOrder(orderData)
        // const orderId = response.data.order_id
        
        ElMessage.success('订单提交成功')
        
        // 跳转到支付页面或订单详情页
        router.push({
          path: getClientPath('/mall/order/1'),
          query: { payment_method: selectedPayment.value }
        })
      } catch (error) {
        ElMessage.error('订单提交失败')
      }
    }
    
    onMounted(() => {
      loadData()
    })
    
    return {
      addresses,
      orderItems,
      selectedAddress,
      orderRemark,
      selectedPayment,
      paymentMethods,
      showAddressModal,
      totalAmount,
      shippingFee,
      finalAmount,
      canSubmit,
      selectAddress,
      editAddress,
      deleteAddress,
      selectPayment,
      submitOrder,
      getClientPath,
      getImageUrl
    }
  }
}
</script>

<style scoped>
.mall-checkout-page {
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

.checkout-header {
  text-align: center;
  margin-bottom: 40px;
}

.checkout-header h1 {
  font-size: 2.5rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.checkout-header p {
  color: var(--color-text-secondary);
  font-size: 1.1rem;
}

.checkout-content {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.address-section,
.products-section,
.remark-section,
.payment-section {
  background: white;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.address-section h2,
.products-section h2,
.remark-section h2,
.payment-section h2 {
  font-size: 1.5rem;
  color: var(--color-text-primary);
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;
}

/* 地址部分 */
.address-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.address-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.address-item:hover {
  border-color: var(--color-primary);
}

.address-item.active {
  border-color: var(--color-primary);
  background: #f0f9ff;
}

.address-info {
  flex: 1;
}

.contact-info {
  margin-bottom: 8px;
}

.contact-info .name {
  font-weight: 600;
  color: var(--color-text-primary);
  margin-right: 15px;
}

.contact-info .phone {
  color: var(--color-text-secondary);
}

.address-detail {
  color: var(--color-text-secondary);
  line-height: 1.5;
}

.address-actions {
  display: flex;
  gap: 10px;
}

.edit-btn,
.delete-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 6px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.edit-btn {
  background: var(--color-primary);
  color: white;
}

.edit-btn:hover {
  background: var(--color-primary-hover);
}

.delete-btn {
  background: #dc3545;
  color: white;
}

.delete-btn:hover {
  background: #c82333;
}

.add-address {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 30px;
  border: 2px dashed #d1d5db;
  border-radius: 12px;
  cursor: pointer;
  color: var(--color-text-secondary);
  transition: all 0.3s ease;
}

.add-address:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.add-icon {
  font-size: 1.5rem;
  font-weight: 600;
}

/* 商品部分 */
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

/* 备注部分 */
.remark-input {
  width: 100%;
  padding: 15px;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  font-size: 1rem;
  outline: none;
  transition: border-color 0.3s;
  resize: vertical;
}

.remark-input:focus {
  border-color: var(--color-primary);
}

/* 支付方式部分 */
.payment-methods {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.payment-method {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.payment-method:hover {
  border-color: var(--color-primary);
}

.payment-method.active {
  border-color: var(--color-primary);
  background: #f0f9ff;
}

.method-icon {
  font-size: 2rem;
}

.method-info {
  flex: 1;
}

.method-name {
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: 5px;
}

.method-desc {
  color: var(--color-text-secondary);
  font-size: 0.9rem;
}

.method-radio input[type="radio"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

/* 订单总计 */
.order-summary {
  background: white;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.summary-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 0;
  font-size: 1.1rem;
  border-bottom: 1px solid #f0f0f0;
}

.summary-item:last-child {
  border-bottom: none;
}

.summary-item.total {
  font-size: 1.3rem;
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

/* 提交部分 */
.submit-section {
  text-align: center;
}

.submit-btn {
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: 12px;
  padding: 18px 40px;
  font-size: 1.2rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.submit-btn:hover:not(:disabled) {
  background: var(--color-primary-hover);
  transform: translateY(-2px);
}

.submit-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .checkout-header h1 {
    font-size: 2rem;
  }
  
  .address-section,
  .products-section,
  .remark-section,
  .payment-section {
    padding: 20px;
  }
  
  .product-item {
    grid-template-columns: 1fr;
    gap: 15px;
    text-align: center;
  }
  
  .product-image {
    margin: 0 auto;
  }
  
  .address-item {
    flex-direction: column;
    align-items: stretch;
    gap: 15px;
  }
  
  .address-actions {
    justify-content: center;
  }
}
</style>
