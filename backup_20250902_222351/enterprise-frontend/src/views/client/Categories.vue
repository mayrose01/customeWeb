<template>
  <div class="categories-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 页面标题 -->
        <div class="page-header">
          <h1>产品分类</h1>
          <p>浏览我们的产品分类，找到您需要的产品</p>
        </div>

        <!-- 搜索功能 -->
        <div class="search-section" v-if="searchKeyword">
          <div class="search-results">
            <h3>搜索结果: "{{ searchKeyword }}"</h3>
            <button @click="clearSearch" class="clear-search">清除搜索</button>
          </div>
        </div>

        <!-- 分类列表 -->
        <div class="categories-grid" v-if="!loading && !searchKeyword && !showAllProducts">
          <div 
            v-for="category in filteredCategories" 
            :key="category.id"
            class="category-card"
            @click="goToSubCategories(category.id)"
          >
            <div class="category-image">
              <img 
                v-if="category.image" 
                :src="category.image" 
                :alt="category.name"
                @error="handleImageError"
              />
              <div v-else class="image-placeholder">
                <span>📦</span>
              </div>
            </div>
            <div class="category-content">
              <h3 class="category-name">{{ category.name }}</h3>
              <p class="category-description" v-if="category.description">
                {{ category.description }}
              </p>
              <div class="category-meta">
                <span class="product-count">{{ getProductCount(category.id) }} 个产品</span>
                <span class="view-more">查看详情 →</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 所有产品列表 -->
        <div v-if="!loading && showAllProducts" class="products-section">
          <h2>所有产品</h2>
          <div class="products-grid">
            <div 
              v-for="product in filteredProducts" 
              :key="product.id"
              class="product-card"
              @click="viewProduct(product.id)"
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
                <h3 class="product-name">{{ product.title }}</h3>
                <p class="product-model" v-if="product.model">型号: {{ product.model }}</p>
                <div class="product-description" v-if="product.short_desc" v-html="product.short_desc"></div>
                <div class="product-actions">
                  <button class="inquiry-btn" @click.stop="showInquiryModal(product)">
                    询价
                  </button>
                  <button class="view-btn" @click.stop="viewProduct(product.id)">
                    查看详情
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载分类...</p>
        </div>

        <!-- 产品搜索结果 -->
        <div v-if="!loading && searchKeyword && filteredProducts.length > 0" class="products-section">
          <h2>搜索结果</h2>
          <div class="products-grid">
            <div 
              v-for="product in filteredProducts" 
              :key="product.id"
              class="product-card"
              @click="viewProduct(product.id)"
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
                <h3 class="product-name">{{ product.title }}</h3>
                <p class="product-model" v-if="product.model">型号: {{ product.model }}</p>
                <div class="product-description" v-if="product.short_desc" v-html="product.short_desc"></div>
                <div class="product-actions">
                  <button class="inquiry-btn" @click.stop="showInquiryModal(product)">
                    询价
                  </button>
                  <button class="view-btn" @click.stop="viewProduct(product.id)">
                    查看详情
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 空状态 -->
        <div v-if="!loading && ((!searchKeyword && filteredCategories.length === 0) || (searchKeyword && filteredProducts.length === 0))" class="empty-state">
          <div class="empty-icon">📦</div>
          <h3>{{ searchKeyword ? '未找到相关产品' : '暂无分类' }}</h3>
          <p>{{ searchKeyword ? '请尝试其他关键词' : '暂时没有可用的产品分类' }}</p>
        </div>
      </div>
    </main>

    <!-- 询价弹窗 -->
    <InquiryModal 
      :visible="showInquiry" 
      :product="selectedProduct"
      @close="closeInquiryModal"
      @success="handleInquirySuccess"
    />



    <ClientFooter />
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import InquiryModal from '@/components/client/InquiryModal.vue'

import { getCategories } from '@/api/category'
import { getProducts } from '@/api/product'
import { getImageUrl } from '@/utils/imageUtils'

