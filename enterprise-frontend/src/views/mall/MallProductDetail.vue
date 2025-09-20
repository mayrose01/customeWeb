<template>
  <div class="mall-product-detail-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 面包屑导航 -->
        <div class="breadcrumb">
          <router-link :to="getClientPath('/mall')">商城首页</router-link>
          <span class="separator">/</span>
          <router-link :to="getClientPath('/mall/products')">商品列表</router-link>
          <span class="separator">/</span>
          <span>{{ product.title }}</span>
        </div>

        <!-- 产品详情 -->
        <div class="product-detail" v-if="!loading && product.id">
          <div class="product-gallery">
            <div class="main-image">
              <img 
                v-if="currentImage && currentImage.trim()" 
                :src="getImageUrl(currentImage)" 
                :alt="product.title"
                @error="handleImageError"
                @load="handleImageLoad"
              />
              <div v-else class="image-placeholder">
                <span>📦</span>
                <p>暂无图片</p>
              </div>
            </div>
            <div class="image-thumbnails" v-if="product.images && product.images.length > 1">
              <div 
                v-for="(image, index) in product.images" 
                :key="index"
                class="thumbnail"
                :class="{ active: currentImageIndex === index }"
                @click="setCurrentImage(index)"
              >
                <img 
                  v-if="image && image.trim()"
                  :src="getImageUrl(image)" 
                  :alt="`${product.title} - 图片 ${index + 1}`"
                  @error="handleThumbnailError"
                />
                <div v-else class="thumbnail-placeholder">
                  <span>📦</span>
                </div>
              </div>
            </div>
          </div>

          <div class="product-info">
            <div class="product-info-container">
              <div class="product-header">
                <h1 class="product-title">{{ product.title }}</h1>
                <p class="product-model" v-if="product.model">型号: {{ product.model }}</p>
              </div>

              <div class="product-price-section">
                <div class="current-price">¥{{ parseFloat(getCurrentPrice()).toFixed(2) }}</div>
                <div v-if="product.original_price" class="original-price">原价: ¥{{ parseFloat(product.original_price).toFixed(2) }}</div>
                <div v-if="product.discount" class="discount-tag">{{ product.discount }}折优惠</div>
              </div>

              <!-- SKU规格选择 -->
              <div class="product-sku-selection" v-if="product.skus && product.skus.length > 0">
                <h3>选择规格</h3>
                <div class="sku-specs">
                  <template v-for="spec in product.specifications" :key="spec.id">
                    <div 
                      v-if="spec && spec.values && spec.values.length > 0"
                      class="sku-spec-group"
                    >
                      <div class="spec-label">{{ spec.name }}:</div>
                      <div class="spec-options">
                        <button
                          v-for="value in spec.values"
                          :key="value.id"
                          class="spec-option"
                          :class="{ 
                            active: selectedSpecs[spec.name] === value.value,
                            disabled: !isSpecValueAvailable(spec.name, value.value)
                          }"
                          @click="selectSpec(spec.name, value.value)"
                          :disabled="!isSpecValueAvailable(spec.name, value.value)"
                        >
                          {{ value.value }}
                        </button>
                      </div>
                    </div>
                  </template>
                  
                  <!-- 当有SKU但没有规格值时，显示SKU选项 -->
                  <div 
                    v-if="product.skus && product.skus.length > 0 && !hasSpecValues()"
                    class="sku-direct-selection"
                  >
                    <div class="spec-label">选择规格:</div>
                    <div class="spec-options">
                      <button
                        v-for="sku in product.skus"
                        :key="sku.id"
                        class="spec-option"
                        :class="{ 
                          active: selectedSKU && selectedSKU.id === sku.id
                        }"
                        @click="selectSKUDirectly(sku)"
                      >
                        {{ formatSKUDisplay(sku) }}
                      </button>
                    </div>
                  </div>
                </div>
                <div class="selected-sku-info" v-if="selectedSKU">
                  <div class="sku-price">价格: ¥{{ selectedSKU.price.toFixed(2) }}</div>
                  <div class="sku-stock">库存: {{ selectedSKU.stock }} 件</div>
                </div>
                <div class="sku-selection-hint" v-else-if="product.specifications && product.specifications.length > 0">
                  <p>请选择规格</p>
                </div>
              </div>

              <!-- 传统规格显示（当没有SKU时） -->
              <div class="product-specs" v-else-if="product.specifications && product.specifications.length > 0">
                <h3>产品规格</h3>
                <div class="specs-grid">
                  <div 
                    v-for="spec in product.specifications" 
                    :key="spec.name"
                    class="spec-item"
                  >
                    <span class="spec-name">{{ spec.name }}:</span>
                    <span class="spec-value">{{ spec.value }}</span>
                  </div>
                </div>
              </div>

              <div class="product-stock" v-if="!selectedSKU">
                <span class="stock-label">库存:</span>
                <span class="stock-value">{{ product.stock || 0 }} 件</span>
              </div>

              <div class="product-actions">
                <div class="quantity-section">
                  <label>数量:</label>
                  <div class="quantity-controls">
                    <button 
                      class="quantity-btn" 
                      @click="decreaseQuantity"
                      :disabled="quantity <= 1"
                    >
                      -
                    </button>
                    <input 
                      type="number" 
                      v-model="quantity" 
                      class="quantity-input"
                      min="1"
                      :max="product.stock"
                    />
                    <button 
                      class="quantity-btn" 
                      @click="increaseQuantity"
                      :disabled="quantity >= getMaxQuantity()"
                    >
                      +
                    </button>
                  </div>
                </div>
                
                <div class="action-buttons">
                  <button 
                    class="add-to-cart-btn" 
                    @click="addToCartHandler"
                    :disabled="!hasStock()"
                  >
                    <span class="btn-icon">🛒</span>
                    加入购物车
                  </button>
                  <button 
                    class="buy-now-btn" 
                    @click="buyNow"
                    :disabled="!hasStock()"
                  >
                    <span class="btn-icon">⚡</span>
                    立即购买
                  </button>
                </div>
              </div>

              <div class="product-description" v-if="product.description">
                <h3>产品描述</h3>
                <div class="rich-text-content" v-html="product.description"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载产品信息...</p>
        </div>

        <!-- 错误状态 -->
        <div v-if="error" class="error-section">
          <div class="error-icon">❌</div>
          <h3>加载失败</h3>
          <p>{{ error }}</p>
          <button class="back-btn" @click="goBack">返回上一页</button>
        </div>
      </div>
    </main>

    <ClientFooter />
  </div>
