<template>
  <div class="checkout-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 页面标题 -->
        <div class="page-header">
          <h1>订单结算</h1>
          <p>确认订单信息并完成支付</p>
        </div>

        <div class="checkout-content">
          <!-- 收货地址 -->
          <div class="address-section">
            <div class="section-header">
              <h2>收货地址</h2>
              <el-button type="primary" @click="showAddressModal = true">
                <i class="icon-add"></i>
                新增地址
              </el-button>
            </div>
            
            <div class="address-list" v-if="addresses.length > 0">
              <div 
                v-for="address in addresses" 
                :key="address.id"
                class="address-item"
                :class="{ active: selectedAddressId === address.id }"
                @click="selectAddress(address.id)"
              >
                <div class="address-info">
                  <div class="contact-info">
                    <span class="name">{{ address.contact_name }}</span>
                    <span class="phone">{{ address.phone }}</span>
                  </div>
                  <div class="address-detail">
                    {{ address.province }} {{ address.city }} {{ address.district }} {{ address.detail_address }}
                  </div>
                </div>
                <div class="address-actions">
                  <el-button type="text" @click.stop="editAddress(address)">
                    <i class="icon-edit"></i>
                    编辑
                  </el-button>
                  <el-button type="text" @click.stop="onDeleteAddress(address.id)">
                    <i class="icon-delete"></i>
                    删除
                  </el-button>
                </div>
              </div>
            </div>
            
            <div v-else class="no-address">
              <p>暂无收货地址，请先添加</p>
            </div>
          </div>

          <!-- 订单商品 -->
          <div class="order-items-section">
            <h2>订单商品</h2>
            <div class="order-items">
              <div 
                v-for="item in orderItems" 
                :key="item.sku_id"
                class="order-item"
              >
                <div class="item-image">
                  <img 
                    v-if="item.product_image" 
                    :src="getImageUrl(item.product_image)" 
                    :alt="item.product_title"
                  />
                  <div v-else class="image-placeholder">📦</div>
                </div>
                <div class="item-info">
                  <h4>{{ item.product_title }}</h4>
                  <p class="sku">SKU: {{ item.sku_code }}</p>
                  <div class="specifications" v-if="item.specifications">
                    <el-tag 
                      v-for="(value, key) in item.specifications" 
                      :key="key"
                      size="small"
                      style="margin-right: 5px;"
                    >
                      {{ key }}: {{ value }}
                    </el-tag>
                  </div>
                </div>
                <div class="item-price">
                  <span class="price">¥{{ item.price }}</span>
                </div>
                <div class="item-quantity">
                  <span class="quantity">x{{ item.quantity }}</span>
                </div>
                <div class="item-subtotal">
                  <span class="subtotal">¥{{ (item.price * item.quantity).toFixed(2) }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 订单备注 -->
          <div class="order-remark-section">
            <h2>订单备注</h2>
            <el-input
              v-model="orderRemark"
              type="textarea"
              :rows="3"
              placeholder="请输入订单备注（可选）"
              maxlength="200"
              show-word-limit
            />
          </div>

          <!-- 订单总计 -->
          <div class="order-summary-section">
            <h2>订单总计</h2>
            <div class="summary-items">
              <div class="summary-item">
                <span>商品总价:</span>
                <span class="amount">¥{{ totalAmount.toFixed(2) }}</span>
              </div>
              <div class="summary-item">
                <span>运费:</span>
                <span class="amount">¥{{ shippingFee.toFixed(2) }}</span>
              </div>
              <div class="summary-item total">
                <span>实付金额:</span>
                <span class="amount">¥{{ (totalAmount + shippingFee).toFixed(2) }}</span>
              </div>
            </div>
          </div>

          <!-- 支付方式 -->
          <div class="payment-section">
            <h2>支付方式</h2>
            <div class="payment-methods">
              <div 
                class="payment-method"
                :class="{ active: selectedPaymentMethod === 'wechat' }"
                @click="selectPaymentMethod('wechat')"
              >
                <i class="icon-wechat"></i>
                <span>微信支付</span>
              </div>
              <div 
                class="payment-method"
                :class="{ active: selectedPaymentMethod === 'alipay' }"
                @click="selectPaymentMethod('alipay')"
              >
                <i class="icon-alipay"></i>
                <span>支付宝</span>
              </div>
            </div>
          </div>

          <!-- 提交订单 -->
          <div class="submit-section">
            <el-button 
              type="primary" 
              size="large" 
              @click="submitOrder"
              :loading="submitting"
              :disabled="!canSubmitOrder"
            >
              提交订单
            </el-button>
          </div>
        </div>
      </div>
    </main>

    <ClientFooter />

    <!-- 地址管理弹窗 -->
    <AddressModal
      :visible="showAddressModal"
      :address="editingAddress"
      @close="closeAddressModal"
      @success="handleAddressSuccess"
    />

    <!-- 支付弹窗 -->
    <PaymentModal
      :visible="showPaymentModal"
      :order="currentOrder"
      :payment-method="selectedPaymentMethod"
      @close="closePaymentModal"
      @success="handlePaymentSuccess"
    />
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import AddressModal from '@/components/client/AddressModal.vue'
import PaymentModal from '@/components/client/PaymentModal.vue'
import { userStore } from '@/store/user'
import { getImageUrl } from '@/utils/imageUtils'
import { createOrder } from '@/api/order'
import { getAddresses, createAddress, updateAddress, deleteAddress as apiDeleteAddress } from '@/api/address'
import { getSkuInfo } from '@/api/product'

export default {
  name: 'Checkout',
  components: {
    ClientHeader,
    ClientFooter,
    AddressModal,
    PaymentModal
  },
  setup() {
    const route = useRoute()
    const router = useRouter()

    
    // 检查用户登录状态
    if (!userStore.isLoggedIn) {
      ElMessage.warning('请先登录')
      router.push('/login')
      return
    }
    
    // 响应式数据
    const addresses = ref([])
    const selectedAddressId = ref(null)
    const orderItems = ref([])
    const orderRemark = ref('')
    const selectedPaymentMethod = ref('wechat')
    const submitting = ref(false)
    const showAddressModal = ref(false)
    const showPaymentModal = ref(false)
    const editingAddress = ref(null)
    const currentOrder = ref(null)
    
    // 运费（可以根据实际需求调整）
    const shippingFee = ref(0)
    
    // 计算属性
    const totalAmount = computed(() => {
      return orderItems.value.reduce((total, item) => {
        const price = parseFloat(item.price) || 0
        const quantity = parseInt(item.quantity) || 0
        return total + (price * quantity)
      }, 0)
    })
    
    const canSubmitOrder = computed(() => {
      return selectedAddressId.value && orderItems.value.length > 0
    })
    
    // 初始化订单商品
    const initOrderItems = async () => {
      const { sku_id, quantity, items } = route.query
      
      if (items) {
        // 从购物车结算的情况
        try {
          orderItems.value = JSON.parse(items)
        } catch (error) {
          console.error('解析购物车商品数据失败:', error)
          orderItems.value = []
        }
      } else if (sku_id && quantity) {
        // 从商品详情直接购买的情况
        try {
          // 根据sku_id获取商品信息
          const skuResponse = await getSkuInfo(parseInt(sku_id))
          const sku = skuResponse.data
          
          if (sku && sku.product) {
            orderItems.value = [{
              sku_id: parseInt(sku_id),
              quantity: parseInt(quantity),
              product_title: sku.product.title,
              sku_code: sku.sku_code || `SKU${sku.id}`,
              price: sku.price,
              product_image: sku.product.images && sku.product.images.length > 0 ? sku.product.images[0] : null,
              specifications: sku.sku_specs ? sku.sku_specs.reduce((acc, spec) => {
                acc[spec.spec_value.specification.name] = spec.spec_value.value
                return acc
              }, {}) : {}
            }]
          } else {
            ElMessage.error('商品信息获取失败')
            router.push('/all-products')
          }
        } catch (error) {
          console.error('获取商品信息失败:', error)
          ElMessage.error('获取商品信息失败')
          router.push('/all-products')
        }
      } else {
        // 其他情况，尝试加载购物车商品
        loadCartItems()
      }
    }
    
    // 加载购物车商品
    const loadCartItems = async () => {
      try {
        // 这里需要调用购物车API
        // 暂时使用模拟数据
        orderItems.value = []
      } catch (error) {
        console.error('加载购物车商品失败:', error)
      }
    }
    
    // 获取用户地址列表
    const loadAddresses = async () => {
      try {
        const res = await getAddresses(userStore.userInfo.id)
        addresses.value = res.data
        // 自动选择第一个地址
        if (addresses.value.length > 0 && !selectedAddressId.value) {
          selectedAddressId.value = addresses.value[0].id
        }
      } catch (error) {
        console.error('加载收货地址失败:', error)
        addresses.value = []
      }
    }
    
    // 选择地址
    const selectAddress = (addressId) => {
      selectedAddressId.value = addressId
    }
    
    // 编辑地址
    const editAddress = (address) => {
      editingAddress.value = { ...address }
      showAddressModal.value = true
    }
    
    // 删除地址
    const onDeleteAddress = async (addressId) => {
      try {
        await ElMessageBox.confirm('确定要删除这个地址吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        
        await apiDeleteAddress(addressId)
        ElMessage.success('地址删除成功')
        await loadAddresses()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除地址失败:', error)
          ElMessage.error('删除地址失败')
        }
      }
    }
    
    // 选择支付方式
    const selectPaymentMethod = (method) => {
      selectedPaymentMethod.value = method
    }
    
    // 提交订单
    const submitOrder = async () => {
      try {
        submitting.value = true
        
        // 验证地址
        if (!selectedAddressId.value) {
          ElMessage.error('请选择收货地址')
          return
        }
        
        // 获取选中的地址
        const selectedAddress = addresses.value.find(addr => addr.id === selectedAddressId.value)
        if (!selectedAddress) {
          ElMessage.error('收货地址无效')
          return
        }
        
        // 构建订单数据
        const orderData = {
          items: orderItems.value.map(item => ({
            sku_id: item.sku_id,
            quantity: item.quantity,
            price: item.price
          })),
          payment_method: selectedPaymentMethod.value,
          shipping_address: `${selectedAddress.province} ${selectedAddress.city} ${selectedAddress.district} ${selectedAddress.detail_address}`,
          shipping_contact: selectedAddress.contact_name,
          shipping_phone: selectedAddress.phone,
          remark: orderRemark.value
        }
        
        // 创建订单
        const response = await createOrder(userStore.userInfo.id, orderData)
        currentOrder.value = response.data
        
        ElMessage.success('订单创建成功')
        
        // 创建成功后直接跳转到我的订单列表，便于测试
        router.push('/orders')
        return
        
      } catch (error) {
        console.error('提交订单失败:', error)
        ElMessage.error('提交订单失败，请重试')
      } finally {
        submitting.value = false
      }
    }
    
    // 关闭地址弹窗
    const closeAddressModal = () => {
      showAddressModal.value = false
      editingAddress.value = null
    }
    
    // 地址操作成功
    const handleAddressSuccess = async () => {
      await loadAddresses()
      closeAddressModal()
    }
    
    // 关闭支付弹窗
    const closePaymentModal = () => {
      showPaymentModal.value = false
    }
    
    // 支付成功
    const handlePaymentSuccess = () => {
      ElMessage.success('支付成功！')
      // 跳转到订单详情页面
      router.push(`/orders/${currentOrder.value.id}`)
    }
    
    // 页面加载
    onMounted(async () => {
      await Promise.all([
        loadAddresses(),
        initOrderItems()
      ])
    })
    
    return {
      addresses,
      selectedAddressId,
      orderItems,
      orderRemark,
      selectedPaymentMethod,
      submitting,
      showAddressModal,
      showPaymentModal,
      editingAddress,
      currentOrder,
      shippingFee,
      totalAmount,
      canSubmitOrder,
      selectAddress,
      editAddress,
      onDeleteAddress,
      selectPaymentMethod,
      submitOrder,
      closeAddressModal,
      handleAddressSuccess,
      closePaymentModal,
      handlePaymentSuccess,
      getImageUrl
    }
  }
}
</script>

<style scoped>
.checkout-page {
  min-height: 100vh;
}

.main-content {
  padding-top: 120px;
  padding-bottom: 60px;
}

.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 0 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h1 {
  font-size: 2.5rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.page-header p {
  font-size: 1.1rem;
  color: var(--color-text-muted);
}

.checkout-content {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

/* 地址部分 */
.address-section {
  background: white;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h2 {
  margin: 0;
  color: var(--color-text-primary);
  font-size: 1.5rem;
}

.address-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.address-item {
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.address-item:hover {
  border-color: var(--color-primary);
}

.address-item.active {
  border-color: var(--color-primary);
  background: var(--color-primary-light);
}

.address-info {
  flex: 1;
}

.contact-info {
  margin-bottom: 8px;
}

.contact-info .name {
  font-weight: 600;
  margin-right: 15px;
}

.contact-info .phone {
  color: var(--color-text-muted);
}

.address-detail {
  color: var(--color-text-secondary);
  line-height: 1.5;
}

.address-actions {
  display: flex;
  gap: 10px;
}

.no-address {
  text-align: center;
  padding: 40px;
  color: var(--color-text-muted);
}

/* 订单商品部分 */
.order-items-section {
  background: white;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.order-items-section h2 {
  margin: 0 0 20px 0;
  color: var(--color-text-primary);
  font-size: 1.5rem;
}

.order-items {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.order-item {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 15px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
}

.item-image {
  width: 80px;
  height: 80px;
  border-radius: 6px;
  overflow: hidden;
  flex-shrink: 0;
}

.item-image img {
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
  background: #f3f4f6;
  font-size: 2rem;
}

.item-info {
  flex: 1;
}

.item-info h4 {
  margin: 0 0 8px 0;
  color: var(--color-text-primary);
  font-size: 1.1rem;
}

.item-info .sku {
  color: var(--color-text-muted);
  font-size: 0.9rem;
  margin-bottom: 8px;
}

.item-price, .item-quantity, .item-subtotal {
  text-align: center;
  min-width: 80px;
}

.item-price .price {
  color: var(--color-primary);
  font-weight: 600;
  font-size: 1.1rem;
}

.item-quantity .quantity {
  color: var(--color-text-secondary);
}

.item-subtotal .subtotal {
  color: var(--color-primary);
  font-weight: 600;
  font-size: 1.1rem;
}

/* 订单备注部分 */
.order-remark-section {
  background: white;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.order-remark-section h2 {
  margin: 0 0 20px 0;
  color: var(--color-text-primary);
  font-size: 1.5rem;
}

/* 订单总计部分 */
.order-summary-section {
  background: white;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.order-summary-section h2 {
  margin: 0 0 20px 0;
  color: var(--color-text-primary);
  font-size: 1.5rem;
}

.summary-items {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #e5e7eb;
}

.summary-item.total {
  border-bottom: none;
  border-top: 2px solid var(--color-primary);
  padding-top: 20px;
  font-size: 1.2rem;
  font-weight: 600;
}

.summary-item .amount {
  color: var(--color-primary);
  font-weight: 600;
}

/* 支付方式部分 */
.payment-section {
  background: white;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.payment-section h2 {
  margin: 0 0 20px 0;
  color: var(--color-text-primary);
  font-size: 1.5rem;
}

.payment-methods {
  display: flex;
  gap: 20px;
}

.payment-method {
  flex: 1;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.1rem;
}

.payment-method:hover {
  border-color: var(--color-primary);
}

.payment-method.active {
  border-color: var(--color-primary);
  background: var(--color-primary-light);
}

.payment-method i {
  font-size: 1.5rem;
}

/* 提交订单部分 */
.submit-section {
  text-align: center;
  padding: 30px;
}

.submit-section .el-button {
  padding: 15px 40px;
  font-size: 1.2rem;
}

/* 图标样式 */
.icon-add::before {
  content: '➕';
}

.icon-edit::before {
  content: '✏️';
}

.icon-delete::before {
  content: '🗑️';
}

.icon-wechat::before {
  content: '💬';
}

.icon-alipay::before {
  content: '💰';
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 15px;
  }
  
  .address-section,
  .order-items-section,
  .order-remark-section,
  .order-summary-section,
  .payment-section {
    padding: 20px;
  }
  
  .order-item {
    flex-direction: column;
    text-align: center;
    gap: 15px;
  }
  
  .item-price, .item-quantity, .item-subtotal {
    min-width: auto;
  }
  
  .payment-methods {
    flex-direction: column;
  }
  
  .page-header h1 {
    font-size: 2rem;
  }
}
</style>