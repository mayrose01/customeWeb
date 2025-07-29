<template>
  <div class="product-detail-page">
    <ClientHeader />
    
    <!-- 主要内容区域 -->
    <main class="main-content">
      <div class="container">
        <!-- 面包屑导航 -->
        <div class="breadcrumb">
          <router-link to="/categories">分类</router-link>
          <span class="separator">/</span>
          <router-link :to="`/categories/${product.category_id}`" v-if="categoryName">
            {{ categoryName }}
          </router-link>
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
                <p v-if="product.images && product.images.length > 0" style="font-size: 0.8rem; color: #94a3b8;">
                  图片数据: {{ product.images.length }} 张
                </p>
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

              <div class="product-description" v-if="product.short_desc">
                <h3>产品简介</h3>
                <div v-html="product.short_desc"></div>
              </div>

              <div class="product-details" v-if="product.detail">
                <h3>产品详情</h3>
                <div v-html="product.detail" style="text-align: center;"></div>
              </div>

              <div class="product-category" v-if="categoryName">
                <h3>产品分类</h3>
                <p>{{ categoryName }}</p>
              </div>

              <div class="product-actions">
                <button class="inquiry-btn" @click="showInquiryModal">
                  <i class="icon-inquiry"></i>
                  立即询价
                </button>
                <button class="contact-btn" @click="goToContact">
                  <i class="icon-contact"></i>
                  联系我们
                </button>
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
        <div v-if="!loading && !product.id" class="error-section">
          <div class="error-icon">❌</div>
          <h3>产品不存在</h3>
          <p>抱歉，您访问的产品不存在或已被删除。</p>
          <button class="back-btn" @click="goBack">返回上一页</button>
        </div>
      </div>
    </main>

    <ClientFooter />

    <!-- 询价弹窗 -->
    <InquiryModal 
      :visible="showInquiry" 
      :product="product"
      @close="closeInquiryModal"
      @success="handleInquirySuccess"
    />
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import InquiryModal from '@/components/client/InquiryModal.vue'
import { getProduct } from '@/api/product'
import { getCategories } from '@/api/category'
import { getImageUrl } from '@/utils/imageUtils'

export default {
  name: 'ProductDetail',
  components: {
    ClientHeader,
    ClientFooter,
    InquiryModal
  },
  setup() {
    const route = useRoute()
    const router = useRouter()
    
    const loading = ref(true)
    const product = ref({})
    const categories = ref([])
    const currentImageIndex = ref(0)
    const imageDisplayMode = ref('contain')
    
    // 询价相关
    const showInquiry = ref(false)

    const currentImage = computed(() => {
      if (product.value.images && product.value.images.length > 0) {
        return product.value.images[currentImageIndex.value]
      }
      return null
    })
    
    const categoryName = computed(() => {
      if (!product.value.category_id) return ''
      const category = categories.value.find(cat => cat.id === product.value.category_id)
      return category ? category.name : ''
    })

    const loadProduct = async () => {
      try {
        loading.value = true
        const productId = route.params.id
        const response = await getProduct(productId)
        product.value = response.data
        currentImageIndex.value = 0
        
        // 应用产品详情图片样式
        applyDetailImageStyles()
      } catch (error) {
        console.error('加载产品失败:', error)
        product.value = {}
      } finally {
        loading.value = false
      }
    }

    const loadCategories = async () => {
      try {
        const response = await getCategories()
        categories.value = response.data
      } catch (error) {
        console.error('加载分类失败:', error)
      }
    }

    const setCurrentImage = (index) => {
      currentImageIndex.value = index
    }

    const showInquiryModal = () => {
      showInquiry.value = true
    }

    const closeInquiryModal = () => {
      showInquiry.value = false
    }

    const handleInquirySuccess = () => {
      // 询价成功后的处理
      console.log('询价提交成功')
    }

    const goToContact = () => {
      router.push('/contact')
    }

    const goBack = () => {
      router.back()
    }

    const handleImageError = (event) => {
      console.error('图片加载失败:', event.target.src)
      // 隐藏失败的图片
      event.target.style.display = 'none'
      // 显示占位符
      const placeholder = event.target.parentElement.querySelector('.image-placeholder')
      if (placeholder) {
        placeholder.style.display = 'flex'
      }
    }

    const handleImageLoad = () => {
      // 图片加载成功后，隐藏占位符
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

    const applyDetailImageStyles = () => {
      // 强制应用产品详情中图片的样式
      setTimeout(() => {
        const detailImages = document.querySelectorAll('.product-description img, .product-details img')
        detailImages.forEach(img => {
          img.style.maxWidth = '95%'
          img.style.width = 'auto'
          img.style.height = 'auto'
          img.style.margin = '10px auto'
          img.style.display = 'block'
          img.style.objectFit = 'contain'
          img.style.borderRadius = '0px'
          img.style.webkitBorderRadius = '0px'
          img.style.mozBorderRadius = '0px'
          
          // 监听图片加载完成事件
          img.onload = function() {
            this.style.borderRadius = '0px'
            this.style.webkitBorderRadius = '0px'
            this.style.mozBorderRadius = '0px'
          }
        })
      }, 100)
    }

    // 监听路由参数变化
    watch(() => route.params.id, (newId) => {
      if (newId) {
        loadProduct()
        loadCategories()
      }
    })

    onMounted(() => {
      loadProduct()
      loadCategories()
    })

    return {
      loading,
      product,
      categories,
      currentImageIndex,
      currentImage,
      categoryName,
      showInquiry,
      imageDisplayMode,
      setCurrentImage,
      showInquiryModal,
      closeInquiryModal,
      handleInquirySuccess,
      goToContact,
      goBack,
      handleImageError,
      handleImageLoad,
      handleThumbnailError,
      getImageUrl,
      applyDetailImageStyles
    }
  }
}
</script>

<style scoped>
.product-detail-page {
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
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  min-height: 600px;
}

.product-gallery {
  display: flex;
  flex-direction: column;
  gap: 20px;
  min-width: 0;
  flex-shrink: 0;
}

.main-image {
  width: 100%;
  aspect-ratio: 4/3;
  border-radius: 8px;
  overflow: hidden;
  background: var(--color-accent);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  min-height: 300px;
}

.main-image img {
  width: 100%;
  height: 100%;
  object-fit: v-bind(imageDisplayMode);
  max-width: 100%;
  max-height: 100%;
}

.image-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: var(--color-text-muted);
  font-size: 3rem;
  text-align: center;
}

