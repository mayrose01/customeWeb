<template>
  <div class="mall-category-detail-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 分类头部信息 -->
        <div class="category-header" v-if="category">
          <div class="category-info">
            <div class="category-image">
              <img 
                v-if="category.image && getImageUrl(category.image)"
                :src="getImageUrl(category.image)" 
                :alt="category.name"
                @error="handleImageError"
              />
              <div v-else class="category-icon">
                <span>📦</span>
              </div>
            </div>
            <div class="category-details">
              <h1>{{ category.name }}</h1>
              <p class="category-description">{{ category.description || '暂无描述' }}</p>
              <div class="category-stats">
                <span>{{ products.length }} 个产品</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 面包屑导航 -->
        <nav class="breadcrumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>
              <router-link :to="getClientPath('/mall')">商城首页</router-link>
            </el-breadcrumb-item>
            <el-breadcrumb-item>
              <router-link :to="getClientPath('/mall/categories')">商品分类</router-link>
            </el-breadcrumb-item>
            <el-breadcrumb-item v-if="category">{{ category.name }}</el-breadcrumb-item>
          </el-breadcrumb>
        </nav>

        <!-- 商品列表 -->
        <div class="products-section">
          <div class="section-header">
            <h2>{{ category ? category.name : '分类' }}商品</h2>
            <div class="view-options">
              <el-button-group>
                <el-button 
                  :type="viewMode === 'grid' ? 'primary' : 'default'"
                  @click="viewMode = 'grid'"
                  icon="Grid"
                >
                  网格视图
                </el-button>
                <el-button 
                  :type="viewMode === 'list' ? 'primary' : 'default'"
                  @click="viewMode = 'list'"
                  icon="List"
                >
                  列表视图
                </el-button>
              </el-button-group>
            </div>
          </div>

          <!-- 加载状态 -->
          <div v-if="loading" class="loading-container">
            <el-skeleton :rows="3" animated />
          </div>

          <!-- 商品网格 -->
          <div v-else-if="viewMode === 'grid'" class="products-grid">
            <div 
              v-for="product in products" 
              :key="product.id"
              class="product-card"
            >
              <div class="product-image">
                <img 
                  v-if="getProductMainImage(product)"
                  :src="getImageUrl(getProductMainImage(product))" 
                  :alt="product.title"
                  @error="handleImageError"
                  @click="goToProduct(product.id)"
                />
                <div v-else class="no-image">
                  <el-icon><Picture /></el-icon>
                  <span>暂无图片</span>
                </div>
                <div class="product-actions">
                  <el-button 
                    type="primary" 
                    size="small"
                    @click="addToCart(product)"
                    :loading="addingToCart === product.id"
                  >
                    加入购物车
                  </el-button>
                  <el-button 
                    type="success" 
                    size="small"
                    @click="buyNow(product)"
                    :loading="buyingNow === product.id"
                  >
                    立即购买
                  </el-button>
                </div>
              </div>
              <div class="product-info">
                <h3 @click="goToProduct(product.id)">{{ product.title }}</h3>
                <p class="product-description">{{ getProductDescription(product) }}</p>
                <div class="product-price">
                  <span class="current-price">¥{{ getProductPrice(product) }}</span>
                  <span v-if="product.original_price && product.original_price > getProductPrice(product)" 
                        class="original-price">¥{{ product.original_price }}</span>
                </div>
                <div class="product-stock">
                  <span :class="{'in-stock': getProductStock(product) > 0, 'out-of-stock': getProductStock(product) === 0}">
                    {{ getProductStock(product) > 0 ? `库存 ${getProductStock(product)}` : '缺货' }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- 商品列表 -->
          <div v-else class="products-list">
            <div 
              v-for="product in products" 
              :key="product.id"
              class="product-item"
            >
              <div class="product-image">
                <img 
                  v-if="getProductMainImage(product)"
                  :src="getImageUrl(getProductMainImage(product))" 
                  :alt="product.title"
                  @error="handleImageError"
                  @click="goToProduct(product.id)"
                />
                <div v-else class="no-image">
                  <el-icon><Picture /></el-icon>
                </div>
              </div>
              <div class="product-info">
                <h3 @click="goToProduct(product.id)">{{ product.title }}</h3>
                <p class="product-description">{{ getProductDescription(product) }}</p>
                <div class="product-meta">
                  <div class="product-price">
                    <span class="current-price">¥{{ getProductPrice(product) }}</span>
                    <span v-if="product.original_price && product.original_price > getProductPrice(product)" 
                          class="original-price">¥{{ product.original_price }}</span>
                  </div>
                  <div class="product-stock">
                    <span :class="{'in-stock': getProductStock(product) > 0, 'out-of-stock': getProductStock(product) === 0}">
                      {{ getProductStock(product) > 0 ? `库存 ${getProductStock(product)}` : '缺货' }}
                    </span>
                  </div>
                </div>
              </div>
              <div class="product-actions">
                <el-button 
                  type="primary" 
                  @click="addToCart(product)"
                  :loading="addingToCart === product.id"
                  :disabled="getProductStock(product) === 0"
                >
                  加入购物车
                </el-button>
                <el-button 
                  type="success" 
                  @click="buyNow(product)"
                  :loading="buyingNow === product.id"
                  :disabled="getProductStock(product) === 0"
                >
                  立即购买
                </el-button>
              </div>
            </div>
          </div>

          <!-- 空状态 -->
          <div v-if="!loading && products.length === 0" class="empty-state">
            <el-empty description="该分类下暂无商品">
              <el-button type="primary" @click="goToCategories">浏览其他分类</el-button>
            </el-empty>
          </div>
        </div>
      </div>
    </main>

    <ClientFooter />
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Picture } from '@element-plus/icons-vue'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getClientPath } from '@/utils/pathUtils'
import { getMallCategories } from '@/api/mall_category'
import { getMallProducts } from '@/api/mall_product'
import { getBestSkuForProduct } from '@/api/mall_product'
import { addToCart as addToCartAPI } from '@/api/mall_cart'
import { userStore } from '@/store/user'

