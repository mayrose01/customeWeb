<template>
  <div class="cart-container">
    <div class="cart-header">
      <h2>我的购物车</h2>
      <el-button 
        v-if="cartItems.length > 0" 
        type="danger" 
        @click="clearCart"
        :loading="clearing"
      >
        清空购物车
      </el-button>
    </div>
    
    <div v-if="loading" class="loading-container">
      <el-skeleton :rows="3" animated />
    </div>
    
    <div v-else-if="cartItems.length === 0" class="empty-cart">
      <el-empty description="购物车是空的" />
      <el-button type="primary" @click="$router.push('/categories')">
        去购物
      </el-button>
    </div>
    
    <div v-else class="cart-content">
      <!-- 购物车商品列表 -->
      <div class="cart-items">
        <div 
          v-for="item in cartItems" 
          :key="item.id" 
          class="cart-item"
        >
          <div class="item-image">
            <el-image 
              v-if="item.sku && item.sku.product && item.sku.product.images && item.sku.product.images.length > 0"
              :src="getImageUrl(item.sku.product.images[0])" 
              fit="cover"
              :preview-src-list="item.sku.product.images.map(img => getImageUrl(img))"
            />
            <div v-else class="no-image">无图片</div>
          </div>
          
          <div class="item-info">
            <h4 class="item-title">
              {{ item.sku?.product?.title || '商品标题' }}
            </h4>
            <p class="item-model">
              型号: {{ item.sku?.product?.model || '未知型号' }}
            </p>
            <p class="item-sku">
              SKU: {{ item.sku?.sku_code || '未知SKU' }}
            </p>
          </div>
          
          <div class="item-price">
            <span class="price">¥{{ item.sku?.price || '0.00' }}</span>
          </div>
          
          <div class="item-quantity">
            <el-input-number 
              v-model="item.quantity" 
              :min="1" 
              :max="99"
              size="small"
              @change="(value) => updateQuantity(item.id, value)"
              :loading="item.updating"
            />
          </div>
          
          <div class="item-subtotal">
            <span class="subtotal">
              ¥{{ ((item.sku?.price || 0) * item.quantity).toFixed(2) }}
            </span>
          </div>
          
          <div class="item-actions">
            <el-button 
              type="danger" 
              size="small" 
              @click="removeItem(item.id)"
              :loading="item.removing"
            >
              删除
            </el-button>
          </div>
        </div>
      </div>
      
      <!-- 购物车底部 -->
      <div class="cart-footer">
        <div class="cart-summary">
          <div class="summary-item">
            <span>商品总数:</span>
            <span class="summary-value">{{ totalQuantity }}</span>
          </div>
          <div class="summary-item">
            <span>商品种类:</span>
            <span class="summary-value">{{ cartItems.length }}</span>
          </div>
          <div class="summary-item total">
            <span>总计:</span>
            <span class="summary-value total-price">¥{{ totalAmount.toFixed(2) }}</span>
          </div>
        </div>
        
        <div class="cart-actions">
          <el-button @click="$router.push('/categories')">
            继续购物
          </el-button>
          <el-button 
            type="primary" 
            size="large"
            @click="checkout"
            :loading="checkingOut"
          >
            去结算
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getUserCart, updateCartItemQuantity, removeFromCart, clearCart as clearCartApi } from '../../api/cart'

const router = useRouter()

// 响应式数据
const loading = ref(false)
const clearing = ref(false)
const checkingOut = ref(false)
const cartItems = ref([])

// 计算属性
const totalQuantity = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + item.quantity, 0)
})

const totalAmount = computed(() => {
  return cartItems.value.reduce((sum, item) => {
    return sum + ((item.sku?.price || 0) * item.quantity)
  }, 0)
})

// 获取购物车数据
const fetchCart = async () => {
  loading.value = true
  try {
    const response = await getUserCart()
    cartItems.value = response.data.items || []
  } catch (error) {
    console.error('获取购物车失败:', error)
    ElMessage.error('获取购物车失败')
  } finally {
    loading.value = false
  }
}

// 更新商品数量
const updateQuantity = async (itemId, quantity) => {
  const item = cartItems.value.find(i => i.id === itemId)
  if (!item) return
  
  item.updating = true
  try {
    await updateCartItemQuantity(itemId, quantity)
    ElMessage.success('数量更新成功')
  } catch (error) {
    console.error('更新数量失败:', error)
    ElMessage.error('更新数量失败')
    // 恢复原数量
    await fetchCart()
  } finally {
    item.updating = false
  }
}

