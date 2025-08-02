<template>
  <div class="all-products-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 页面标题 -->
        <div class="page-header">
          <h1>所有产品</h1>
          <p>浏览我们的完整产品目录，找到您需要的产品</p>
        </div>

        <!-- 筛选和搜索 -->
        <div class="filters-section">
          <div class="search-box">
            <input 
              type="text" 
              placeholder="输入标题搜索产品..." 
              v-model="searchKeyword"
              @input="handleSearch"
            />
            <button @click="handleSearch">
              <i class="icon-search"></i>
            </button>
          </div>
          
          <div class="category-filter">
            <select v-model="selectedCategory" @change="handleCategoryFilter">
              <option value="">所有分类</option>
              <option v-for="category in categories" :key="category.id" :value="category.id">
                {{ category.name }}
              </option>
            </select>
          </div>
        </div>

        <!-- 产品统计 -->
        <div class="products-stats">
          <span>共找到 {{ filteredProducts.length }} 个产品</span>
        </div>

        <!-- 产品列表 -->
        <div v-if="!loading && filteredProducts.length > 0" class="products-grid">
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
              <h3 class="product-title">{{ product.title }}</h3>
              <p class="product-model" v-if="product.model">型号: {{ product.model }}</p>
              <div class="product-description" v-if="product.short_desc" v-html="product.short_desc"></div>
              <div class="product-category" v-if="product.category">
                <span class="category-tag">{{ product.category.name }}</span>
              </div>
              <div class="product-actions">
                <button class="inquiry-btn" @click.stop="openInquiryModal(product)">
                  询价
                </button>
                <button class="view-btn" @click.stop="viewProduct(product.id)">
                  查看详情
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载产品...</p>
        </div>

        <!-- 空状态 -->
        <div v-if="!loading && filteredProducts.length === 0" class="empty-state">
          <div class="empty-icon">📦</div>
          <h3>未找到产品</h3>
          <p>请尝试调整搜索条件或分类筛选</p>
        </div>


      </div>
    </main>



    <ClientFooter />
    
    <!-- 询价弹窗 -->
    <InquiryModal
      :visible="showInquiryModal"
      :product="selectedProduct"
      @close="closeInquiryModal"
      @success="handleInquirySuccess"
    />
  </div>
</template>

<script>
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import InquiryModal from '@/components/client/InquiryModal.vue'

import { getAllProducts } from '@/api/clientProduct'
import { getCategories } from '@/api/category'
import { getImageUrl } from '@/utils/imageUtils'

export default {
  name: 'AllProducts',
  components: {
    ClientHeader,
    ClientFooter,
    InquiryModal
  },
  setup() {
    const router = useRouter()
    
    const products = ref([])
    const categories = ref([])
    const loading = ref(true)
    const searchKeyword = ref('')
    const selectedCategory = ref('')
    const showInquiryModal = ref(false)
    const selectedProduct = ref({})

    const loadProducts = async () => {
      try {
        loading.value = true
        const params = {}
        
        // 添加分类筛选参数
        if (selectedCategory.value) {
          params.category_id = selectedCategory.value
        }
        
        // 添加搜索参数
        if (searchKeyword.value) {
          params.search = searchKeyword.value
        }
        
        const response = await getAllProducts(params)
        // 客户端API直接返回产品数组
        products.value = response.data
      } catch (error) {
        console.error('加载产品失败:', error)
        products.value = []
      } finally {
        loading.value = false
      }
    }

    const loadCategories = async () => {
      try {
        const response = await getCategories()
        // 只显示子类目（有父分类的分类），不显示顶级类目
        categories.value = response.data.filter(category => category.parent_id !== null)
      } catch (error) {
        console.error('加载分类失败:', error)
        categories.value = []
      }
    }

    const filteredProducts = computed(() => {
      // 直接返回从后端获取的产品，因为搜索和筛选都在后端处理
      return products.value
    })

    let searchTimeout = null

    const handleSearch = () => {
      // 清除之前的定时器
      if (searchTimeout) {
        clearTimeout(searchTimeout)
      }
      
      // 设置新的定时器，延迟500ms执行搜索
      searchTimeout = setTimeout(() => {
        loadProducts()
      }, 500)
    }

    const handleCategoryFilter = () => {
      loadProducts()
    }

    const viewProduct = (productId) => {
      router.push(`/product/${productId}`)
    }

    const openInquiryModal = (product) => {
      selectedProduct.value = product
      showInquiryModal.value = true
    }

    const closeInquiryModal = () => {
      showInquiryModal.value = false
      selectedProduct.value = {}
    }

    const handleInquirySuccess = () => {
      closeInquiryModal()
      // 可以在这里添加成功提示
    }

    const handleImageError = (event) => {
      event.target.style.display = 'none'
      const placeholder = event.target.nextElementSibling
      if (placeholder) {
        placeholder.style.display = 'flex'
      }
    }



    onMounted(async () => {
      await Promise.all([loadProducts(), loadCategories()])
    })

    return {
      products,
      categories,
      loading,
      searchKeyword,
      selectedCategory,
      filteredProducts,
      handleSearch,
      handleCategoryFilter,
      viewProduct,
      openInquiryModal,
      closeInquiryModal,
      handleInquirySuccess,
      showInquiryModal,
      selectedProduct,
      handleImageError,
      getImageUrl
    }
  }
}
</script>

<style scoped>
.all-products-page {
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
  margin-bottom: 40px;
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

.filters-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  gap: 20px;
  flex-wrap: wrap;
}

.search-box {
  display: flex;
  align-items: center;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  overflow: hidden;
  flex: 1;
  max-width: 400px;
}

.search-box input {
  border: none;
  padding: 12px 16px;
  outline: none;
  flex: 1;
  font-size: 14px;
}

.search-box button {
  background: var(--color-primary);
  color: white;
  border: none;
  padding: 12px 16px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.search-box button:hover {
  background: var(--color-primary-hover);
}

.category-filter select {
  padding: 12px 16px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: white;
  font-size: 14px;
  cursor: pointer;
  min-width: 150px;
}

.products-stats {
  margin-bottom: 20px;
  color: var(--color-text-muted);
  font-size: 14px;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 30px;
  margin-bottom: 40px;
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
  object-fit: contain;
  transition: transform 0.3s;
  background-color: #f8f9fa;
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

.product-title {
  font-size: 1.2rem;
  color: var(--color-text-primary);
  margin-bottom: 8px;
  font-weight: 600;
  line-height: 1.4;
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
  margin-bottom: 12px;
  max-height: 60px;
  overflow: hidden;
}

.product-category {
  margin-bottom: 16px;
}

.category-tag {
  background: var(--color-accent-light);
  color: var(--color-primary);
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
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



.icon-search::before {
  content: '🔍';
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header h1 {
    font-size: 2rem;
  }
  
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
  
  .product-content {
    padding: 16px;
  }
  
  .pagination {
    flex-direction: column;
    gap: 10px;
  }
}
</style> 