</template>

<script>
import { ref, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getClientPath } from '@/utils/pathUtils'
import { getImageUrl } from '@/utils/imageUtils'
import { getMallProduct } from '@/api/mall_product'
import { addToCart } from '@/api/mall_cart'
import { userStore } from '@/store/user'

export default {
  name: 'MallProductDetail',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    const product = ref({})
    const loading = ref(true)
    const error = ref('')
    const currentImageIndex = ref(0)
    const currentImage = ref('')
    const quantity = ref(1)
    
    // SKU选择相关
    const selectedSpecs = ref({}) // 已选择的规格
    const selectedSKU = ref(null) // 当前选中的SKU
    
    // 加载产品数据
    const loadProduct = async () => {
      try {
        loading.value = true
        error.value = ''
        
        // 调用API加载产品数据
        const response = await getMallProduct(route.params.id)
        
        if (response.data) {
          product.value = {
            ...response.data,
            price: response.data.base_price,
            images: response.data.images || [],
            specifications: response.data.specifications || []
          }
          
          
          // 确保描述字段有默认值
          if (!product.value.description) {
            product.value.description = '<p>暂无产品描述</p>'
          }
          
          if (product.value.images && product.value.images.length > 0) {
            currentImage.value = product.value.images[0]
          }
        } else {
          throw new Error('产品数据格式错误')
        }
      } catch (err) {
        console.error('加载产品失败:', err)
        // 如果API失败，使用模拟数据
        product.value = {
          id: route.params.id,
          title: '智能手机',
          model: 'SM-G998B',
          price: 2999,
          original_price: 3299,
          discount: 9,
          stock: 50,
          description: '<p>这是一款高性能智能手机，采用最新的处理器和摄像头技术。</p><h3>主要特点</h3><ul><li>高性能处理器</li><li>专业级摄像头</li><li>长续航电池</li></ul>',
          images: [],
          specifications: [
            { name: '屏幕尺寸', value: '6.8英寸' },
            { name: '处理器', value: '骁龙8 Gen 2' },
            { name: '内存', value: '12GB' },
            { name: '存储', value: '256GB' },
            { name: '摄像头', value: '108MP主摄' }
          ]
        }
        
        if (product.value.images && product.value.images.length > 0) {
          currentImage.value = product.value.images[0]
        }
      } finally {
        loading.value = false
      }
    }
    
    // 设置当前图片
    const setCurrentImage = (index) => {
      currentImageIndex.value = index
      currentImage.value = product.value.images[index]
    }
    
    // 数量控制
    const decreaseQuantity = () => {
      if (quantity.value > 1) {
        quantity.value--
      }
    }
    
    const increaseQuantity = () => {
      if (quantity.value < getMaxQuantity()) {
        quantity.value++
      }
    }
    
    // SKU选择相关方法
    const selectSpec = (specName, specValue) => {
      selectedSpecs.value[specName] = specValue
      updateSelectedSKU()
    }
    
    const updateSelectedSKU = () => {
      if (!product.value.skus || product.value.skus.length === 0) {
        selectedSKU.value = null
        return
      }
      
      // 检查是否所有规格都已选择
      const requiredSpecs = (product.value.specifications || []).filter(spec => 
        spec && spec.values && spec.values.length > 0
      )
      const selectedSpecCount = Object.keys(selectedSpecs.value).length
      
      if (selectedSpecCount < requiredSpecs.length) {
        selectedSKU.value = null
        return
      }
      
      // 查找匹配的SKU
      const matchingSKU = product.value.skus.find(sku => {
        if (!sku.specifications) return false
        
        return Object.keys(selectedSpecs.value).every(specName => {
          return sku.specifications[specName] === selectedSpecs.value[specName]
        })
      })
      
      selectedSKU.value = matchingSKU || null
      
      // 重置数量为1
      if (selectedSKU.value) {
        quantity.value = 1
      }
    }
    
    const isSpecValueAvailable = (specName, specValue) => {
      if (!product.value.skus || product.value.skus.length === 0) {
        return true
      }
      
      // 检查是否有SKU包含这个规格值
      return product.value.skus.some(sku => {
        if (!sku || !sku.specifications) return false
        return sku.specifications[specName] === specValue
      })
    }
    
    const getMaxQuantity = () => {
      if (selectedSKU.value) {
        return selectedSKU.value.stock
      }
      return product.value.stock || 0
    }
    
    const canAddToCart = () => {
      // 如果有SKU，必须选择完整的规格
      if (product.value.skus && product.value.skus.length > 0) {
        return selectedSKU.value !== null && selectedSKU.value.stock > 0
      }
      // 如果没有SKU，检查产品库存
      return (product.value.stock || 0) > 0
    }
    
    const hasStock = () => {
      // 只检查是否有库存，不检查规格选择
      if (product.value.skus && product.value.skus.length > 0) {
        // 如果有SKU，检查是否有任何SKU有库存
        return product.value.skus.some(sku => sku && sku.stock > 0)
      }
      // 如果没有SKU，检查产品库存
      return (product.value.stock || 0) > 0
    }
    
    const hasSpecValues = () => {
      if (!product.value.specifications || product.value.specifications.length === 0) {
        return false
      }
      return product.value.specifications.some(spec => 
        spec && spec.values && spec.values.length > 0
      )
    }
    
    // 获取当前价格
    const getCurrentPrice = () => {
      if (selectedSKU.value) {
        return selectedSKU.value.price
      }
      return product.value.price || product.value.base_price || 0
    }
    
    const selectSKUDirectly = (sku) => {
      selectedSKU.value = sku
      quantity.value = 1
    }
    
    const formatSKUDisplay = (sku) => {
      if (sku.specifications) {
        const specText = Object.entries(sku.specifications)
          .map(([key, value]) => `${key}: ${value}`)
          .join(', ')
        return `${specText} - ¥${sku.price}`
      }
      return `${sku.sku_code} - ¥${sku.price}`
    }
    
    // 检查用户登录状态
    const checkLoginStatus = () => {
      if (!userStore.isLoggedIn) {
        ElMessageBox.confirm(
          '请先登录后再进行此操作',
          '需要登录',
          {
            confirmButtonText: '去登录',
            cancelButtonText: '取消',
            type: 'warning',
          }
        ).then(() => {
          router.push({
            path: getClientPath('/login'),
            query: { redirect: route.fullPath }
          })
        }).catch(() => {
          // 用户取消登录
        })
        return false
      }
      return true
    }
    
    // 加入购物车
    const addToCartHandler = async () => {
      if (!checkLoginStatus()) {
        return
      }
      
      // 检查是否选择了规格
      if (product.value.skus && product.value.skus.length > 0 && !selectedSKU.value) {
        ElMessageBox.alert(
          '请先选择商品规格！',
          '提示',
          {
            confirmButtonText: '知道了',
            type: 'warning',
            customClass: 'spec-selection-alert'
          }
        )
        return
      }
      
      try {
        const cartData = {
          product_id: product.value.id,
          sku_id: selectedSKU.value ? selectedSKU.value.id : null,
          quantity: quantity.value
        }
        
        await addToCart(userStore.userInfo.id, cartData)
        ElMessage.success(`已添加 ${quantity.value} 件商品到购物车`)
      } catch (err) {
        console.error('添加到购物车失败:', err)
        ElMessage.error('添加失败')
      }
    }
    
    // 立即购买
    const buyNow = () => {
      if (!checkLoginStatus()) {
        return
      }
      
      // 检查是否选择了规格
      if (product.value.skus && product.value.skus.length > 0 && !selectedSKU.value) {
        ElMessageBox.alert(
          '请先选择商品规格！',
          '提示',
          {
            confirmButtonText: '知道了',
            type: 'warning',
            customClass: 'spec-selection-alert'
          }
        )
        return
      }
      
      try {
        const query = { 
          product_id: product.value.id, 
          quantity: quantity.value 
        }
        
        if (selectedSKU.value) {
          query.sku_id = selectedSKU.value.id
        }
        
        router.push({
          path: getClientPath('/mall/checkout'),
          query: query
        })
      } catch (err) {
        ElMessage.error('操作失败')
      }
    }
    
    // 图片处理
    const handleImageError = (event) => {
      console.error('图片加载失败:', event.target.src)
      event.target.style.display = 'none'
      const placeholder = event.target.parentElement.querySelector('.image-placeholder')
      if (placeholder) {
        placeholder.style.display = 'flex'
      }
    }
    
    const handleImageLoad = () => {
      const placeholder = document.querySelector('.main-image .image-placeholder')
      if (placeholder) {
        placeholder.style.display = 'none'
      }
    }
    
    const handleThumbnailError = (event) => {
      event.target.style.display = 'none'
      const placeholder = event.target.parentElement.querySelector('.thumbnail-placeholder')
      if (placeholder) {
        placeholder.style.display = 'flex'
      }
    }
    
    // 返回上一页
    const goBack = () => {
      router.back()
    }
    
    // 监听路由参数变化
    watch(() => route.params.id, (newId) => {
      if (newId) {
        loadProduct()
      }
    })
    
    onMounted(() => {
      loadProduct()
    })
    
    return {
      product,
      loading,
      error,
      currentImageIndex,
      currentImage,
      quantity,
      selectedSpecs,
      selectedSKU,
      setCurrentImage,
      decreaseQuantity,
      increaseQuantity,
      selectSpec,
      isSpecValueAvailable,
      getMaxQuantity,
      canAddToCart,
      hasStock,
      hasSpecValues,
      getCurrentPrice,
      selectSKUDirectly,
      formatSKUDisplay,
      addToCartHandler,
      buyNow,
      handleImageError,
      handleImageLoad,
      handleThumbnailError,
      goBack,
      getClientPath,
      getImageUrl
    }
  }
}
</script>