export default {
  name: 'MallCategoryDetail',
  components: {
    ClientHeader,
    ClientFooter,
    Picture
  },
  setup() {
    const route = useRoute()
    const router = useRouter()
    
    const category = ref(null)
    const products = ref([])
    const loading = ref(true)
    const viewMode = ref('grid')
    const addingToCart = ref(null)
    const buyingNow = ref(null)
    
    const categoryId = computed(() => parseInt(route.params.id))
    
    // 加载分类信息
    const loadCategory = async () => {
      try {
        const response = await getMallCategories()
        const categories = response.data
        const foundCategory = categories.find(cat => cat.id === categoryId.value)
        if (foundCategory) {
          category.value = foundCategory
        } else {
          ElMessage.error('分类不存在')
          router.push(getClientPath('/mall/categories'))
        }
      } catch (error) {
        console.error('加载分类失败:', error)
        ElMessage.error('加载分类失败')
      }
    }
    
    // 加载分类下的商品
    const loadProducts = async () => {
      try {
        loading.value = true
        const response = await getMallProducts({
          category_id: categoryId.value,
          page: 1,
          page_size: 100 // 获取更多商品
        })
        products.value = response.data.items || []
      } catch (error) {
        console.error('加载商品失败:', error)
        ElMessage.error('加载商品失败')
        products.value = []
      } finally {
        loading.value = false
      }
    }
    
    // 获取图片URL
    const getImageUrl = (imagePath) => {
      if (!imagePath) return null
      if (imagePath.startsWith('http')) return imagePath
      // 从API_BASE_URL中移除/api路径，因为图片不需要API前缀
      const baseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api'
      const imageBaseUrl = baseUrl.replace('/api', '')
      const fullUrl = `${imageBaseUrl}${imagePath}`
      console.log('构建图片URL:', imagePath, '->', fullUrl)
      return fullUrl
    }
    
    // 获取商品主图
    const getProductMainImage = (product) => {
      console.log('获取商品主图:', product.title, product.images)
      if (product.images && product.images.length > 0) {
        return product.images[0]
      }
      return null
    }
    
    // 获取商品描述（清理HTML标签）
    const getProductDescription = (product) => {
      if (!product.description) return '暂无描述'
      
      // 移除HTML标签，只保留纯文本
      const tempDiv = document.createElement('div')
      tempDiv.innerHTML = product.description
      const textContent = tempDiv.textContent || tempDiv.innerText || ''
      
      // 截取前100个字符，避免描述过长
      return textContent.length > 100 ? textContent.substring(0, 100) + '...' : textContent
    }
    
    // 处理图片加载错误
    const handleImageError = (event) => {
      event.target.style.display = 'none'
    }
    
    // 获取商品价格
    const getProductPrice = (product) => {
      if (product.skus && product.skus.length > 0) {
        const minPrice = Math.min(...product.skus.map(sku => sku.price))
        return minPrice.toFixed(2)
      }
      return (product.price || 0).toFixed(2)
    }
    
    // 获取商品库存
    const getProductStock = (product) => {
      if (product.skus && product.skus.length > 0) {
        return product.skus.reduce((total, sku) => total + sku.stock, 0)
      }
      return product.stock || 0
    }
    
    // 跳转到商品详情
    const goToProduct = (productId) => {
      console.log('跳转到商品详情:', productId)
      const path = getClientPath(`/mall/product/${productId}`)
      console.log('跳转路径:', path)
      router.push(path)
    }
    
    // 跳转到分类列表
    const goToCategories = () => {
      router.push(getClientPath('/mall/categories'))
    }
    
    // 添加到购物车
    const addToCart = async (product) => {
      try {
        console.log('添加到购物车的产品:', product)
        if (!product || !product.id) {
          console.error('产品ID不存在:', product)
          ElMessage.error('产品信息错误，无法添加到购物车')
          return
        }
        
        if (!userStore.isLoggedIn || !userStore.userInfo) {
          ElMessage.warning('请先登录')
          router.push(getClientPath('/login'))
          return
        }
        
        addingToCart.value = product.id
        const userId = userStore.userInfo.id
        const skuResponse = await getBestSkuForProduct(product.id)
        const sku = skuResponse.data
        
        const cartData = {
          product_id: product.id,
          sku_id: sku.id,
          quantity: 1
        }
        
        await addToCartAPI(userId, cartData)
        ElMessage.success('已添加到购物车')
      } catch (error) {
        console.error('添加到购物车失败:', error)
        if (error.response && error.response.status === 404) {
          ElMessage.error('产品暂无可用库存')
        } else {
          ElMessage.error('添加失败')
        }
      } finally {
        addingToCart.value = null
      }
    }
    
    // 立即购买
    const buyNow = async (product) => {
      try {
        console.log('立即购买的产品:', product)
        if (!product || !product.id) {
          console.error('产品ID不存在:', product)
          ElMessage.error('产品信息错误，无法立即购买')
          return
        }
        
        if (!userStore.isLoggedIn || !userStore.userInfo) {
          ElMessage.warning('请先登录')
          router.push(getClientPath('/login'))
          return
        }
        
        buyingNow.value = product.id
        const userId = userStore.userInfo.id
        const skuResponse = await getBestSkuForProduct(product.id)
        const sku = skuResponse.data
        
        // 先添加到购物车
        const cartData = {
          product_id: product.id,
          sku_id: sku.id,
          quantity: 1
        }
        
        await addToCartAPI(userId, cartData)
        
        // 然后跳转到结算页面
        router.push(getClientPath('/mall/checkout'))
        ElMessage.success('已加入购物车，跳转到结算页面')
      } catch (error) {
        console.error('立即购买失败:', error)
        if (error.response && error.response.status === 404) {
          ElMessage.error('产品暂无可用库存')
        } else {
          ElMessage.error('购买失败')
        }
      } finally {
        buyingNow.value = null
      }
    }
    
    onMounted(async () => {
      await loadCategory()
      await loadProducts()
    })
    
    return {
      category,
      products,
      loading,
      viewMode,
      addingToCart,
      buyingNow,
      getImageUrl,
      getProductMainImage,
      getProductDescription,
      handleImageError,
      getProductPrice,
      getProductStock,
      goToProduct,
      goToCategories,
      addToCart,
      buyNow,
      getClientPath
    }
  }
}
</script>

