<template>
  <div class="mall-cart-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 面包屑导航 -->
        <div class="breadcrumb">
          <router-link :to="getClientPath('/mall')">商城首页</router-link>
          <span class="separator">/</span>
          <span>购物车</span>
        </div>

        <!-- 购物车内容 -->
        <div class="cart-content" v-if="!loading">
          <div class="cart-header">
            <h1>购物车</h1>
            <div class="cart-actions">
              <button 
                class="clear-cart-btn" 
                @click="clearCart"
                :disabled="cartItems.length === 0"
              >
                清空购物车
              </button>
            </div>
          </div>

          <!-- 购物车为空 -->
          <div v-if="cartItems.length === 0" class="empty-cart">
            <div class="empty-icon">🛒</div>
            <h3>购物车是空的</h3>
            <p>快去挑选心仪的商品吧！</p>
            <router-link :to="getClientPath('/mall/products')" class="go-shopping-btn">
              去购物
            </router-link>
          </div>

          <!-- 购物车商品列表 -->
          <div v-else class="cart-items">
            <!-- 全选控制 -->
            <div class="select-all-row">
              <div class="select-all-checkbox">
                <input 
                  type="checkbox" 
                  :checked="isAllSelected"
                  @change="toggleSelectAll"
                />
                <span>全选</span>
              </div>
            </div>
            
            <div class="cart-item" v-for="item in cartItems" :key="item.id">
              <div class="item-checkbox">
                <input 
                  type="checkbox" 
                  v-model="item.selected"
                  @change="updateSelectedItems"
                />
              </div>
              
              <div class="item-image">
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
              
              <div class="item-info">
                <h3 class="item-title">
                  <router-link :to="getClientPath(`/mall/product/${item.product_id}`)">
                    {{ item.product?.title || '商品已下架' }}
                  </router-link>
                </h3>
                <p class="item-specs" v-if="item.sku && item.sku.specifications">
                  {{ formatSpecifications(item.sku.specifications) }}
                </p>
                <div class="item-price">¥{{ parseFloat(item.sku?.price || item.product?.base_price || 0).toFixed(2) }}</div>
              </div>
              
              <div class="item-quantity">
                <div class="quantity-controls">
                  <button 
                    class="quantity-btn" 
                    @click="decreaseQuantity(item)"
                    :disabled="item.quantity <= 1"
                  >
                    -
                  </button>
                  <input 
                    type="number" 
                    v-model="item.quantity" 
                    class="quantity-input"
                    min="1"
                    :max="item.product?.stock || 999"
                    @change="updateQuantity(item)"
                  />
                  <button 
                    class="quantity-btn" 
                    @click="increaseQuantity(item)"
                    :disabled="item.quantity >= (item.product?.stock || 999)"
                  >
                    +
                  </button>
                </div>
              </div>
              
              <div class="item-subtotal">
                ¥{{ (parseFloat(item.sku?.price || item.product?.base_price || 0) * item.quantity).toFixed(2) }}
              </div>
              
              <div class="item-actions">
                <button class="remove-btn" @click="removeItem(item)">
                  删除
                </button>
              </div>
            </div>
          </div>

          <!-- 购物车结算 -->
          <div v-if="cartItems.length > 0" class="cart-summary">
            <div class="summary-info">
              <div class="selected-count">
                已选择 {{ selectedItems.length }} 件商品
              </div>
              <div class="total-amount">
                合计：<span class="amount">¥{{ totalAmount.toFixed(2) }}</span>
              </div>
            </div>
            <div class="summary-actions">
              <button 
                class="checkout-btn"
                @click="goToCheckout"
                :disabled="selectedItems.length === 0"
              >
                去结算 ({{ selectedItems.length }})
              </button>
            </div>
          </div>
        </div>

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载购物车...</p>
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
import { getCart, updateCartItem, removeFromCart, clearCart } from '@/api/mall_cart'