export default {
  name: 'ClientCategories',
  components: {
    ClientHeader,
    ClientFooter,
    InquiryModal
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    const categories = ref([])
    const products = ref([])
    const loading = ref(true)
    const searchKeyword = ref(route.query.search || '')
    const showAllProducts = ref(false) // 新增：控制是否显示所有产品

    const loadCategories = async () => {
      try {
        loading.value = true
        const response = await getCategories()
        // 只显示顶级分类（parent_id为null）
        categories.value = response.data.filter(cat => !cat.parent_id)
      } catch (error) {
        console.error('加载分类失败:', error)
      } finally {
        loading.value = false
      }
    }

    const loadProducts = async (searchTerm = '') => {
      try {
        const params = {}
        if (searchTerm) {
          params.title = searchTerm
        }
        const response = await getProducts(params)
        // 正确处理API返回的数据结构
        products.value = response.data.items || response.data || []
        console.log('加载的产品数据:', products.value)
      } catch (error) {
        console.error('加载产品失败:', error)
        products.value = []
      }
    }

    const getProductCount = (categoryId) => {
      if (!Array.isArray(products.value)) {
        return 0
      }
      return products.value.filter(product => product.category_id === categoryId).length
    }

    const goToSubCategories = (categoryId) => {
      router.push(`/categories/${categoryId}`)
    }

    const viewProduct = (productId) => {
      router.push(`/product/${productId}`)
    }

    // 询价相关
    const showInquiry = ref(false)
    const selectedProduct = ref({})

    const showInquiryModal = (product) => {
      selectedProduct.value = product
      showInquiry.value = true
    }

    const closeInquiryModal = () => {
      showInquiry.value = false
      selectedProduct.value = {}
    }

    const handleInquirySuccess = () => {
      // 询价成功后的处理
      console.log('询价提交成功')
    }

    const clearSearch = () => {
      searchKeyword.value = ''
      showAllProducts.value = true // 显示所有产品
      router.push({ path: '/categories', query: {} })
      // 重新加载所有产品
      loadProducts()
    }

    const handleSearch = () => {
      if (searchKeyword.value.trim()) {
        // 搜索时重新从后端获取数据
        loadProducts(searchKeyword.value.trim())
      } else {
        // 如果搜索词为空，加载所有产品
        loadProducts()
      }
    }

    const handleImageError = (event) => {
      event.target.style.display = 'none'
      event.target.nextElementSibling.style.display = 'flex'
    }

    const filteredCategories = computed(() => {
      if (!searchKeyword.value) {
        return categories.value
      }
      return categories.value.filter(category => 
        category.name.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
        (category.description && category.description.toLowerCase().includes(searchKeyword.value.toLowerCase()))
      )
    })

    const filteredProducts = computed(() => {
      // 确保products.value是数组
      if (!Array.isArray(products.value)) {
        console.warn('products.value不是数组:', products.value)
        return []
      }
      // 如果有搜索关键词，返回搜索结果；如果显示所有产品，返回所有产品
      if (searchKeyword.value) {
        // 搜索逻辑在后端处理，直接返回从后端获取的产品
        return products.value
      } else if (showAllProducts.value) {
        // 显示所有产品
        return products.value
      } else {
        // 显示分类时，不显示产品
        return []
      }
    })

    onMounted(async () => {
      await Promise.all([loadCategories(), loadProducts()])
      
      // 如果URL中有搜索参数，执行搜索
      if (searchKeyword.value) {
        showAllProducts.value = false // 搜索时显示搜索结果
        handleSearch()
      } else {
        // 如果没有搜索参数，默认显示分类
        showAllProducts.value = false
      }
    })

    // 监听搜索参数变化
    watch(() => route.query.search, (newSearch) => {
      searchKeyword.value = newSearch || ''
      if (newSearch) {
        showAllProducts.value = false // 搜索时显示搜索结果
        handleSearch()
      } else {
        // 如果没有搜索参数，保持当前状态（可能是显示分类或所有产品）
        loadProducts()
      }
    })

    return {
      categories,
      products,
      loading,
      searchKeyword,
      filteredCategories,
      filteredProducts,
      getProductCount,
      goToSubCategories,
      viewProduct,
      showInquiryModal,
      closeInquiryModal,
      handleInquirySuccess,
      showInquiry,
      selectedProduct,

      clearSearch,
      handleSearch,
      handleImageError,
      getImageUrl,
      showAllProducts
    }
  }
}
</script>

