<template>
  <div class="cart-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <div class="cart-header">
          <h1>购物车</h1>
          <p v-if="cartItems.length === 0 && !loading" class="empty-cart-message">购物车是空的，去 <router-link to="/all-products">选购商品</router-link> 吧！</p>
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
                  <i class="icon-delete"></i>
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
                <span>总计: </span>
                <span class="total-amount">¥{{ totalAmount.toFixed(2) }}</span>
              </div>
            </div>
            
            <div class="cart-actions">
              <button class="clear-cart-btn" @click="clearCart">
                清空购物车
              </button>
              <button 
                class="checkout-btn" 
                @click="goToCheckout"
                :disabled="selectedCount === 0"
              >
                去结算 ({{ selectedCount }})
              </button>
            </div>
          </div>
        </div>

        <!-- 空购物车状态 -->
        <div v-else class="empty-cart">
          <div class="empty-cart-icon">🛒</div>
          <h2>购物车是空的</h2>
          <p>快去选购心仪的商品吧！</p>
          <router-link to="/all-products" class="shop-now-btn">
            立即购物
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
import { getCart, updateCartItem, removeFromCart, clearCart as clearCartAPI } from '@/api/cart'
import { userStore } from '@/store/user'
import { getImageUrl } from '@/utils/imageUtils'

