<template>
  <div class="mall-products-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <div class="page-header">
          <h1>商品列表</h1>
          <p>浏览所有商品，找到您心仪的产品</p>
        </div>

        <!-- 筛选和搜索 -->
        <div class="filters-section">
          <div class="search-box">
            <input 
              type="text" 
              placeholder="搜索商品..." 
              v-model="searchKeyword"
              @input="handleSearch"
            />
            <button @click="handleSearch">
              <i class="icon-search">🔍</i>
            </button>
          </div>
          
          <div class="category-filter">
            <select v-model="selectedCategory" @change="filterProducts">
              <option value="">所有分类</option>
              <option v-for="category in categories" :key="category.id" :value="category.id">
                {{ category.name }}
              </option>
            </select>
          </div>
          
          <div class="sort-filter">
            <select v-model="sortBy" @change="sortProducts">
              <option value="default">默认排序</option>
              <option value="price-asc">价格从低到高</option>
              <option value="price-desc">价格从高到低</option>
              <option value="newest">最新上架</option>
            </select>
          </div>
        </div>

        <!-- 产品统计 -->
        <div class="products-stats">
          <span>共找到 {{ filteredProducts.length }} 个商品</span>
        </div>

        <!-- 产品列表 -->
        <div v-if="!loading && filteredProducts.length > 0" class="products-grid">
          <div 
            v-for="product in filteredProducts" 
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
              <div v-if="product.is_new" class="new-badge">新品</div>
              <div v-if="product.discount" class="discount-badge">{{ product.discount }}折</div>
            </div>
            <div class="product-content">
              <h3 class="product-title">{{ product.title }}</h3>
              <p class="product-category">{{ product.category_name }}</p>
              <div class="product-price-section">
                <span class="current-price">¥{{ parseFloat(product.price || 0).toFixed(2) }}</span>
                <span v-if="product.original_price" class="original-price">¥{{ parseFloat(product.original_price).toFixed(2) }}</span>
              </div>
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

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载商品...</p>
        </div>

        <!-- 空状态 -->
        <div v-if="!loading && filteredProducts.length === 0" class="empty-state">
          <div class="empty-icon">📦</div>
          <h3>未找到商品</h3>
          <p>请尝试调整搜索条件或分类筛选</p>
        </div>

        <!-- 分页 -->
        <div v-if="totalPages > 1" class="pagination">
          <button 
            :disabled="currentPage === 1" 
            @click="changePage(currentPage - 1)"
            class="page-btn"
          >
            上一页
          </button>
          <span class="page-info">{{ currentPage }} / {{ totalPages }}</span>
          <button 
            :disabled="currentPage === totalPages" 
            @click="changePage(currentPage + 1)"
            class="page-btn"
          >
            下一页
          </button>
        </div>
      </div>
    </main>

    <ClientFooter />
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
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
  name: 'MallProducts',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    const products = ref([])
    const categories = ref([])
    const loading = ref(true)
    const searchKeyword = ref('')
    const selectedCategory = ref('')
    const sortBy = ref('default')
    const currentPage = ref(1)
    const totalPages = ref(1)
    
    // 加载产品数据
    const loadProducts = async () => {
      try {
        loading.value = true
        // 调用API加载产品数据，只获取上架的产品
        const response = await getMallProducts({ status: 'active' })
        
        if (response.data && response.data.items) {
          // 处理分页响应
          products.value = response.data.items.map(item => ({
            ...item,
            title: item.title,
            price: item.base_price,
            original_price: item.original_price,
            category_name: item.category?.name || '未分类',
            images: item.images || [],
            is_new: item.is_new || false,
            discount: item.discount
          }))
        } else if (Array.isArray(response.data)) {
          // 处理数组响应
          products.value = response.data
            .filter(item => item.status === 'active') // 只显示上架产品
            .map(item => ({
              ...item,
              title: item.title,
              price: item.base_price,
              original_price: item.original_price,
              category_name: item.category?.name || '未分类',
              images: item.images || [],
              is_new: item.is_new || false,
              discount: item.discount
            }))
        } else {
          products.value = []
        }
        
        // 加载分类数据
        const categoryResponse = await getMallCategories()
        if (categoryResponse.data) {
          categories.value = categoryResponse.data.filter(cat => cat.status === 'active')
        } else {
          categories.value = []
        }
        
        totalPages.value = Math.ceil(products.value.length / 8)
      } catch (error) {
        console.error('加载产品失败:', error)
        // 如果API失败，使用模拟数据（只包含上架产品）
        products.value = [
          { id: 1, title: '智能手机', price: 2999, original_price: 3299, category_name: '电子产品', images: [], is_new: true, discount: 9, status: 'active' },
          { id: 2, title: '无线耳机', price: 299, original_price: 399, category_name: '电子产品', images: [], discount: 7.5, status: 'active' },
          { id: 3, title: '智能手表', price: 899, category_name: '电子产品', images: [], status: 'active' },
          { id: 4, title: '蓝牙音箱', price: 199, category_name: '电子产品', images: [], status: 'active' },
          { id: 5, title: '男士休闲鞋', price: 299, category_name: '服装鞋帽', images: [], status: 'active' },
          { id: 6, title: '女士连衣裙', price: 199, category_name: '服装鞋帽', images: [], status: 'active' },
          { id: 7, title: '厨房刀具套装', price: 399, category_name: '家居用品', images: [], status: 'active' },
          { id: 8, title: '护肤精华液', price: 299, category_name: '美妆护肤', images: [], status: 'active' }
        ]
        
        categories.value = [
          { id: 1, name: '电子产品', status: 'active' },
          { id: 2, name: '服装鞋帽', status: 'active' },
          { id: 3, name: '家居用品', status: 'active' },
          { id: 4, name: '美妆护肤', status: 'active' }
        ]
        
        totalPages.value = Math.ceil(products.value.length / 8)
      } finally {
        loading.value = false
      }
    }
    
    // 筛选产品
    const filteredProducts = computed(() => {
      let filtered = products.value
      
      // 分类筛选
      if (selectedCategory.value) {
        filtered = filtered.filter(p => p.category_name === categories.value.find(c => c.id == selectedCategory.value)?.name)
      }
      
      // 搜索筛选
      if (searchKeyword.value.trim()) {
        filtered = filtered.filter(p => 
          p.title.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
          p.category_name.toLowerCase().includes(searchKeyword.value.toLowerCase())
        )
      }
      
      // 排序
      switch (sortBy.value) {
        case 'price-asc':
          filtered = [...filtered].sort((a, b) => a.price - b.price)
          break
        case 'price-desc':
          filtered = [...filtered].sort((a, b) => b.price - a.price)
          break
        case 'newest':
          filtered = [...filtered].sort((a, b) => (b.is_new ? 1 : 0) - (a.is_new ? 1 : 0))
          break
      }
      
      return filtered
    })
    
    // 搜索处理
    const handleSearch = () => {
      currentPage.value = 1
    }
    
    // 筛选处理
    const filterProducts = () => {
      currentPage.value = 1
    }
    
    // 排序处理
    const sortProducts = () => {
      // 排序逻辑已在计算属性中处理
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
    
    // 分页处理
    const changePage = (page) => {
      currentPage.value = page
      // TODO: 调用API加载对应页面的数据
    }
    
    // 监听路由参数变化
    watch(() => route.query.category, (newCategory) => {
      if (newCategory) {
        selectedCategory.value = parseInt(newCategory)
      }
    })
    
    onMounted(() => {
      loadProducts()
      // 检查URL参数
      if (route.query.category) {
        selectedCategory.value = parseInt(route.query.category)
      }
    })
    
    return {
      products,
      categories,
      loading,
      searchKeyword,
      selectedCategory,
      sortBy,
      currentPage,
      totalPages,
      filteredProducts,
      handleSearch,
      filterProducts,
      sortProducts,
      goToProduct,
      addToCart,
      buyNow,
      handleImageError,
      changePage,
      getClientPath,
      getImageUrl
    }
  }
}
</script>

