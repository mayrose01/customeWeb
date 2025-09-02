<template>
  <div class="mall-cart-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <div class="cart-header">
          <h1>购物车</h1>
          <p v-if="cartItems.length === 0 && !loading" class="empty-cart-message">
            购物车是空的，去 <router-link :to="getClientPath('/mall/products')">选购商品</router-link> 吧！
          </p>
        </div>

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载购物车...</p>
        </div>

        <!-- 购物车内容 -->
        <div v-else-if="cartItems.length > 0" class="cart-content">
          <!-- 购物车商品列表 -->
          <div class="cart-items">
            <div 
              v-for="item in cartItems" 
              :key="item.id" 
              class="cart-item"
            >
              <div class="item-select">
                <input 
                  type="checkbox" 
                  v-model="item.selected"
                  @change="updateTotal"
                />
              </div>
              
              <div class="item-image">
                <img 
                  v-if="item.product_image" 
                  :src="getImageUrl(item.product_image)" 
                  :alt="item.product_title"
                />
                <div v-else class="image-placeholder">
                  <span>📦</span>
                </div>
              </div>
              
              <div class="item-info">
                <h3 class="item-title">{{ item.product_title }}</h3>
                <div class="item-specs" v-if="item.specificationsList && item.specificationsList.length">
                  <span 
                    v-for="spec in item.specificationsList" 
                    :key="spec.name"
                    class="spec-tag"
                  >
                    {{ spec.name }}：{{ spec.value }}
                  </span>
                </div>
              </div>
              
              <div class="item-price">
                <span class="price">¥{{ parseFloat(item.price || 0).toFixed(2) }}</span>
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
                    :max="item.stock"
                    @change="updateItemQuantity(item)"
                  />
                  <button 
                    class="quantity-btn" 
                    @click="increaseQuantity(item)"
                    :disabled="item.quantity >= item.stock"
                  >
                    +
                  </button>
                </div>
                <p class="stock-info">库存: {{ item.stock }}</p>
              </div>
              
              <div class="item-total">
                <span class="total-price">¥{{ (parseFloat(item.price || 0) * item.quantity).toFixed(2) }}</span>
              </div>
              
              <div class="item-actions">
                <button type="button" class="remove-btn" @click.stop="removeItem(item.id)">
                  <i class="icon-delete">🗑️</i>
                  删除
                </button>
              </div>
            </div>
          </div>

          <!-- 购物车底部 -->
          <div class="cart-footer">
            <div class="cart-summary">
              <div class="summary-item">
                <span>已选择 {{ selectedCount }} 件商品</span>
              </div>
              <div class="summary-item">
                <span>商品总价：</span>
                <span class="total-amount">¥{{ totalAmount.toFixed(2) }}</span>
              </div>
              <div class="summary-item">
                <span>运费：</span>
                <span class="shipping-fee">¥{{ shippingFee.toFixed(2) }}</span>
              </div>
              <div class="summary-item total">
                <span>应付总额：</span>
                <span class="final-amount">¥{{ finalAmount.toFixed(2) }}</span>
              </div>
            </div>
            
            <div class="cart-actions">
              <button class="clear-cart-btn" @click="clearCart">
                清空购物车
              </button>
              <button class="checkout-btn" @click="goToCheckout" :disabled="selectedCount === 0">
                去结算 ({{ selectedCount }})
              </button>
            </div>
          </div>
        </div>

        <!-- 空购物车状态 -->
        <div v-if="!loading && cartItems.length === 0" class="empty-cart">
          <div class="empty-cart-icon">🛒</div>
          <h2>购物车是空的</h2>
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
  name: 'MallCart',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    
    const cartItems = ref([])
    const loading = ref(true)
    const shippingFee = ref(0)
    
    // 加载购物车数据
    const loadCart = async () => {
      try {
        loading.value = true
        // TODO: 调用API加载购物车数据
        // const response = await getMallCart()
        // cartItems.value = response.data
        
        // 模拟数据
        cartItems.value = [
          {
            id: 1,
            product_id: 1,
            product_title: '智能手机',
            product_image: '',
            price: 2999,
            quantity: 1,
            stock: 50,
            selected: true,
            specificationsList: [
              { name: '颜色', value: '黑色' },
              { name: '存储', value: '256GB' }
            ]
          },
          {
            id: 2,
            product_id: 2,
            product_title: '无线耳机',
            product_image: '',
            price: 299,
            quantity: 2,
            stock: 100,
            selected: true,
            specificationsList: [
              { name: '颜色', value: '白色' }
            ]
          }
        ]
        
        // 计算运费
        shippingFee.value = totalAmount.value > 99 ? 0 : 10
      } catch (error) {
        console.error('加载购物车失败:', error)
        ElMessage.error('加载购物车失败')
      } finally {
        loading.value = false
      }
    }
    
    // 计算属性
    const selectedCount = computed(() => {
      return cartItems.value.filter(item => item.selected).length
    })
    
    const totalAmount = computed(() => {
      return cartItems.value
        .filter(item => item.selected)
        .reduce((total, item) => total + (parseFloat(item.price || 0) * item.quantity), 0)
    })
    
    const finalAmount = computed(() => {
      return totalAmount.value + shippingFee.value
    })
    
    // 更新商品数量
    const updateItemQuantity = async (item) => {
      try {
        // TODO: 调用API更新购物车商品数量
        // await updateMallCartItem(item.id, { quantity: item.quantity })
        updateTotal()
        ElMessage.success('数量更新成功')
      } catch (error) {
        ElMessage.error('数量更新失败')
      }
    }
    
    // 增加数量
    const increaseQuantity = (item) => {
      if (item.quantity < item.stock) {
        item.quantity++
        updateItemQuantity(item)
      }
    }
    
    // 减少数量
    const decreaseQuantity = (item) => {
      if (item.quantity > 1) {
        item.quantity--
        updateItemQuantity(item)
      }
    }
    
    // 删除商品
    const removeItem = async (itemId) => {
      try {
        await ElMessageBox.confirm('确定要删除这个商品吗？', '提示', {
          type: 'warning'
        })
        
        // TODO: 调用API删除购物车商品
        // await removeMallCartItem(itemId)
        
        cartItems.value = cartItems.value.filter(item => item.id !== itemId)
        updateTotal()
        ElMessage.success('商品已删除')
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('删除失败')
        }
      }
    }
    
    // 清空购物车
    const clearCart = async () => {
      try {
        await ElMessageBox.confirm('确定要清空购物车吗？', '提示', {
          type: 'warning'
        })
        
        // TODO: 调用API清空购物车
        // await clearMallCart()
        
        cartItems.value = []
        updateTotal()
        ElMessage.success('购物车已清空')
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('清空失败')
        }
      }
    }
    
    // 更新总计
    const updateTotal = () => {
      // 重新计算运费
      shippingFee.value = totalAmount.value > 99 ? 0 : 10
    }
    
    // 去结算
    const goToCheckout = () => {
      if (selectedCount.value === 0) {
        ElMessage.warning('请选择要结算的商品')
        return
      }
      
      const selectedItems = cartItems.value.filter(item => item.selected)
      const itemIds = selectedItems.map(item => item.id)
      
      router.push({
        path: getClientPath('/mall/checkout'),
        query: { 
          cart_items: itemIds.join(',')
        }
      })
    }
    
    onMounted(() => {
      loadCart()
    })
    
    return {
      cartItems,
      loading,
      shippingFee,
      selectedCount,
      totalAmount,
      finalAmount,
      updateItemQuantity,
      increaseQuantity,
      decreaseQuantity,
      removeItem,
      clearCart,
      updateTotal,
      goToCheckout,
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

.cart-header {
  text-align: center;
  margin-bottom: 40px;
}

.cart-header h1 {
  font-size: 2.5rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.empty-cart-message {
  color: var(--color-text-secondary);
}

.empty-cart-message a {
  color: var(--color-primary);
  text-decoration: none;
}

.empty-cart-message a:hover {
  text-decoration: underline;
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

.cart-content {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.cart-items {
  padding: 20px;
}

.cart-item {
  display: grid;
  grid-template-columns: 50px 100px 1fr 120px 150px 120px 100px;
  gap: 20px;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
  transition: background-color 0.3s;
}

.cart-item:hover {
  background-color: #f8f9fa;
}

.cart-item:last-child {
  border-bottom: none;
}

.item-select input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.item-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
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
  background: #f5f5f5;
  color: #999;
  font-size: 1.5rem;
}

.item-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.item-title {
  font-size: 1.1rem;
  color: var(--color-text-primary);
  margin: 0;
  line-height: 1.3;
}

.item-specs {
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

.item-price {
  text-align: center;
}

.price {
  font-size: 1.2rem;
  color: #ff4757;
  font-weight: 600;
}

.item-quantity {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.quantity-controls {
  display: flex;
  align-items: center;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  overflow: hidden;
}

.quantity-btn {
  width: 30px;
  height: 30px;
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
  height: 30px;
  border: none;
  text-align: center;
  font-size: 0.9rem;
  outline: none;
}

.stock-info {
  font-size: 0.8rem;
  color: var(--color-text-secondary);
  margin: 0;
}

.item-total {
  text-align: center;
}

.total-price {
  font-size: 1.3rem;
  color: #ff4757;
  font-weight: 700;
}

.item-actions {
  text-align: center;
}

.remove-btn {
  background: none;
  border: none;
  color: #dc3545;
  cursor: pointer;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: color 0.3s;
}

.remove-btn:hover {
  color: #c82333;
}

.cart-footer {
  background: #f8f9fa;
  padding: 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.cart-summary {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  gap: 20px;
  font-size: 1rem;
}

.summary-item.total {
  font-size: 1.2rem;
  font-weight: 700;
  color: var(--color-text-primary);
  border-top: 1px solid #e5e7eb;
  padding-top: 10px;
}

.total-amount,
.final-amount {
  color: #ff4757;
  font-weight: 600;
}

.shipping-fee {
  color: var(--color-text-secondary);
}

.cart-actions {
  display: flex;
  gap: 15px;
}

.clear-cart-btn,
.checkout-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.clear-cart-btn {
  background: #6c757d;
  color: white;
}

.clear-cart-btn:hover {
  background: #5a6268;
}

.checkout-btn {
  background: var(--color-primary);
  color: white;
}

.checkout-btn:hover:not(:disabled) {
  background: var(--color-primary-hover);
  transform: translateY(-2px);
}

.checkout-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.empty-cart {
  text-align: center;
  padding: 100px 0;
}

.empty-cart-icon {
  font-size: 5rem;
  margin-bottom: 20px;
}

.empty-cart h2 {
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.empty-cart p {
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

@media (max-width: 1024px) {
  .cart-item {
    grid-template-columns: 1fr;
    gap: 15px;
    text-align: center;
  }
  
  .item-image {
    margin: 0 auto;
  }
  
  .cart-footer {
    flex-direction: column;
    align-items: stretch;
  }
  
  .cart-actions {
    justify-content: center;
  }
}

@media (max-width: 768px) {
  .cart-header h1 {
    font-size: 2rem;
  }
  
  .cart-items {
    padding: 15px;
  }
  
  .cart-footer {
    padding: 20px;
  }
}
</style>