export default {
  name: 'ClientCart',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    
    // 响应式数据
    const cartItems = ref([])
    const loading = ref(false)
    
    // 计算属性
    const selectedItems = computed(() => {
      return cartItems.value.filter(item => item.selected)
    })
    
    const selectedCount = computed(() => {
      return selectedItems.value.length
    })
    
    const totalAmount = computed(() => {
      return selectedItems.value.reduce((total, item) => {
        const price = parseFloat(item.price || 0)
        const quantity = parseInt(item.quantity || 0)
        return total + (price * quantity)
      }, 0)
    })
    
    // 加载购物车数据
    const loadCart = async () => {
      if (!userStore.isLoggedIn) {
        ElMessage.warning('请先登录')
        router.push('/login')
        return
      }
      
      try {
        loading.value = true
        console.log('开始加载购物车，用户ID:', userStore.userInfo.id)
        
        const response = await getCart(userStore.userInfo.id)
        console.log('购物车API响应:', response)
        console.log('购物车响应数据:', response.data)
        
        if (!response.data || !response.data.items) {
          console.warn('购物车数据格式不正确')
          cartItems.value = []
          return
        }
        
        console.log('购物车项数量:', response.data.items.length)
        
        // 处理嵌套的数据结构，提取所需信息
        cartItems.value = response.data.items.map((item, index) => {
          console.log(`处理第${index + 1}个购物车项:`, item)
          
          const sku = item.sku
          console.log(`第${index + 1}项的SKU:`, sku)
          
          const product = sku?.product
          console.log(`第${index + 1}项的产品:`, product)
          
          // 提取规格信息
          let specifications = {}
          if (sku?.sku_specs && sku.sku_specs.length > 0) {
            console.log(`第${index + 1}项的规格:`, sku.sku_specs)
            sku.sku_specs.forEach(spec => {
              if (spec.spec_value && spec.spec_value.specification) {
                specifications[spec.spec_value.specification.name] = spec.spec_value.value
              }
            })
          }
          const specificationsList = Object.keys(specifications).map(name => ({ name, value: specifications[name] }))
          
          const processedItem = {
            id: item.id,
            sku_id: item.sku_id,
            quantity: item.quantity,
            selected: true, // 默认选中
            // 产品信息
            product_title: product?.title || '未知产品',
            product_image: product?.images && product.images.length > 0 ? product.images[0] : null,
            // SKU信息
            sku_code: sku?.sku_code || `SKU${sku?.id || 'unknown'}`,
            price: parseFloat(sku?.price || 0) || 0,
            stock: parseInt(sku?.stock || 0) || 0,
            // 规格信息
            specifications,
            specificationsList
          }
          
          console.log(`第${index + 1}项处理后的数据:`, processedItem)
          return processedItem
        })
        
        console.log('最终购物车数据:', cartItems.value)
      } catch (error) {
        console.error('加载购物车失败:', error)
        if (error.response?.status === 500) {
          ElMessage.error('服务器内部错误，请稍后重试')
        } else if (error.response?.status === 404) {
          ElMessage.warning('购物车为空')
          cartItems.value = []
        } else {
          ElMessage.error('加载购物车失败，请检查网络连接')
        }
        cartItems.value = []
      } finally {
        loading.value = false
      }
    }
    
    // 更新商品数量
    const updateItemQuantity = async (item) => {
      try {
        await updateCartItem(userStore.userInfo.id, item.id, item.quantity)
        ElMessage.success('数量更新成功')
      } catch (error) {
        console.error('更新数量失败:', error)
        ElMessage.error('更新数量失败')
        // 恢复原数量
        loadCart()
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
      if (!itemId) {
        console.error('无效的商品ID:', itemId)
        ElMessage.error('无效的商品ID')
        return
      }
      
      try {
        await ElMessageBox.confirm('确定要删除这个商品吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        
        console.log('删除商品，ID:', itemId)
        await removeFromCart(userStore.userInfo.id, itemId)
        ElMessage.success('商品已删除')
        await loadCart() // 重新加载购物车
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除商品失败:', error)
          ElMessage.error('删除商品失败，请重试')
        }
      }
    }
    
    // 清空购物车
    const clearCart = async () => {
      try {
        await ElMessageBox.confirm('确定要清空购物车吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        
        await clearCartAPI(userStore.userInfo.id)
        ElMessage.success('购物车已清空')
        cartItems.value = []
      } catch (error) {
        if (error !== 'cancel') {
          console.error('清空购物车失败:', error)
          ElMessage.error('清空购物车失败')
        }
      }
    }
    
    // 去结算
    const goToCheckout = () => {
      if (selectedCount.value === 0) {
        ElMessage.warning('请选择要结算的商品')
        return
      }
      
      // 将选中的商品信息传递到结算页面
      const selectedItemsData = selectedItems.value.map(item => ({
        sku_id: item.sku_id,
        quantity: item.quantity,
        price: item.price,
        product_title: item.product_title,
        sku_code: item.sku_code,
        product_image: item.product_image,
        specifications: item.specifications
      }))
      
      router.push({
        path: '/checkout',
        query: {
          items: JSON.stringify(selectedItemsData)
        }
      })
    }
    
    // 更新总计
    const updateTotal = () => {
      // 触发计算属性重新计算
    }
    
    onMounted(() => {
      loadCart()
    })
    
    return {
      cartItems,
      loading,
      selectedCount,
      totalAmount,
      getImageUrl,
      increaseQuantity,
      decreaseQuantity,
      updateItemQuantity,
      removeItem,
      clearCart,
      goToCheckout,
      updateTotal
    }
  }
}
</script>

<style scoped>
.cart-page {
  min-height: 100vh;
  background-color: #f8fafc;
}

.main-content {
  padding: 40px 0;
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
  color: #1e293b;
  margin-bottom: 10px;
}

.empty-cart-message {
  color: #64748b;
  font-size: 1.1rem;
}

.empty-cart-message a {
  color: #3b82f6;
  text-decoration: none;
}

.empty-cart-message a:hover {
  text-decoration: underline;
}

.cart-content {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.cart-items {
  padding: 20px;
}

.cart-item {
  display: grid;
  grid-template-columns: 50px 100px 1fr 120px 150px 120px 80px;
  gap: 20px;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #e2e8f0;
  transition: background-color 0.2s;
}

.cart-item:hover {
  background-color: #f8fafc;
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
  background-color: #f1f5f9;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
}

.item-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.item-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #1e293b;
  margin: 0;
}

.item-sku {
  font-size: 0.9rem;
  color: #64748b;
  margin: 0;
}

.item-specs {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.spec-tag {
  background-color: #e2e8f0;
  color: #475569;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
}

.item-price {
  text-align: center;
}

.price {
  font-size: 1.2rem;
  font-weight: 600;
  color: #dc2626;
}

.item-quantity {
  text-align: center;
}

.quantity-controls {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-bottom: 8px;
}

.quantity-btn {
  width: 32px;
  height: 32px;
  border: 1px solid #d1d5db;
  background: white;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  transition: all 0.2s;
}

.quantity-btn:hover:not(:disabled) {
  background-color: #f3f4f6;
}

.quantity-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.quantity-input {
  width: 50px;
  height: 32px;
  text-align: center;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 1rem;
}

.stock-info {
  font-size: 0.8rem;
  color: #64748b;
  margin: 0;
}

.item-total {
  text-align: center;
}

.total-price {
  font-size: 1.3rem;
  font-weight: 700;
  color: #dc2626;
}

.item-actions {
  text-align: center;
}

.remove-btn {
  background: none;
  border: 1px solid #ef4444;
  color: #ef4444;
  padding: 6px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 4px;
}

.remove-btn:hover {
  background-color: #ef4444;
  color: white;
}

.cart-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background-color: #f8fafc;
  border-top: 1px solid #e2e8f0;
}

.cart-summary {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.summary-item {
  font-size: 1.1rem;
  color: #374151;
}

.total-amount {
  font-size: 1.5rem;
  font-weight: 700;
  color: #dc2626;
}

.cart-actions {
  display: flex;
  gap: 15px;
}

.clear-cart-btn {
  background: none;
  border: 1px solid #6b7280;
  color: #6b7280;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.clear-cart-btn:hover {
  background-color: #6b7280;
  color: white;
}

.checkout-btn {
  background-color: #dc2626;
  border: none;
  color: white;
  padding: 12px 32px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1.1rem;
  font-weight: 600;
  transition: all 0.2s;
}

.checkout-btn:hover:not(:disabled) {
  background-color: #b91c1c;
  transform: translateY(-2px);
}

.checkout-btn:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
  transform: none;
}

.empty-cart {
  text-align: center;
  padding: 80px 20px;
}

.empty-cart-icon {
  font-size: 4rem;
  margin-bottom: 20px;
}

.empty-cart h2 {
  font-size: 2rem;
  color: #374151;
  margin-bottom: 10px;
}

.empty-cart p {
  color: #6b7280;
  font-size: 1.1rem;
  margin-bottom: 30px;
}

.shop-now-btn {
  display: inline-block;
  background-color: #3b82f6;
  color: white;
  padding: 15px 30px;
  border-radius: 8px;
  text-decoration: none;
  font-size: 1.1rem;
  font-weight: 600;
  transition: all 0.2s;
}

.shop-now-btn:hover {
  background-color: #2563eb;
  transform: translateY(-2px);
}

/* 加载状态样式 */
.loading-section {
  text-align: center;
  padding: 60px 20px;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-section p {
  color: #64748b;
  font-size: 1.1rem;
}

/* 响应式设计 */
@media (max-width: 768px) {
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
    gap: 20px;
    text-align: center;
  }
  
  .cart-actions {
    flex-direction: column;
    width: 100%;
  }
  
  .checkout-btn,
  .clear-cart-btn {
    width: 100%;
  }
}
</style> 