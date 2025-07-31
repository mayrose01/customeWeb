<template>
  <div class="subcategories-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 面包屑导航 -->
        <div class="breadcrumb">
          <router-link :to="getClientPath('/categories')">分类</router-link>
          <span class="separator">/</span>
          <span>{{ categoryName }}</span>
        </div>

        <!-- 页面标题 -->
        <div class="page-header">
          <h1>{{ categoryName }}</h1>
          <p v-if="categoryDescription">{{ categoryDescription }}</p>
        </div>

        <!-- 搜索功能 -->
        <div class="search-section">
          <div class="search-box">
            <input 
              type="text" 
              placeholder="搜索产品..." 
              v-model="searchKeyword"
              @keyup.enter="handleSearch"
            />
            <button @click="handleSearch">
              <i class="icon-search"></i>
            </button>
          </div>
          <div class="filter-options">
            <select v-model="sortBy" @change="handleSort">
              <option value="name">按名称排序</option>
              <option value="created_at">按时间排序</option>
            </select>
          </div>
        </div>

        <!-- 产品列表 -->
        <div class="products-grid" v-if="!loading && filteredProducts.length > 0">
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

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载产品...</p>
        </div>

        <!-- 空状态 -->
        <div v-if="!loading && filteredProducts.length === 0" class="empty-state">
          <div class="empty-icon">📦</div>
          <h3>暂无产品</h3>
          <p>该分类下暂时没有产品</p>
        </div>

        <!-- 分页 -->
        <div v-if="totalPages > 1" class="pagination">
          <button 
            @click="changePage(currentPage - 1)" 
            :disabled="currentPage <= 1"
            class="page-btn"
          >
            上一页
          </button>
          <span class="page-info">{{ currentPage }} / {{ totalPages }}</span>
          <button 
            @click="changePage(currentPage + 1)" 
            :disabled="currentPage >= totalPages"
            class="page-btn"
          >
            下一页
          </button>
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
import { getImageUrl, getProductImages } from '@/utils/imageUtils'
import { getClientPath } from '@/utils/pathUtils'

export default {
  name: 'ClientSubCategories',
  components: {
    ClientHeader,
    ClientFooter,
    InquiryModal
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    const loading = ref(true)
    const products = ref([])
    const categories = ref([])
    const searchKeyword = ref('')
    const sortBy = ref('name')
    const currentPage = ref(1)
    const pageSize = ref(12)
    const totalPages = ref(1)
    
    // 询价相关
    const showInquiry = ref(false)
    const selectedProduct = ref({})

    const categoryId = computed(() => route.params.id)
    const categoryName = computed(() => {
      const category = categories.value.find(cat => cat.id == categoryId.value)
      return category ? category.name : '产品分类'
    })
    const categoryDescription = computed(() => {
      const category = categories.value.find(cat => cat.id == categoryId.value)
      return category ? category.description : ''
    })

    const filteredProducts = computed(() => {
      let filtered = products.value

      // 搜索过滤
      if (searchKeyword.value) {
        const keyword = searchKeyword.value.toLowerCase()
        filtered = filtered.filter(product => 
          product.title.toLowerCase().includes(keyword) ||
          (product.model && product.model.toLowerCase().includes(keyword))
        )
      }

      // 排序
      filtered.sort((a, b) => {
        if (sortBy.value === 'name') {
          return a.title.localeCompare(b.title)
        } else if (sortBy.value === 'created_at') {
          return new Date(b.created_at) - new Date(a.created_at)
        }
        return 0
      })

      return filtered
    })

    const loadCategories = async () => {
      try {
        const response = await getCategories()
        categories.value = response.data
      } catch (error) {
        console.error('加载分类失败:', error)
      }
    }

    const loadProducts = async () => {
      try {
        loading.value = true
        const params = {
          category_id: categoryId.value,
          page: currentPage.value,
          page_size: pageSize.value
        }
        const response = await getProducts(params)
        products.value = response.data.items || response.data
        totalPages.value = Math.ceil((response.data.total || products.value.length) / pageSize.value)
      } catch (error) {
        console.error('加载产品失败:', error)
        products.value = []
      } finally {
        loading.value = false
      }
    }

    const handleSearch = () => {
      currentPage.value = 1
      // 搜索逻辑已在computed中处理
    }

    const handleSort = () => {
      // 排序逻辑已在computed中处理
    }

    const changePage = (page) => {
      if (page >= 1 && page <= totalPages.value) {
        currentPage.value = page
        loadProducts()
      }
    }

    const viewProduct = (productId) => {
      router.push(`/product/${productId}`)
    }

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

    const handleImageError = (event) => {
      event.target.style.display = 'none'
      event.target.nextElementSibling.style.display = 'block'
    }

    onMounted(() => {
      loadCategories()
      loadProducts()
    })

    watch(() => route.params.id, () => {
      if (route.params.id) {
        currentPage.value = 1
        loadProducts()
      }
    })

    return {
      loading,
      products,
      categories,
      searchKeyword,
      sortBy,
      currentPage,
      totalPages,
      categoryName,
      categoryDescription,
      filteredProducts,
      showInquiry,
      selectedProduct,
      handleSearch,
      handleSort,
      changePage,
      viewProduct,
      showInquiryModal,
      closeInquiryModal,
      handleInquirySuccess,

      handleImageError,
      getImageUrl,
      getClientPath
    }
  }
}
</script>

<style scoped>
.subcategories-page {
  min-height: 100vh;
  background: #f8fafc;
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

.breadcrumb {
  margin-bottom: 20px;
  font-size: 14px;
  color: #64748b;
}

.breadcrumb a {
  color: #1e40af;
  text-decoration: none;
}

.breadcrumb .separator {
  margin: 0 8px;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h1 {
  font-size: 2.5rem;
  color: #1e293b;
  margin-bottom: 10px;
}

.page-header p {
  color: #64748b;
  font-size: 1.1rem;
}

.search-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  gap: 20px;
}

.search-box {
  display: flex;
  flex: 1;
  max-width: 400px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  overflow: hidden;
}

.search-box input {
  flex: 1;
  border: none;
  padding: 12px 16px;
  outline: none;
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

.filter-options select {
  padding: 10px 16px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: white;
  font-size: 14px;
  cursor: pointer;
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
  background: #f1f5f9;
  font-size: 3rem;
}

.product-content {
  padding: 20px;
}

.product-name {
  font-size: 1.2rem;
  color: #1e293b;
  margin-bottom: 8px;
  font-weight: 600;
}

.product-model {
  color: #64748b;
  font-size: 0.9rem;
  margin-bottom: 12px;
}

.product-description {
  color: #64748b;
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
  background: #f1f5f9;
  color: #374151;
}

.view-btn:hover {
  background: #e2e8f0;
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

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  margin-top: 40px;
}

.page-btn {
  padding: 10px 20px;
  border: 1px solid #d1d5db;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s;
}

.page-btn:hover:not(:disabled) {
  background: #f8fafc;
  border-color: #1e40af;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  color: #64748b;
  font-weight: 500;
}



/* 响应式设计 */
@media (max-width: 768px) {
  .search-section {
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
  
  .modal-content {
    width: 95%;
    margin: 20px;
  }
}
</style> 