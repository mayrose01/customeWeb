<template>
  <div class="mall-checkout-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 面包屑导航 -->
        <div class="breadcrumb">
          <router-link :to="getClientPath('/mall')">商城首页</router-link>
          <span class="separator">/</span>
          <span>订单结算</span>
        </div>

        <div class="checkout-content" v-if="!loading">
          <div class="checkout-main">
            <!-- 收货地址 -->
            <div class="address-section">
              <div class="section-header">
                <h2>收货地址</h2>
                <button class="add-address-btn" @click="showAddressModal = true">
                  + 新增地址
                </button>
              </div>
              
              <div class="address-list" v-if="addresses.length > 0">
                <div 
                  class="address-item"
                  v-for="address in addresses"
                  :key="address.id"
                  :class="{ selected: selectedAddress?.id === address.id }"
                  @click="selectAddress(address)"
                >
                  <div class="address-info">
                    <div class="address-header">
                      <span class="name">{{ address.name }}</span>
                      <span class="phone">{{ address.phone }}</span>
                      <span v-if="address.is_default" class="default-tag">默认</span>
                    </div>
                    <div class="address-detail">
                      {{ address.province }} {{ address.city }} {{ address.district }} {{ address.address }}
                    </div>
                  </div>
                  <div class="address-actions">
                    <button class="edit-btn" @click.stop="editAddress(address)">编辑</button>
                    <button class="delete-btn" @click.stop="deleteAddress(address)">删除</button>
                  </div>
                </div>
              </div>
              
              <div v-else class="no-address">
                <p>暂无收货地址，请先添加地址</p>
                <button class="add-first-address-btn" @click="showAddressModal = true">
                  添加收货地址
                </button>
              </div>
            </div>

            <!-- 商品信息 -->
            <div class="products-section">
              <div class="section-header">
                <h2>商品信息</h2>
              </div>
              
              <div class="product-list">
                <div class="product-item" v-for="item in orderItems" :key="item.product_id">
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
                    <h3 class="product-title">{{ item.product?.title || '商品已下架' }}</h3>
                    <p class="product-specs" v-if="item.sku && item.sku.specifications">
                      {{ formatSpecifications(item.sku.specifications) }}
                    </p>
                    <div class="product-price">¥{{ parseFloat(item.price || 0).toFixed(2) }}</div>
                  </div>
                  
                  <div class="product-quantity">
                    <span class="quantity-label">数量：</span>
                    <span class="quantity-value">{{ item.quantity }}</span>
                  </div>
                  
                  <div class="product-subtotal">
                    ¥{{ (parseFloat(item.price || 0) * item.quantity).toFixed(2) }}
                  </div>
                </div>
              </div>
            </div>

            <!-- 订单备注 -->
            <div class="remark-section">
              <div class="section-header">
                <h2>订单备注</h2>
              </div>
              <textarea 
                v-model="orderRemark"
                class="remark-input"
                placeholder="请输入订单备注（选填）"
                rows="3"
              ></textarea>
            </div>
          </div>

          <!-- 订单汇总 -->
          <div class="order-summary">
            <div class="summary-header">
              <h2>订单汇总</h2>
            </div>
            
            <div class="summary-details">
              <div class="summary-row">
                <span>商品总价：</span>
                <span>¥{{ totalAmount.toFixed(2) }}</span>
              </div>
              <div class="summary-row">
                <span>运费：</span>
                <span>¥0.00</span>
              </div>
              <div class="summary-row total">
                <span>应付总额：</span>
                <span>¥{{ totalAmount.toFixed(2) }}</span>
              </div>
            </div>
            
            <div class="payment-section">
              <div class="payment-method">
                <h3>支付方式</h3>
                <div class="payment-options">
                  <div class="payment-option">
                    <input 
                      type="radio" 
                      id="contact-service" 
                      v-model="paymentMethod" 
                      value="contact_service"
                    />
                    <label for="contact-service">
                      <span class="payment-icon">📞</span>
                      <span class="payment-text">联系客服付款</span>
                    </label>
                  </div>
                </div>
                <div class="payment-note">
                  <p>💡 请添加客服微信或电话联系客服完成付款</p>
                </div>
              </div>
            </div>
            
            <button 
              class="submit-order-btn"
              @click="submitOrder"
              :disabled="!selectedAddress || submitting"
            >
              {{ submitting ? '提交中...' : '提交订单' }}
            </button>
          </div>
        </div>

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载...</p>
        </div>
      </div>
    </main>

    <!-- 地址编辑弹窗 -->
    <div v-if="showAddressModal" class="modal-overlay" @click="closeAddressModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>{{ editingAddress ? '编辑地址' : '新增地址' }}</h3>
          <button class="close-btn" @click="closeAddressModal">×</button>
        </div>
        
        <div class="modal-body">
          <form @submit.prevent="saveAddress">
            <div class="form-group">
              <label>收货人姓名 *</label>
              <input 
                type="text" 
                v-model="addressForm.name" 
                required
                placeholder="请输入收货人姓名"
              />
            </div>
            
            <div class="form-group">
              <label>手机号码 *</label>
              <input 
                type="tel" 
                v-model="addressForm.phone" 
                required
                placeholder="请输入手机号码"
              />
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label>省份 *</label>
                <select 
                  v-model="addressForm.province" 
                  required
                  @change="onProvinceChange"
                  class="region-select"
                >
                  <option value="">请选择省份</option>
                  <option 
                    v-for="province in provinces" 
                    :key="province.code" 
                    :value="province.name"
                  >
                    {{ province.name }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label>城市 *</label>
                <select 
                  v-model="addressForm.city" 
                  required
                  @change="onCityChange"
                  :disabled="!addressForm.province"
                  class="region-select"
                >
                  <option value="">请选择城市</option>
                  <option 
                    v-for="city in availableCities" 
                    :key="city.code" 
                    :value="city.name"
                  >
                    {{ city.name }}
                  </option>
                </select>
              </div>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label>区县 *</label>
                <select 
                  v-model="addressForm.district" 
                  required
                  :disabled="!addressForm.city"
                  class="region-select"
                >
                  <option value="">请选择区县</option>
                  <option 
                    v-for="district in availableDistricts" 
                    :key="district.code" 
                    :value="district.name"
                  >
                    {{ district.name }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label>邮政编码</label>
                <input 
                  type="text" 
                  v-model="addressForm.postal_code" 
                  placeholder="请输入邮政编码"
                />
              </div>
            </div>
            
            <div class="form-group">
              <label>详细地址 *</label>
              <textarea 
                v-model="addressForm.address" 
                required
                placeholder="请输入详细地址"
                rows="3"
              ></textarea>
            </div>
            
            <div class="form-group">
              <label class="checkbox-label">
                <input 
                  type="checkbox" 
                  v-model="addressForm.is_default"
                />
                设为默认地址
              </label>
            </div>
            
            <div class="form-actions">
              <button type="button" class="cancel-btn" @click="closeAddressModal">
                取消
              </button>
              <button type="submit" class="save-btn" :disabled="savingAddress">
                {{ savingAddress ? '保存中...' : '保存' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <ClientFooter />
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getClientPath } from '@/utils/pathUtils'
import { getImageUrl } from '@/utils/imageUtils'
import { userStore } from '@/store/user'
import { getUserAddresses, createAddress, updateAddress, deleteAddress, setDefaultAddress } from '@/api/mall_address'
import { createOrder } from '@/api/mall_order'
import { clearCart, removeFromCart } from '@/api/mall_cart'
import { getMallProduct } from '@/api/mall_product'
import { provinces, getCities, getDistricts } from '@/data/regions'

export default {
  name: 'MallCheckout',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    const loading = ref(true)
    const submitting = ref(false)
    const orderItems = ref([])
    const cartItemIds = ref([]) // 记录来自购物车的项目ID，用于订单创建后移除
    const addresses = ref([])
    const selectedAddress = ref(null)
    const orderRemark = ref('')
    const paymentMethod = ref('contact_service')
    
    // 地址相关
    const showAddressModal = ref(false)
    const editingAddress = ref(null)
    const savingAddress = ref(false)
    const addressForm = ref({
      name: '',
      phone: '',
      province: '',
      city: '',
      district: '',
      address: '',
      postal_code: '',
      is_default: false
    })
    
    // 省市区相关
    const availableCities = ref([])
    const availableDistricts = ref([])
    
    // 总金额
    const totalAmount = computed(() => {
      return orderItems.value.reduce((total, item) => {
        return total + (parseFloat(item.price || 0) * item.quantity)
      }, 0)
    })
    
    // 加载数据
    const loadData = async () => {
      try {
        loading.value = true
        
        if (!userStore.isLoggedIn) {
          ElMessage.warning('请先登录')
          router.push(getClientPath('/login'))
          return
        }
        
        // 加载地址列表
        await loadAddresses()
        
        // 解析订单商品
        await parseOrderItems()
        
      } catch (err) {
        console.error('加载数据失败:', err)
        ElMessage.error('加载数据失败')
      } finally {
        loading.value = false
      }
    }
    
    // 加载地址列表
    const loadAddresses = async () => {
      try {
        const response = await getUserAddresses(userStore.userInfo.id)
        addresses.value = response.data || []
        
        // 自动选择默认地址
        const defaultAddress = addresses.value.find(addr => addr.is_default)
        if (defaultAddress) {
          selectedAddress.value = defaultAddress
        }
      } catch (err) {
        console.error('加载地址失败:', err)
      }
    }
    
    // 解析订单商品
    const parseOrderItems = async () => {
      try {
        const { product_id, quantity, items, from, cart_item_ids } = route.query
        
        if (from === 'cart' && items) {
          // 从购物车来的
          const cartItems = JSON.parse(items)
          orderItems.value = cartItems
          
          // 记录购物车项目ID
          if (cart_item_ids) {
            cartItemIds.value = JSON.parse(cart_item_ids)
          }
        } else if (product_id && quantity) {
          // 立即购买
          const response = await getMallProduct(product_id)
          if (response.data) {
            const product = response.data
            const sku_id = route.query.sku_id ? parseInt(route.query.sku_id) : null
            
            // 查找对应的SKU
            let selectedSKU = null
            let price = product.base_price
            
            if (sku_id && product.skus) {
              selectedSKU = product.skus.find(sku => sku.id === sku_id)
              if (selectedSKU) {
                price = selectedSKU.price
              }
            }
            
            orderItems.value = [{
              product_id: parseInt(product_id),
              sku_id: sku_id,
              quantity: parseInt(quantity),
              price: price,
              product: product,
              sku: selectedSKU
            }]
          }
        }
      } catch (err) {
        console.error('解析订单商品失败:', err)
        ElMessage.error('订单商品信息错误')
        router.push(getClientPath('/mall'))
      }
    }
    
    // 选择地址
    const selectAddress = (address) => {
      selectedAddress.value = address
    }
    
    // 编辑地址
    const editAddress = (address) => {
      editingAddress.value = address
      addressForm.value = { ...address }
      
      // 根据已有地址信息加载对应的城市和区县选项
      if (address.province) {
        const selectedProvince = provinces.find(p => p.name === address.province)
        
        if (selectedProvince) {
          availableCities.value = getCities(selectedProvince.code)
          
          // 如果已有城市信息，加载对应的区县选项
          if (address.city) {
            const selectedCity = availableCities.value.find(c => c.name === address.city)
            
            if (selectedCity) {
              availableDistricts.value = getDistricts(selectedCity.code)
            }
          }
        }
      }
      
      showAddressModal.value = true
    }
    
    // 删除地址
    const deleteAddress = async (address) => {
      try {
        await ElMessageBox.confirm(
          '确定要删除这个地址吗？',
          '确认删除',
          {
            confirmButtonText: '删除',
            cancelButtonText: '取消',
            type: 'warning',
          }
        )
        
        await deleteAddress(address.id, userStore.userInfo.id)
        await loadAddresses()
        ElMessage.success('地址已删除')
      } catch (err) {
        if (err !== 'cancel') {
          ElMessage.error('删除失败')
        }
      }
    }
    
    // 保存地址
    const saveAddress = async () => {
      try {
        savingAddress.value = true
        
        if (editingAddress.value) {
          // 更新地址
          await updateAddress(editingAddress.value.id, userStore.userInfo.id, addressForm.value)
          ElMessage.success('地址已更新')
        } else {
          // 创建地址
          await createAddress(userStore.userInfo.id, addressForm.value)
          ElMessage.success('地址已添加')
        }
        
        await loadAddresses()
        closeAddressModal()
      } catch (err) {
        ElMessage.error('保存失败')
      } finally {
        savingAddress.value = false
      }
    }
    
    // 关闭地址弹窗
    const closeAddressModal = () => {
      showAddressModal.value = false
      editingAddress.value = null
      addressForm.value = {
        name: '',
        phone: '',
        province: '',
        city: '',
        district: '',
        address: '',
        postal_code: '',
        is_default: false
      }
      // 重置省市区选择
      availableCities.value = []
      availableDistricts.value = []
    }
    
    // 省份选择变化
    const onProvinceChange = () => {
      // 清空城市和区县
      addressForm.value.city = ''
      addressForm.value.district = ''
      availableDistricts.value = []
      
      // 获取对应城市列表
      const selectedProvince = provinces.find(p => p.name === addressForm.value.province)
      if (selectedProvince) {
        availableCities.value = getCities(selectedProvince.code)
      } else {
        availableCities.value = []
      }
    }
    
    // 城市选择变化
    const onCityChange = () => {
      // 清空区县
      addressForm.value.district = ''
      
      // 获取对应区县列表
      const selectedCity = availableCities.value.find(c => c.name === addressForm.value.city)
      
      if (selectedCity) {
        availableDistricts.value = getDistricts(selectedCity.code)
      } else {
        availableDistricts.value = []
      }
    }
    
    // 提交订单
    const submitOrder = async () => {
      if (!selectedAddress.value) {
        ElMessage.warning('请选择收货地址')
        return
      }
      
      if (orderItems.value.length === 0) {
        ElMessage.warning('订单商品不能为空')
        return
      }
      
      try {
        submitting.value = true
        
        // 构建订单数据
        const orderData = {
          total_amount: totalAmount.value,
          status: 'pending',
          payment_status: 'unpaid',
          payment_method: paymentMethod.value,
          shipping_address: `${selectedAddress.value.name} ${selectedAddress.value.phone} ${selectedAddress.value.province} ${selectedAddress.value.city} ${selectedAddress.value.district} ${selectedAddress.value.address}`,
          remark: orderRemark.value,
          items: orderItems.value.map(item => ({
            product_id: item.product_id,
            sku_id: item.sku_id,
            product_name: item.product?.title || item.product_name,
            sku_specifications: item.sku?.specifications || item.sku_specifications || {},
            price: item.sku?.price || item.product?.base_price || 0,
            quantity: item.quantity,
            subtotal: (item.sku?.price || item.product?.base_price || 0) * item.quantity
          }))
        }
        
        // 创建订单
        const response = await createOrder(userStore.userInfo.id, orderData)
        
        // 移除已结算的购物车项目（只移除从购物车来的商品）
        if (cartItemIds.value.length > 0) {
          try {
            // 逐个移除购物车项目
            await Promise.all(
              cartItemIds.value.map(itemId => removeFromCart(itemId))
            )
            console.log('已移除购物车中的结算商品')
          } catch (cartError) {
            console.warn('移除购物车商品失败:', cartError)
          }
        }
        
        ElMessage.success('订单创建成功！请联系客服完成付款')
        
        // 跳转到订单列表
        router.push(getClientPath('/mall/orders'))
        
      } catch (err) {
        console.error('提交订单失败:', err)
        ElMessage.error('提交订单失败')
      } finally {
        submitting.value = false
      }
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
      loadData()
    })
    
    return {
      loading,
      submitting,
      orderItems,
      addresses,
      selectedAddress,
      orderRemark,
      paymentMethod,
      totalAmount,
      showAddressModal,
      editingAddress,
      savingAddress,
      addressForm,
      provinces,
      availableCities,
      availableDistricts,
      selectAddress,
      editAddress,
      deleteAddress,
      saveAddress,
      closeAddressModal,
      onProvinceChange,
      onCityChange,
      submitOrder,
      formatSpecifications,
      handleImageError,
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

.checkout-content {
  display: grid;
  grid-template-columns: 1fr 400px;
  gap: 30px;
}

.checkout-main {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 2px solid #f0f0f0;
}

.section-header h2 {
  font-size: 1.5rem;
  color: var(--color-text-primary);
  margin: 0;
}

.add-address-btn {
  padding: 8px 16px;
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.add-address-btn:hover {
  background: var(--color-primary-hover);
}

.address-section,
.products-section,
.remark-section {
  background: white;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

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
  border: 2px solid #f0f0f0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.address-item:hover {
  border-color: var(--color-primary);
}

.address-item.selected {
  border-color: var(--color-primary);
  background: #f8f9ff;
}

.address-info {
  flex: 1;
}

.address-header {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 8px;
}

.name {
  font-weight: 600;
  color: var(--color-text-primary);
}

.phone {
  color: var(--color-text-secondary);
}

.default-tag {
  background: var(--color-primary);
  color: white;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
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
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.edit-btn {
  background: #e3f2fd;
  color: #1976d2;
}

.edit-btn:hover {
  background: #bbdefb;
}

.delete-btn {
  background: #ffebee;
  color: #d32f2f;
}

.delete-btn:hover {
  background: #ffcdd2;
}

.no-address {
  text-align: center;
  padding: 40px 20px;
  color: var(--color-text-secondary);
}

.add-first-address-btn {
  margin-top: 15px;
  padding: 10px 20px;
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.add-first-address-btn:hover {
  background: var(--color-primary-hover);
}

.product-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.product-item {
  display: grid;
  grid-template-columns: 80px 1fr 100px 120px;
  gap: 20px;
  align-items: center;
  padding: 20px;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
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

.remark-input {
  width: 100%;
  padding: 12px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  font-size: 1rem;
  resize: vertical;
  outline: none;
  transition: border-color 0.3s;
}

.remark-input:focus {
  border-color: var(--color-primary);
}

.order-summary {
  background: white;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  height: fit-content;
  position: sticky;
  top: 140px;
}

.summary-header h2 {
  font-size: 1.5rem;
  color: var(--color-text-primary);
  margin: 0 0 20px 0;
}

.summary-details {
  margin-bottom: 30px;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  color: var(--color-text-secondary);
}

.summary-row.total {
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--color-text-primary);
  padding-top: 10px;
  border-top: 1px solid #f0f0f0;
}

.payment-section {
  margin-bottom: 30px;
}

.payment-method h3 {
  font-size: 1.1rem;
  color: var(--color-text-primary);
  margin: 0 0 15px 0;
}

.payment-options {
  margin-bottom: 15px;
}

.payment-option {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.3s;
}

.payment-option:hover {
  border-color: var(--color-primary);
}

.payment-option input[type="radio"] {
  margin: 0;
}

.payment-icon {
  font-size: 1.2rem;
}

.payment-text {
  font-weight: 500;
}

.payment-note {
  background: #fff3cd;
  border: 1px solid #ffeaa7;
  border-radius: 6px;
  padding: 12px;
}

.payment-note p {
  margin: 0;
  color: #856404;
  font-size: 0.9rem;
}

.submit-order-btn {
  width: 100%;
  padding: 15px;
  background: #ff4757;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1.1rem;
  font-weight: 600;
  transition: background-color 0.3s;
}

.submit-order-btn:hover:not(:disabled) {
  background: #ff3742;
}

.submit-order-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
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

/* 弹窗样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 25px;
  border-bottom: 1px solid #f0f0f0;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.3rem;
  color: var(--color-text-primary);
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: var(--color-text-secondary);
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  color: var(--color-text-primary);
}

.modal-body {
  padding: 25px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: var(--color-text-primary);
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  font-size: 1rem;
  outline: none;
  transition: border-color 0.3s;
}

.form-group input:focus,
.form-group textarea:focus {
  border-color: var(--color-primary);
}

.region-select {
  width: 100%;
  padding: 14px 16px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  font-size: 1rem;
  outline: none;
  transition: border-color 0.3s;
  background-color: white;
  min-height: 48px;
  cursor: pointer;
}

.region-select:focus {
  border-color: var(--color-primary);
}

.region-select:disabled {
  background-color: #f9fafb;
  color: #6b7280;
  cursor: not-allowed;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  width: auto;
  margin: 0;
}

.form-actions {
  display: flex;
  gap: 15px;
  justify-content: flex-end;
  margin-top: 30px;
}

.cancel-btn,
.save-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.3s;
}

.cancel-btn {
  background: #f5f5f5;
  color: var(--color-text-secondary);
}

.cancel-btn:hover {
  background: #e5e5e5;
}

.save-btn {
  background: var(--color-primary);
  color: white;
}

.save-btn:hover:not(:disabled) {
  background: var(--color-primary-hover);
}

.save-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .checkout-content {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .order-summary {
    position: static;
  }
  
  .product-item {
    grid-template-columns: 1fr;
    gap: 15px;
    text-align: center;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .form-actions {
    flex-direction: column;
  }
}
</style>