<style scoped>
.mall-category-detail-page {
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

/* 分类头部 */
.category-header {
  margin-bottom: 40px;
  padding: 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  color: white;
}

.category-info {
  display: flex;
  align-items: center;
  gap: 30px;
}

.category-image {
  width: 120px;
  height: 120px;
  border-radius: 12px;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
}

.category-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.category-icon {
  font-size: 3rem;
  opacity: 0.7;
}

.category-details h1 {
  font-size: 2.5rem;
  margin-bottom: 10px;
  font-weight: 700;
}

.category-description {
  font-size: 1.1rem;
  opacity: 0.9;
  margin-bottom: 15px;
  line-height: 1.6;
}

.category-stats {
  font-size: 1rem;
  opacity: 0.8;
}

/* 面包屑导航 */
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

/* 商品区域 */
.products-section {
  margin-top: 40px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;
}

.section-header h2 {
  font-size: 1.8rem;
  color: var(--color-text-primary);
  margin: 0;
}

/* 网格视图 */
.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 25px;
}

.product-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.product-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.product-image {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.product-image img:hover {
  transform: scale(1.05);
}

.no-image {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  color: #999;
}

.no-image .el-icon {
  font-size: 2rem;
  margin-bottom: 8px;
}

.product-actions {
  position: absolute;
  top: 10px;
  right: 10px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.product-card:hover .product-actions {
  opacity: 1;
}

.product-info {
  padding: 20px;
}

.product-info h3 {
  font-size: 1.1rem;
  margin-bottom: 8px;
  color: var(--color-text-primary);
  cursor: pointer;
  transition: color 0.3s ease;
}

.product-info h3:hover {
  color: var(--color-primary);
}

.product-description {
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  margin-bottom: 12px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.product-price {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.current-price {
  font-size: 1.2rem;
  font-weight: 600;
  color: #e74c3c;
}

.original-price {
  font-size: 0.9rem;
  color: #999;
  text-decoration: line-through;
}

.product-stock {
  font-size: 0.85rem;
}

.in-stock {
  color: #27ae60;
}

.out-of-stock {
  color: #e74c3c;
}

/* 列表视图 */
.products-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.product-item {
  display: flex;
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.product-item:hover {
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.product-item .product-image {
  width: 200px;
  height: 150px;
  flex-shrink: 0;
}

.product-item .product-info {
  flex: 1;
  padding: 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.product-item .product-info h3 {
  font-size: 1.3rem;
  margin-bottom: 10px;
}

.product-item .product-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
}

.product-item .product-actions {
  padding: 20px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 10px;
  border-left: 1px solid #f0f0f0;
}

/* 加载状态 */
.loading-container {
  padding: 40px 0;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 60px 20px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .category-info {
    flex-direction: column;
    text-align: center;
    gap: 20px;
  }
  
  .category-details h1 {
    font-size: 2rem;
  }
  
  .products-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
  }
  
  .product-item {
    flex-direction: column;
  }
  
  .product-item .product-image {
    width: 100%;
    height: 200px;
  }
  
  .product-item .product-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .product-item .product-actions {
    border-left: none;
    border-top: 1px solid #f0f0f0;
    flex-direction: row;
  }
  
  .section-header {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }
}
</style>