// 删除商品
const removeItem = async (itemId) => {
  try {
    await ElMessageBox.confirm('确定要删除这个商品吗？', '确认删除', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const item = cartItems.value.find(i => i.id === itemId)
    if (item) item.removing = true
    
    await removeFromCart(itemId)
    ElMessage.success('商品已删除')
    await fetchCart()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除商品失败:', error)
      ElMessage.error('删除商品失败')
    }
  }
}

// 清空购物车
const clearCart = async () => {
  try {
    await ElMessageBox.confirm('确定要清空购物车吗？此操作不可恢复。', '确认清空', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    clearing.value = true
    await clearCartApi()
    ElMessage.success('购物车已清空')
    cartItems.value = []
  } catch (error) {
    if (error !== 'cancel') {
      console.error('清空购物车失败:', error)
      ElMessage.error('清空购物车失败')
    }
  } finally {
    clearing.value = false
  }
}

// 去结算
const checkout = () => {
  if (cartItems.value.length === 0) {
    ElMessage.warning('购物车是空的')
    return
  }
  
  // 跳转到结算页面，传递购物车数据
  router.push({
    path: '/checkout',
    query: { 
      from: 'cart',
      items: JSON.stringify(cartItems.value.map(item => ({
        id: item.id,
        sku_id: item.sku_id,
        quantity: item.quantity,
        price: item.sku?.price,
        product_title: item.sku?.product?.title,
        sku_code: item.sku?.sku_code
      })))
    }
  })
}

// 获取图片URL
const getImageUrl = (imagePath) => {
  if (!imagePath) return ''
  if (imagePath.startsWith('http')) return imagePath
  return `${import.meta.env.VITE_API_BASE_URL}/uploads/${imagePath}`
}

// 组件挂载时获取数据
onMounted(() => {
  fetchCart()
})
</script>

<style scoped>
.cart-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #f0f0f0;
}

.cart-header h2 {
  margin: 0;
  color: #333;
}

.loading-container {
  padding: 40px;
}

.empty-cart {
  text-align: center;
  padding: 60px 20px;
}

.cart-content {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.cart-items {
  padding: 0;
}

.cart-item {
  display: flex;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
  transition: background-color 0.3s;
}

.cart-item:hover {
  background-color: #f9f9f9;
}

.cart-item:last-child {
  border-bottom: none;
}

.item-image {
  width: 80px;
  height: 80px;
  margin-right: 20px;
  flex-shrink: 0;
}

.item-image .el-image {
  width: 100%;
  height: 100%;
  border-radius: 4px;
}

.no-image {
  width: 100%;
  height: 100%;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;
  border-radius: 4px;
}

.item-info {
  flex: 1;
  margin-right: 20px;
}

.item-title {
  margin: 0 0 8px 0;
  font-size: 16px;
  color: #333;
}

.item-model, .item-sku {
  margin: 4px 0;
  color: #666;
  font-size: 14px;
}

.item-price {
  width: 100px;
  text-align: center;
  margin-right: 20px;
}

.price {
  font-size: 18px;
  font-weight: bold;
  color: #e74c3c;
}

.item-quantity {
  width: 120px;
  text-align: center;
  margin-right: 20px;
}

.item-subtotal {
  width: 100px;
  text-align: center;
  margin-right: 20px;
}

.subtotal {
  font-size: 16px;
  font-weight: bold;
  color: #e74c3c;
}

.item-actions {
  width: 80px;
  text-align: center;
}

.cart-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: #f9f9f9;
  border-top: 1px solid #e0e0e0;
}

.cart-summary {
  display: flex;
  gap: 30px;
}

.summary-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}

.summary-item span:first-child {
  color: #666;
  font-size: 14px;
}

.summary-value {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.summary-item.total .summary-value {
  font-size: 20px;
  color: #e74c3c;
}

.cart-actions {
  display: flex;
  gap: 15px;
}

@media (max-width: 768px) {
  .cart-container {
    padding: 10px;
  }
  
  .cart-header {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }
  
  .cart-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }
  
  .item-image {
    width: 100%;
    height: 200px;
    margin-right: 0;
  }
  
  .item-info {
    margin-right: 0;
    width: 100%;
  }
  
  .cart-footer {
    flex-direction: column;
    gap: 20px;
    align-items: stretch;
  }
  
  .cart-summary {
    justify-content: space-around;
  }
  
  .cart-actions {
    justify-content: center;
  }
}
</style> 