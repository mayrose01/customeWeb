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
                <div class="current-price">¥{{ parseFloat(product.price || 0).toFixed(2) }}</div>
                <div v-if="product.original_price" class="original-price">原价: ¥{{ parseFloat(product.original_price).toFixed(2) }}</div>
                <div v-if="product.discount" class="discount-tag">{{ product.discount }}折优惠</div>
              </div>

              <div class="product-specs" v-if="product.specifications && product.specifications.length > 0">
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

              <div class="product-stock">
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
                      :disabled="quantity >= product.stock"
                    >
                      +
                    </button>
                  </div>
                </div>
                
                <div class="action-buttons">
                  <button class="add-to-cart-btn" @click="addToCart">
                    <span class="btn-icon">🛒</span>
                    加入购物车
                  </button>
                  <button class="buy-now-btn" @click="buyNow">
                    <span class="btn-icon">⚡</span>
                    立即购买
                  </button>
                </div>
              </div>

              <div class="product-description" v-if="product.description">
                <h3>产品描述</h3>
                <div v-html="product.description"></div>
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
import { ElMessage } from 'element-plus'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getClientPath } from '@/utils/pathUtils'
import { getImageUrl } from '@/utils/imageUtils'

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
    
    // 加载产品数据
    const loadProduct = async () => {
      try {
        loading.value = true
        error.value = ''
        
        // TODO: 调用API加载产品数据
        // const response = await getMallProduct(route.params.id)
        // product.value = response.data
        
        // 模拟数据
        product.value = {
          id: route.params.id,
          title: '智能手机',
          model: 'SM-G998B',
          price: 2999,
          original_price: 3299,
          discount: 9,
          stock: 50,
          description: '这是一款高性能智能手机，采用最新的处理器和摄像头技术。',
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
      } catch (err) {
        error.value = '产品信息加载失败，请稍后重试'
        console.error('加载产品失败:', err)
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
      if (quantity.value < product.value.stock) {
        quantity.value++
      }
    }
    
    // 加入购物车
    const addToCart = async () => {
      try {
        // TODO: 检查用户是否登录
        // TODO: 调用API添加到购物车
        ElMessage.success(`已添加 ${quantity.value} 件商品到购物车`)
      } catch (err) {
        ElMessage.error('添加失败')
      }
    }
    
    // 立即购买
    const buyNow = () => {
      try {
        // TODO: 检查用户是否登录
        router.push({
          path: getClientPath('/mall/checkout'),
          query: { 
            product_id: product.value.id, 
            quantity: quantity.value 
          }
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
      setCurrentImage,
      decreaseQuantity,
      increaseQuantity,
      addToCart,
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
  font-size: 14px;
  color: var(--color-text-muted);
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
