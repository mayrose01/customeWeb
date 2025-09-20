<template>
  <div class="mall-home-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 商城横幅 -->
        <div class="mall-banner">
          <div class="banner-content">
            <h1>欢迎来到我们的商城</h1>
            <p>精选优质产品，品质保证，价格实惠</p>
            <router-link :to="getClientPath('/mall/products')" class="browse-btn">
              立即选购
            </router-link>
          </div>
        </div>

        <!-- 分类导航 -->
        <div class="categories-section">
          <h2 class="section-title">商品分类</h2>
          <div class="categories-grid">
            <div 
              v-for="category in categories" 
              :key="category.id"
              class="category-card"
              @click="goToCategory(category.id)"
            >
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
              <h3>{{ category.name }}</h3>
              <p>{{ category.description || '暂无描述' }}</p>
            </div>
          </div>
        </div>

        <!-- 热门产品 -->
        <div class="hot-products-section">
          <h2 class="section-title">热门产品</h2>
          <div class="products-grid">
            <div 
              v-for="product in hotProducts" 
              :key="product.id"
              class="product-card"
              @click="goToProduct(product.id)"
            >
              <div class="product-image">
                <img 
                  v-if="product.images && product.images.length > 0" 
                  :src="getImageUrl(product.images[0])" 
                  :alt="product.title"
                  @error="handleImageError"
                />
                <div v-else class="image-placeholder">
                  <span>📦</span>
                </div>
              </div>
              <div class="product-content">
                <h3 class="product-title">{{ product.title }}</h3>
                <p class="product-price">¥{{ parseFloat(product.price || 0).toFixed(2) }}</p>
                <div class="product-actions">
                  <button class="add-to-cart-btn" @click.stop="addToCart(product)">
                    加入购物车
                  </button>
                  <button class="buy-now-btn" @click.stop="buyNow(product)">
                    立即购买
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 新品推荐 -->
        <div class="new-products-section">
          <h2 class="section-title">新品推荐</h2>
          <div class="products-grid">
            <div 
              v-for="product in newProducts" 
              :key="product.id"
              class="product-card"
              @click="goToProduct(product.id)"
            >
              <div class="product-image">
                <img 
                  v-if="product.images && product.images.length > 0" 
                  :src="getImageUrl(product.images[0])" 
                  :alt="product.title"
                  @error="handleImageError"
                />
                <div v-else class="image-placeholder">
                  <span>📦</span>
                </div>
                <div class="new-badge">新品</div>
              </div>
              <div class="product-content">
                <h3 class="product-title">{{ product.title }}</h3>
                <p class="product-price">¥{{ parseFloat(product.price || 0).toFixed(2) }}</p>
                <div class="product-actions">
                  <button class="add-to-cart-btn" @click.stop="addToCart(product)">
                    加入购物车
                  </button>
                  <button class="buy-now-btn" @click.stop="buyNow(product)">
                    立即购买
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 商城特色 -->
        <div class="features-section">
          <h2 class="section-title">商城特色</h2>
          <div class="features-grid">
            <div class="feature-item">
              <div class="feature-icon">🚚</div>
              <h3>快速配送</h3>
              <p>全国包邮，快速送达</p>
            </div>
            <div class="feature-item">
              <div class="feature-icon">🛡️</div>
              <h3>品质保证</h3>
              <p>正品保证，假一赔十</p>
            </div>
            <div class="feature-item">
              <div class="feature-icon">💰</div>
              <h3>价格实惠</h3>
              <p>价格透明，优惠多多</p>
            </div>
            <div class="feature-item">
              <div class="feature-icon">🎯</div>
              <h3>专业服务</h3>
              <p>专业客服，贴心服务</p>
            </div>
          </div>
        </div>
      </div>
    </main>

    <ClientFooter />
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getClientPath } from '@/utils/pathUtils'
import { getImageUrl } from '@/utils/imageUtils'
import { getMallProducts, getBestSkuForProduct } from '@/api/mall_product'
import { getMallCategories } from '@/api/mall_category'
import { addToCart as addToCartAPI } from '@/api/mall_cart'
import { userStore } from '@/store/user'