<style scoped>
.categories-page {
  min-height: 100vh;
}

.main-content {
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
  margin-bottom: 50px;
}

.page-header h1 {
  font-size: 2.5rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.page-header p {
  font-size: 1.1rem;
  color: var(--color-text-muted);
}

.search-section {
  margin-bottom: 30px;
}

.search-results {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--color-accent);
  padding: 15px 20px;
  border-radius: 8px;
}

.search-results h3 {
  color: var(--color-text-primary);
  margin: 0;
}

.clear-search {
  background: var(--color-btn-secondary);
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.3s;
}

.clear-search:hover {
  background: var(--color-btn-secondary-hover);
}

.categories-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 30px;
}

.category-card {
  background: var(--color-background);
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  transition: all 0.3s;
  cursor: pointer;
}

.category-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.category-image {
  height: 200px;
  overflow: hidden;
  position: relative;
}

.category-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}

.category-card:hover .category-image img {
  transform: scale(1.05);
}

.image-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-light));
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 3rem;
}

.category-content {
  padding: 25px;
}

.category-name {
  font-size: 1.3rem;
  color: var(--color-text-primary);
  margin-bottom: 10px;
  font-weight: 600;
}

.category-description {
  color: var(--color-text-muted);
  line-height: 1.6;
  margin-bottom: 15px;
  font-size: 0.95rem;
}

.category-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 15px;
}

.product-count {
  color: #64748b;
  font-size: 0.9rem;
}

.view-more {
  color: var(--color-primary);
  font-weight: 500;
  font-size: 0.9rem;
  transition: color 0.3s;
}

.category-card:hover .view-more {
  color: var(--color-primary-hover);
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
  color: #1e293b;
  margin-bottom: 10px;
}

.empty-state p {
  color: #64748b;
}

/* 产品搜索结果样式 */
.products-section {
  margin-top: 30px;
}

.products-section h2 {
  font-size: 2rem;
  color: #1e293b;
  margin-bottom: 30px;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 30px;
}

.product-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s, box-shadow 0.3s;
  cursor: pointer;
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
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
  transition: transform 0.3s;
}

.product-card:hover .product-image img {
  transform: scale(1.05);
}

.image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-accent);
  font-size: 3rem;
}

.product-content {
  padding: 20px;
}

.product-name {
  font-size: 1.2rem;
  color: var(--color-text-primary);
  margin-bottom: 8px;
  font-weight: 600;
}

.product-model {
  color: var(--color-text-muted);
  font-size: 0.9rem;
  margin-bottom: 12px;
}

.product-description {
  color: var(--color-text-muted);
  font-size: 0.9rem;
  line-height: 1.5;
  margin-bottom: 16px;
  max-height: 60px;
  overflow: hidden;
}

.product-actions {
  display: flex;
  gap: 10px;
}

.inquiry-btn, .view-btn {
  flex: 1;
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.inquiry-btn {
  background: var(--color-primary);
  color: white;
}

.inquiry-btn:hover {
  background: var(--color-primary-hover);
}

.view-btn {
  background: var(--color-accent);
  color: var(--color-text-secondary);
}

.view-btn:hover {
  background: var(--color-accent-dark);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header h1 {
    font-size: 2rem;
  }
  
  .categories-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .category-content {
    padding: 20px;
  }
  
  .search-results {
    flex-direction: column;
    gap: 10px;
    text-align: center;
  }
}
</style> 