.image-placeholder p {
  margin: 10px 0 0 0;
  font-size: 1rem;
}

.image-thumbnails {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  padding: 5px 0;
}

.thumbnail {
  width: 80px;
  height: 80px;
  border-radius: 6px;
  overflow: hidden;
  cursor: pointer;
  border: 2px solid transparent;
  transition: all 0.3s;
  flex-shrink: 0;
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
  background: var(--color-accent);
  color: var(--color-text-muted);
  font-size: 1.5rem;
}

.product-info {
  display: flex;
  flex-direction: column;
}

.product-info-container {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.product-header {
  border-bottom: 1px solid var(--color-accent-dark);
  padding-bottom: 20px;
}

.product-title {
  font-size: 2rem;
  color: var(--color-text-primary);
  margin: 0 0 10px 0;
  line-height: 1.3;
}

.product-model {
  font-size: 1.1rem;
  color: var(--color-text-secondary);
  margin: 0;
}

.product-description,
.product-details,
.product-category {
  border-bottom: 1px solid var(--color-accent-dark);
  padding-bottom: 20px;
}

.product-description h3,
.product-details h3,
.product-category h3 {
  color: var(--color-text-primary);
  margin: 0 0 15px 0;
  font-size: 1.3rem;
}

.product-description div,
.product-details div {
  color: var(--color-text-secondary);
  line-height: 1.6;
}

.product-category p {
  color: var(--color-text-secondary);
  margin: 0;
}

.product-actions {
  display: flex;
  gap: 15px;
  margin-top: 20px;
}

.inquiry-btn,
.contact-btn {
  flex: 1;
  padding: 15px 24px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.inquiry-btn {
  background: var(--color-primary);
  color: white;
}

.inquiry-btn:hover {
  background: var(--color-primary-hover);
}

.contact-btn {
  background: var(--color-accent);
  color: var(--color-text-secondary);
}

.contact-btn:hover {
  background: var(--color-accent-dark);
}

.loading-section,
.error-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid var(--color-accent);
  border-top: 4px solid var(--color-primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-icon {
  font-size: 3rem;
  margin-bottom: 20px;
}

.error-section h3 {
  color: var(--color-text-primary);
  margin: 0 0 10px 0;
}

.error-section p {
  color: var(--color-text-secondary);
  margin: 0 0 20px 0;
}

.back-btn {
  padding: 12px 24px;
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.back-btn:hover {
  background: var(--color-primary-hover);
}

/* 图标样式 */
.icon-inquiry::before {
  content: '💬';
}

.icon-contact::before {
  content: '📞';
}

/* 响应式设计 */
@media (max-width: 768px) {
  .product-detail {
    grid-template-columns: 1fr;
    gap: 30px;
    padding: 20px;
    min-height: auto;
  }
  
  .product-gallery {
    min-width: auto;
    flex-shrink: 1;
  }
  
  .product-info-container {
    gap: 20px;
  }
  
  .product-title {
    font-size: 1.5rem;
  }
  
  .product-actions {
    flex-direction: column;
    gap: 10px;
  }
  
  .inquiry-btn,
  .contact-btn {
    flex: none;
    width: 100%;
  }
  
  .image-thumbnails {
    gap: 8px;
  }
  
  .thumbnail {
    width: 60px;
    height: 60px;
  }
}

@media (max-width: 480px) {
  .product-detail {
    grid-template-columns: 1fr;
    padding: 15px;
  }
  
  .product-info-container {
    gap: 15px;
  }
  
  .product-title {
    font-size: 1.3rem;
  }
}
</style> 