export default {
  name: 'MallHome',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    
    const categories = ref([])
    const hotProducts = ref([])
    const newProducts = ref([])
    
    // 加载分类数据
    const loadCategories = async () => {
      try {
        const response = await getMallCategories()
        if (response.data) {
          // 只显示启用的分类
          categories.value = response.data.filter(cat => cat.status === 'active')
        } else {
          categories.value = []
        }
      } catch (error) {
        console.error('加载分类失败:', error)
        // 如果API失败，使用模拟数据
        categories.value = [
          { id: 1, name: '电子产品', description: '手机、电脑、配件等', status: 'active' },
          { id: 2, name: '服装鞋帽', description: '男装、女装、童装等', status: 'active' },
          { id: 3, name: '家居用品', description: '家具、装饰、厨具等', status: 'active' },
          { id: 4, name: '美妆护肤', description: '护肤品、彩妆、香水等', status: 'active' }
        ]
      }
    }
    
    // 加载热门产品
    const loadHotProducts = async () => {
      try {
        // 获取上架的产品作为热门产品
        const response = await getMallProducts({ status: 'active', limit: 4 })
        
        if (response.data && response.data.items) {
          hotProducts.value = response.data.items.map(item => ({
            ...item,
            title: item.title,
            price: item.base_price,
            images: item.images || []
          }))
        } else if (Array.isArray(response.data)) {
          hotProducts.value = response.data
            .filter(item => item.status === 'active')
            .slice(0, 4)
            .map(item => ({
              ...item,
              title: item.title,
              price: item.base_price,
              images: item.images || []
            }))
        } else {
          hotProducts.value = []
        }
      } catch (error) {
        console.error('加载热门产品失败:', error)
        // 如果API失败，使用模拟数据
        hotProducts.value = [
          { id: 1, title: '智能手机', price: 2999, images: [], status: 'active' },
          { id: 2, title: '无线耳机', price: 299, images: [], status: 'active' },
          { id: 3, title: '智能手表', price: 899, images: [], status: 'active' },
          { id: 4, title: '蓝牙音箱', price: 199, images: [], status: 'active' }
        ]
      }
    }
    
    // 加载新品
    const loadNewProducts = async () => {
      try {
        // 获取上架的产品作为新品（可以按创建时间排序）
        const response = await getMallProducts({ status: 'active', limit: 4, sort: 'created_at' })
        
        if (response.data && response.data.items) {
          newProducts.value = response.data.items.map(item => ({
            ...item,
            title: item.title,
            price: item.base_price,
            images: item.images || []
          }))
        } else if (Array.isArray(response.data)) {
          newProducts.value = response.data
            .filter(item => item.status === 'active')
            .slice(0, 4)
            .map(item => ({
              ...item,
              title: item.title,
              price: item.base_price,
              images: item.images || []
            }))
        } else {
          newProducts.value = []
        }
      } catch (error) {
        console.error('加载新品失败:', error)
        // 如果API失败，使用模拟数据
        newProducts.value = [
          { id: 5, title: '无线充电器', price: 89, images: [], status: 'active' },
          { id: 6, title: '便携充电宝', price: 129, images: [], status: 'active' },
          { id: 7, title: '手机支架', price: 39, images: [], status: 'active' },
          { id: 8, title: '数据线', price: 29, images: [], status: 'active' }
        ]
      }
    }
    
    // 跳转到分类页面
    const goToCategory = (categoryId) => {
      router.push(getClientPath(`/mall/categories/${categoryId}`))
    }
    
    // 跳转到产品详情
    const goToProduct = (productId) => {
      router.push(getClientPath(`/mall/product/${productId}`))
    }
    
    // 加入购物车
    const addToCart = async (product) => {
      try {
        console.log('添加到购物车的产品:', product)
        
        // 检查产品ID是否存在
        if (!product || !product.id) {
          console.error('产品ID不存在:', product)
          ElMessage.error('产品信息错误，无法添加到购物车')
          return
        }
        
        // 检查用户是否登录
        if (!userStore.isLoggedIn || !userStore.userInfo) {
          ElMessage.warning('请先登录')
          router.push(getClientPath('/login'))
          return
        }
        
        const userId = userStore.userInfo.id
        
        // 获取产品中价格最高且有库存的SKU
        const skuResponse = await getBestSkuForProduct(product.id)
        const sku = skuResponse.data
        
        // 添加到购物车
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
      }
    }
    
    // 立即购买
    const buyNow = async (product) => {
      try {
        console.log('立即购买的产品:', product)
        
        // 检查产品ID是否存在
        if (!product || !product.id) {
          console.error('产品ID不存在:', product)
          ElMessage.error('产品信息错误，无法立即购买')
          return
        }
        
        // 检查用户是否登录
        if (!userStore.isLoggedIn || !userStore.userInfo) {
          ElMessage.warning('请先登录')
          router.push(getClientPath('/login'))
          return
        }
        
        // 获取产品中价格最高且有库存的SKU
        const skuResponse = await getBestSkuForProduct(product.id)
        const sku = skuResponse.data
        
        // 跳转到结算页面，传递SKU信息
        router.push({
          path: getClientPath('/mall/checkout'),
          query: { 
            product_id: product.id, 
            sku_id: sku.id,
            quantity: 1 
          }
        })
      } catch (error) {
        console.error('立即购买失败:', error)
        if (error.response && error.response.status === 404) {
          ElMessage.error('产品暂无可用库存')
        } else {
          ElMessage.error('操作失败')
        }
      }
    }
    
    // 图片加载失败处理
    const handleImageError = (event) => {
      event.target.style.display = 'none'
      const placeholder = event.target.parentElement.querySelector('.image-placeholder')
      if (placeholder) {
        placeholder.style.display = 'flex'
      }
    }
    
    onMounted(() => {
      loadCategories()
      loadHotProducts()
      loadNewProducts()
    })
    
    return {
      categories,
      hotProducts,
      newProducts,
      goToCategory,
      goToProduct,
      addToCart,
      buyNow,
      handleImageError,
      getClientPath,
      getImageUrl
    }
  }
}
</script>