<style scoped>
.mall-products-page {
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
  color: var(--color-text-secondary);
}

.filters-section {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
  align-items: center;
  flex-wrap: wrap;
}

.search-box {
  display: flex;
  flex: 1;
  max-width: 400px;
}

.search-box input {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #e5e7eb;
  border-right: none;
  border-radius: 8px 0 0 8px;
  font-size: 16px;
  outline: none;
  transition: border-color 0.3s;
}

.search-box input:focus {
  border-color: var(--color-primary);
}

.search-box button {
  padding: 12px 20px;
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: 0 8px 8px 0;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.search-box button:hover {
  background: var(--color-primary-hover);
}

.category-filter,
.sort-filter {
  min-width: 150px;
}

.category-filter select,
.sort-filter select {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  font-size: 16px;
  outline: none;
  transition: border-color 0.3s;
}

.category-filter select:focus,
.sort-filter select:focus {
  border-color: var(--color-primary);
}

.products-stats {
  margin-bottom: 30px;
  color: var(--color-text-secondary);
  font-size: 1rem;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 30px;
  margin-bottom: 40px;
}

.product-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  position: relative;
}

.product-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
}

.product-image {
  position: relative;
  height: 220px;
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
  font-size: 3rem;
}

.new-badge {
  position: absolute;
  top: 10px;
  left: 10px;
  background: #ff4757;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.discount-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background: #ffa502;
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
  margin-bottom: 8px;
  line-height: 1.4;
  height: 2.8em;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.product-category {
  color: var(--color-text-secondary);
  font-size: 0.9rem;
  margin-bottom: 12px;
}

.product-price-section {
  margin-bottom: 15px;
}

.current-price {
  font-size: 1.4rem;
  color: #ff4757;
  font-weight: 700;
  margin-right: 10px;
}

.original-price {
  font-size: 1rem;
  color: #999;
  text-decoration: line-through;
}

.product-actions {
  display: flex;
  gap: 10px;
}

.add-to-cart-btn,
.buy-now-btn {
  flex: 1;
  padding: 12px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
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

.loading-section {
  text-align: center;
  padding: 60px 0;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e5e7eb;
  border-top: 4px solid var(--color-primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty-state {
  text-align: center;
  padding: 60px 0;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 20px;
}

.empty-state h3 {
  color: var(--color-text-primary);
  margin-bottom: 10px;
}

.empty-state p {
  color: var(--color-text-secondary);
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  margin-top: 40px;
}

.page-btn {
  padding: 10px 20px;
  border: 2px solid var(--color-primary);
  background: white;
  color: var(--color-primary);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
}

.page-btn:hover:not(:disabled) {
  background: var(--color-primary);
  color: white;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  color: var(--color-text-secondary);
  font-weight: 600;
}

@media (max-width: 768px) {
  .filters-section {
    flex-direction: column;
    align-items: stretch;
  }
  
  .search-box {
    max-width: none;
  }
  
  .products-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .product-actions {
    flex-direction: column;
  }
  
  .page-header h1 {
    font-size: 2rem;
  }
}
</style>