<style scoped>
.mall-product-detail-page {
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

.product-detail {
  display: grid;
  grid-template-columns: minmax(400px, 1fr) minmax(500px, 1.2fr);
  gap: 60px;
  background: white;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.product-gallery {
  min-width: 400px;
}

.main-image {
  width: 100%;
  height: 400px;
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 20px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
}

.main-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #999;
  font-size: 3rem;
}

.image-placeholder p {
  margin-top: 10px;
  font-size: 1rem;
}

.image-thumbnails {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.thumbnail {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  border: 2px solid transparent;
  transition: border-color 0.3s;
}

.thumbnail.active {
  border-color: var(--color-primary);
}

.thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.thumbnail-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  color: #999;
  font-size: 1.5rem;
}

.product-info-container {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

.product-header h1 {
  font-size: 2rem;
  color: var(--color-text-primary);
  margin-bottom: 10px;
  line-height: 1.3;
}

.product-model {
  color: var(--color-text-secondary);
  font-size: 1rem;
}

.product-price-section {
  display: flex;
  align-items: center;
  gap: 15px;
  flex-wrap: wrap;
}

.current-price {
  font-size: 2.5rem;
  color: #ff4757;
  font-weight: 700;
}

.original-price {
  font-size: 1.2rem;
  color: #999;
  text-decoration: line-through;
}

.discount-tag {
  background: #ffa502;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.9rem;
  font-weight: 600;
}

/* SKU规格选择样式 */
.product-sku-selection {
  margin-bottom: 30px;
}

.product-sku-selection h3 {
  font-size: 1.2rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.sku-specs {
  margin-bottom: 20px;
}

.sku-spec-group {
  margin-bottom: 20px;
}

.spec-label {
  font-size: 14px;
  font-weight: 500;
  color: #666;
  margin-bottom: 8px;
}

.spec-options {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.spec-option {
  padding: 8px 16px;
  border: 2px solid #e9ecef;
  background: #fff;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 14px;
  color: #333;
}

.spec-option:hover:not(.disabled) {
  border-color: #007bff;
  color: #007bff;
}

.spec-option.active {
  border-color: #007bff;
  background: #007bff;
  color: #fff;
}

.spec-option.disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background: #f8f9fa;
  color: #999;
}

.selected-sku-info {
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #e9ecef;
}

.sku-price {
  font-size: 16px;
  font-weight: 600;
  color: #e74c3c;
  margin-bottom: 5px;
}

.sku-stock {
  font-size: 14px;
  color: #666;
}

.sku-selection-hint {
  padding: 15px;
  background: #fff3cd;
  border: 1px solid #ffeaa7;
  border-radius: 8px;
  text-align: center;
}

.sku-selection-hint p {
  margin: 0;
  color: #856404;
  font-size: 14px;
}

/* 规格选择提示弹窗样式 */
:deep(.spec-selection-alert) {
  .el-message-box {
    border-radius: 15px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  }
  
  .el-message-box__title {
    font-size: 20px;
    font-weight: bold;
    color: #ff6b6b;
  }
  
  .el-message-box__content {
    font-size: 18px;
    color: #333;
    padding: 20px 0;
  }
  
  .el-message-box__btns {
    .el-button--primary {
      background: linear-gradient(135deg, #ff6b6b, #ff8e8e);
      border: none;
      border-radius: 25px;
      padding: 12px 30px;
      font-size: 16px;
      font-weight: bold;
    }
  }
}

.sku-direct-selection {
  margin-bottom: 20px;
}

.sku-direct-selection .spec-label {
  font-size: 14px;
  font-weight: 500;
  color: #666;
  margin-bottom: 8px;
}

.sku-direct-selection .spec-options {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.sku-direct-selection .spec-option {
  padding: 12px 16px;
  border: 2px solid #e9ecef;
  background: #fff;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 14px;
  color: #333;
  min-width: 120px;
  text-align: center;
}

.sku-direct-selection .spec-option:hover {
  border-color: #007bff;
  color: #007bff;
}

.sku-direct-selection .spec-option.active {
  border-color: #007bff;
  background: #007bff;
  color: #fff;
}

.product-specs h3 {
  font-size: 1.2rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.specs-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.spec-item {
  display: flex;
  justify-content: space-between;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 8px;
}

.spec-name {
  color: var(--color-text-secondary);
  font-weight: 500;
}

.spec-value {
  color: var(--color-text-primary);
  font-weight: 600;
}

.product-stock {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
}

.stock-label {
  color: var(--color-text-secondary);
  font-weight: 500;
}

.stock-value {
  color: var(--color-text-primary);
  font-weight: 600;
  font-size: 1.1rem;
}

.product-actions {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.quantity-section {
  display: flex;
  align-items: center;
  gap: 15px;
}

.quantity-section label {
  font-weight: 600;
  color: var(--color-text-primary);
}

.quantity-controls {
  display: flex;
  align-items: center;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  overflow: hidden;
}

.quantity-btn {
  width: 40px;
  height: 40px;
  border: none;
  background: #f8f9fa;
  cursor: pointer;
  font-size: 1.2rem;
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
  width: 60px;
  height: 40px;
  border: none;
  text-align: center;
  font-size: 1rem;
  outline: none;
}

.action-buttons {
  display: flex;
  gap: 15px;
}

.add-to-cart-btn,
.buy-now-btn {
  flex: 1;
  padding: 15px 20px;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.add-to-cart-btn {
  background: var(--color-primary);
  color: white;
}

.add-to-cart-btn:hover {
  background: var(--color-primary-hover);
  transform: translateY(-2px);
}

.buy-now-btn {
  background: #ff4757;
  color: white;
}

.buy-now-btn:hover {
  background: #ff3742;
  transform: translateY(-2px);
}

.btn-icon {
  font-size: 1.2rem;
}

.product-description h3 {
  font-size: 1.2rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.product-description {
  color: var(--color-text-secondary);
  line-height: 1.6;
}

/* 富文本内容样式 */
.rich-text-content {
  color: var(--color-text-primary);
  line-height: 1.8;
  font-size: 1rem;
}

.rich-text-content h1,
.rich-text-content h2,
.rich-text-content h3,
.rich-text-content h4,
.rich-text-content h5,
.rich-text-content h6 {
  color: var(--color-text-primary);
  margin: 20px 0 15px 0;
  font-weight: 600;
  line-height: 1.4;
}

.rich-text-content h1 { font-size: 1.8rem; }
.rich-text-content h2 { font-size: 1.6rem; }
.rich-text-content h3 { font-size: 1.4rem; }
.rich-text-content h4 { font-size: 1.2rem; }
.rich-text-content h5 { font-size: 1.1rem; }
.rich-text-content h6 { font-size: 1rem; }

.rich-text-content p {
  margin: 15px 0;
  color: var(--color-text-primary);
}

.rich-text-content strong,
.rich-text-content b {
  font-weight: 600;
  color: var(--color-text-primary);
}

.rich-text-content em,
.rich-text-content i {
  font-style: italic;
}

.rich-text-content u {
  text-decoration: underline;
}

.rich-text-content s,
.rich-text-content strike {
  text-decoration: line-through;
}

.rich-text-content blockquote {
  margin: 20px 0;
  padding: 15px 20px;
  background: #f8f9fa;
  border-left: 4px solid var(--color-primary);
  border-radius: 0 8px 8px 0;
  color: var(--color-text-secondary);
  font-style: italic;
}

.rich-text-content ul,
.rich-text-content ol {
  margin: 15px 0;
  padding-left: 30px;
}

.rich-text-content li {
  margin: 8px 0;
  color: var(--color-text-primary);
}

.rich-text-content ul li {
  list-style-type: disc;
}

.rich-text-content ol li {
  list-style-type: decimal;
}

.rich-text-content a {
  color: var(--color-primary);
  text-decoration: none;
  border-bottom: 1px solid transparent;
  transition: border-color 0.3s;
}

.rich-text-content a:hover {
  border-bottom-color: var(--color-primary);
}

.rich-text-content img {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  margin: 15px 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.rich-text-content video {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  margin: 15px 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.rich-text-content table {
  width: 100%;
  border-collapse: collapse;
  margin: 20px 0;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.rich-text-content th,
.rich-text-content td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #e5e7eb;
}

.rich-text-content th {
  background: #f8f9fa;
  font-weight: 600;
  color: var(--color-text-primary);
}

.rich-text-content td {
  color: var(--color-text-primary);
}

.rich-text-content tr:hover {
  background: #f8f9fa;
}

.rich-text-content code {
  background: #f1f3f4;
  color: #e83e8c;
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 0.9em;
}

.rich-text-content pre {
  background: #f8f9fa;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 15px;
  margin: 15px 0;
  overflow-x: auto;
}

.rich-text-content pre code {
  background: none;
  color: var(--color-text-primary);
  padding: 0;
  border-radius: 0;
}

.rich-text-content hr {
  border: none;
  height: 1px;
  background: #e5e7eb;
  margin: 30px 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .rich-text-content {
    font-size: 0.95rem;
  }
  
  .rich-text-content h1 { font-size: 1.5rem; }
  .rich-text-content h2 { font-size: 1.4rem; }
  .rich-text-content h3 { font-size: 1.3rem; }
  .rich-text-content h4 { font-size: 1.2rem; }
  .rich-text-content h5 { font-size: 1.1rem; }
  .rich-text-content h6 { font-size: 1rem; }
  
  .rich-text-content table {
    font-size: 0.9rem;
  }
  
  .rich-text-content th,
  .rich-text-content td {
    padding: 8px 10px;
  }
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

.error-section {
  text-align: center;
  padding: 100px 0;
}

.error-icon {
  font-size: 4rem;
  margin-bottom: 20px;
}

.error-section h3 {
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.error-section p {
  color: var(--color-text-secondary);
  margin-bottom: 25px;
}

.back-btn {
  padding: 12px 24px;
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.3s;
}

.back-btn:hover {
  background: var(--color-primary-hover);
}

@media (max-width: 1024px) {
  .product-detail {
    grid-template-columns: 1fr;
    gap: 40px;
    padding: 30px;
  }
  
  .product-gallery {
    min-width: auto;
  }
  
  .main-image {
    height: 300px;
  }
}

@media (max-width: 768px) {
  .product-detail {
    padding: 20px;
  }
  
  .main-image {
    height: 250px;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .specs-grid {
    grid-template-columns: 1fr;
  }
}
</style>