export default {
  name: 'MallCart',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    
    const loading = ref(true)
    const cartItems = ref([])
    
    // 加载购物车数据
    const loadCart = async () => {
      try {
        loading.value = true
        
        if (!userStore.isLoggedIn) {
          ElMessage.warning('请先登录')
          router.push(getClientPath('/login'))
          return
        }
        
        const response = await getCart(userStore.userInfo.id)
        if (response.data && response.data.items) {
          cartItems.value = response.data.items.map(item => ({
            ...item,
            selected: true // 默认选中
          }))
        }
      } catch (err) {
        console.error('加载购物车失败:', err)
        ElMessage.error('加载购物车失败')
      } finally {
        loading.value = false
      }
    }
    
    // 选中的商品
    const selectedItems = computed(() => {
      return cartItems.value.filter(item => item.selected)
    })
    
    // 是否全选
    const isAllSelected = computed(() => {
      return cartItems.value.length > 0 && cartItems.value.every(item => item.selected)
    })
    
    // 总金额
    const totalAmount = computed(() => {
      return selectedItems.value.reduce((total, item) => {
        return total + (parseFloat(item.sku?.price || item.product?.base_price || 0) * item.quantity)
      }, 0)
    })
    
    // 更新选中状态
    const updateSelectedItems = () => {
      // 这里可以添加其他逻辑，比如保存到本地存储
    }
    
    // 切换全选状态
    const toggleSelectAll = () => {
      const newSelectAll = !isAllSelected.value
      cartItems.value.forEach(item => {
        item.selected = newSelectAll
      })
    }
    
    // 数量控制
    const decreaseQuantity = async (item) => {
      if (item.quantity <= 1) return
      
      try {
        const newQuantity = item.quantity - 1
        await updateCartItem(item.id, { quantity: newQuantity })
        item.quantity = newQuantity
        ElMessage.success('数量已更新')
      } catch (err) {
        ElMessage.error('更新数量失败')
      }
    }
    
    const increaseQuantity = async (item) => {
      if (item.quantity >= (item.product?.stock || 999)) {
        ElMessage.warning('库存不足')
        return
      }
      
      try {
        const newQuantity = item.quantity + 1
        await updateCartItem(item.id, { quantity: newQuantity })
        item.quantity = newQuantity
        ElMessage.success('数量已更新')
      } catch (err) {
        ElMessage.error('更新数量失败')
      }
    }
    
    const updateQuantity = async (item) => {
      if (item.quantity < 1) {
        item.quantity = 1
        return
      }
      
      if (item.quantity > (item.product?.stock || 999)) {
        item.quantity = item.product?.stock || 999
        ElMessage.warning('库存不足')
        return
      }
      
      try {
        await updateCartItem(item.id, { quantity: item.quantity })
        ElMessage.success('数量已更新')
      } catch (err) {
        ElMessage.error('更新数量失败')
      }
    }
    
    // 删除商品
    const removeItem = async (item) => {
      try {
        await ElMessageBox.confirm(
          '确定要删除这个商品吗？',
          '确认删除',
          {
            confirmButtonText: '删除',
            cancelButtonText: '取消',
            type: 'warning',
          }
        )
        
        await removeFromCart(item.id)
        const index = cartItems.value.findIndex(i => i.id === item.id)
        if (index > -1) {
          cartItems.value.splice(index, 1)
        }
        ElMessage.success('商品已删除')
      } catch (err) {
        if (err !== 'cancel') {
          ElMessage.error('删除失败')
        }
      }
    }
    
    // 清空购物车
    const clearCart = async () => {
      try {
        await ElMessageBox.confirm(
          '确定要清空购物车吗？',
          '确认清空',
          {
            confirmButtonText: '清空',
            cancelButtonText: '取消',
            type: 'warning',
          }
        )
        
        await clearCart(userStore.userInfo.id)
        cartItems.value = []
        ElMessage.success('购物车已清空')
      } catch (err) {
        if (err !== 'cancel') {
          ElMessage.error('清空失败')
        }
      }
    }
    
    // 去结算
    const goToCheckout = () => {
      if (selectedItems.value.length === 0) {
        ElMessage.warning('请选择要结算的商品')
        return
      }
      
      // 将选中的商品ID和数量传递给结算页面
      const selectedData = selectedItems.value.map(item => ({
        product_id: item.product_id,
        sku_id: item.sku_id,
        quantity: item.quantity,
        price: item.sku?.price || item.product?.base_price || 0,
        product: item.product,  // 传递完整的商品信息
        sku: item.sku  // 传递完整的SKU信息
      }))
      
      // 传递购物车项目ID，用于订单创建后移除
      const cartItemIds = selectedItems.value.map(item => item.id)
      
      router.push({
        path: getClientPath('/mall/checkout'),
        query: { 
          items: JSON.stringify(selectedData),
          cart_item_ids: JSON.stringify(cartItemIds),
          from: 'cart'
        }
      })
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
      loadCart()
    })
    
    return {
      loading,
      cartItems,
      selectedItems,
      isAllSelected,
      totalAmount,
      updateSelectedItems,
      toggleSelectAll,
      decreaseQuantity,
      increaseQuantity,
      updateQuantity,
      removeItem,
      clearCart,
      goToCheckout,
      formatSpecifications,
      handleImageError,
      getClientPath,
      getImageUrl
    }
  }
}
</script>