<style scoped>
.mall-home-page {
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

/* 商城横幅 */
.mall-banner {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 80px 40px;
  border-radius: 16px;
  text-align: center;
  margin-bottom: 60px;
}

.banner-content h1 {
  font-size: 3rem;
  margin-bottom: 20px;
  font-weight: 700;
}

.banner-content p {
  font-size: 1.2rem;
  margin-bottom: 30px;
  opacity: 0.9;
}

.browse-btn {
  display: inline-block;
  background: white;
  color: #667eea;
  padding: 15px 40px;
  border-radius: 50px;
  text-decoration: none;
  font-weight: 600;
  font-size: 1.1rem;
  transition: all 0.3s ease;
}

.browse-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}

/* 分类导航 */
.categories-section {
  margin-bottom: 60px;
}

.section-title {
  font-size: 2rem;
  color: var(--color-text-primary);
  margin-bottom: 30px;
  text-align: center;
}

.categories-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
}

.category-card {
  background: white;
  padding: 30px;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
}

.category-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.category-image {
  width: 100%;
  height: 160px;
  margin-bottom: 20px;
  border-radius: 8px;
  overflow: hidden;
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
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  color: #999;
}

.category-card h3 {
  font-size: 1.3rem;
  color: var(--color-text-primary);
  margin-bottom: 10px;
}

.category-card p {
  color: var(--color-text-secondary);
  line-height: 1.5;
}

/* 产品展示 */
.hot-products-section,
.new-products-section {
  margin-bottom: 60px;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 30px;
}

.product-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  position: relative;
}

.product-card:hover {
  transform: translateY(-5px);
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
  transition: transform 0.3s ease;
}

.product-card:hover .product-image img {
  transform: scale(1.05);
}

.image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  color: #999;
  font-size: 2rem;
}

.new-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background: #ff4757;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.product-content {
  padding: 20px;
}

.product-title {
  font-size: 1.1rem;
  color: var(--color-text-primary);
  margin-bottom: 10px;
  line-height: 1.4;
}

.product-price {
  font-size: 1.3rem;
  color: #ff4757;
  font-weight: 700;
  margin-bottom: 15px;
}

.product-actions {
  display: flex;
  gap: 10px;
}

.add-to-cart-btn,
.buy-now-btn {
  flex: 1;
  padding: 10px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.add-to-cart-btn {
  background: var(--color-primary);
  color: white;
}

.add-to-cart-btn:hover {
  background: var(--color-primary-hover);
}

.buy-now-btn {
  background: #ff4757;
  color: white;
}

.buy-now-btn:hover {
  background: #ff3742;
}

/* 商城特色 */
.features-section {
  margin-bottom: 60px;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
}

.feature-item {
  background: white;
  padding: 30px;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.feature-icon {
  font-size: 3rem;
  margin-bottom: 20px;
}

.feature-item h3 {
  font-size: 1.2rem;
  color: var(--color-text-primary);
  margin-bottom: 10px;
}

.feature-item p {
  color: var(--color-text-secondary);
  line-height: 1.5;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .mall-banner {
    padding: 60px 20px;
  }
  
  .banner-content h1 {
    font-size: 2rem;
  }
  
  .banner-content p {
    font-size: 1rem;
  }
  
  .categories-grid,
  .products-grid,
  .features-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .product-actions {
    flex-direction: column;
  }
}
</style>