<style scoped>
.mall-cart-page {
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

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #f0f0f0;
}

.cart-header h1 {
  font-size: 2rem;
  color: var(--color-text-primary);
  margin: 0;
}

.clear-cart-btn {
  padding: 8px 16px;
  background: #ff4757;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.clear-cart-btn:hover:not(:disabled) {
  background: #ff3742;
}

.clear-cart-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.empty-cart {
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

.empty-cart h3 {
  color: var(--color-text-primary);
  margin-bottom: 10px;
}

.empty-cart p {
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

.cart-items {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.select-all-row {
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
  background: #f8f9fa;
}

.select-all-checkbox {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  color: #666;
}

.select-all-checkbox input[type="checkbox"] {
  width: 16px;
  height: 16px;
}

.cart-item {
  display: grid;
  grid-template-columns: 50px 100px 1fr 150px 120px 80px;
  gap: 20px;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
}

.cart-item:last-child {
  border-bottom: none;
}

.item-checkbox input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.item-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
}

.item-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;
  font-size: 1.5rem;
}

.item-info {
  min-width: 0;
}

.item-title {
  margin: 0 0 8px 0;
  font-size: 1.1rem;
  color: var(--color-text-primary);
}

.item-title a {
  color: inherit;
  text-decoration: none;
}

.item-title a:hover {
  color: var(--color-primary);
}

.item-specs {
  margin: 0 0 8px 0;
  font-size: 0.9rem;
  color: var(--color-text-secondary);
}

.item-price {
  font-size: 1.1rem;
  color: #ff4757;
  font-weight: 600;
}

.quantity-controls {
  display: flex;
  align-items: center;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  overflow: hidden;
}

.quantity-btn {
  width: 32px;
  height: 32px;
  border: none;
  background: #f8f9fa;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  transition: background-color 0.3s;
}

.quantity-btn:hover:not(:disabled) {
  background: #e9ecef;
}

.quantity-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.quantity-input {
  width: 50px;
  height: 32px;
  border: none;
  text-align: center;
  font-size: 0.9rem;
  outline: none;
}

.item-subtotal {
  font-size: 1.1rem;
  color: #ff4757;
  font-weight: 600;
  text-align: right;
}

.remove-btn {
  padding: 6px 12px;
  background: #ff4757;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.remove-btn:hover {
  background: #ff3742;
}

.cart-summary {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 30px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.summary-info {
  display: flex;
  align-items: center;
  gap: 30px;
}

.selected-count {
  color: var(--color-text-secondary);
  font-size: 1rem;
}

.total-amount {
  font-size: 1.2rem;
  color: var(--color-text-primary);
}

.amount {
  color: #ff4757;
  font-weight: 700;
  font-size: 1.5rem;
}

.checkout-btn {
  padding: 15px 30px;
  background: #ff4757;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1.1rem;
  font-weight: 600;
  transition: background-color 0.3s;
}

.checkout-btn:hover:not(:disabled) {
  background: #ff3742;
}

.checkout-btn:disabled {
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

@media (max-width: 768px) {
  .cart-item {
    grid-template-columns: 1fr;
    gap: 15px;
    text-align: center;
  }
  
  .item-checkbox {
    order: 1;
  }
  
  .item-image {
    order: 2;
    margin: 0 auto;
  }
  
  .item-info {
    order: 3;
  }
  
  .item-quantity {
    order: 4;
  }
  
  .item-subtotal {
    order: 5;
    text-align: center;
  }
  
  .item-actions {
    order: 6;
  }
  
  .cart-summary {
    flex-direction: column;
    gap: 20px;
    text-align: center;
  }
  
  .summary-info {
    flex-direction: column;
    gap: 10px;
  }
}
</style>