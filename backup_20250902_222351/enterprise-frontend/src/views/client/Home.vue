<template>
  <div class="home-page">
    <ClientHeader />
    

    
    <!-- 主要内容区域 -->
    <main class="main-content">
      <!-- 轮播图区域 -->
      <section class="carousel-section" v-if="carouselImages.length > 0">
        <div class="carousel-container">
          <el-carousel height="500px" indicator-position="outside">
            <el-carousel-item v-for="image in carouselImages" :key="image.id">
              <div class="carousel-item">
                <img :src="image.image_url" :alt="image.caption" class="carousel-image">
                <div class="carousel-content">
                  <h2 class="carousel-title">{{ image.caption }}</h2>
                  <p class="carousel-description">{{ image.description }}</p>
                </div>
              </div>
            </el-carousel-item>
          </el-carousel>
        </div>
      </section>

      <!-- 公司信息区域 -->
      <section class="company-section">
        <div class="container">
          <div class="company-content">
            <div class="company-text">
              <h1 class="company-title">{{ companyInfo.name || '企业官网' }}</h1>
              <p class="company-description">{{ companyInfo.main_business || '专注于为客户提供优质的产品和服务' }}</p>
              <div class="company-actions">
                <router-link :to="getClientPath('/all-products')" class="btn-primary">查看产品</router-link>
                <router-link :to="getClientPath('/contact')" class="btn-secondary">联系我们</router-link>
              </div>
            </div>
            <div class="company-image" v-if="companyInfo.main_pic_url">
              <img :src="companyInfo.main_pic_url" :alt="companyInfo.name" class="main-business-image">
            </div>
          </div>
        </div>
      </section>

      <!-- 业务板块区域 -->
      <section class="services-section" v-if="services.length > 0">
        <div class="container">
          <div class="section-header">
            <h2>我们的业务板块</h2>
            <p>我们致力于为客户提供最优质的产品和服务</p>
          </div>
          
          <div class="services-grid">
            <div class="service-card" v-for="service in services" :key="service.id">
              <div class="service-image" v-if="service.image_url">
                <img :src="service.image_url" :alt="service.name" class="service-img">
              </div>
              <div class="service-content">
                <h3 class="service-title">{{ service.name }}</h3>
                <p class="service-description">{{ service.description }}</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 特色功能区域 - 已隐藏 -->
      <!-- <section class="features-section">
        <div class="container">
          <div class="section-header">
            <h2>我们的主要特色</h2>
            <p>专注于为客户提供最优质的产品和服务体验</p>
          </div>
          
          <div class="features-grid">
            <div class="feature-card">
              <div class="feature-icon">🏭</div>
              <h3>工厂介绍</h3>
              <p>{{ companyInfo.factory_introduction || '现代化的生产设施，先进的生产工艺，确保产品质量。' }}</p>
            </div>
            <div class="feature-card">
              <div class="feature-icon">📞</div>
              <h3>客户服务</h3>
              <p>24小时客户服务热线，专业团队随时为您解答问题。</p>
            </div>
            <div class="feature-card">
              <div class="feature-icon">🚚</div>
              <h3>快速配送</h3>
              <p>全国物流网络，快速配送，确保产品及时送达。</p>
            </div>
            <div class="feature-card">
              <div class="feature-icon">🛡️</div>
              <h3>质量保证</h3>
              <p>严格的质量管理体系，确保每一个产品都符合标准。</p>
            </div>
          </div>
        </div>
      </section> -->


    </main>

    <ClientFooter />
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getCompanyInfo, getCarouselImages, getServices } from '@/api/client'
import { getClientPath } from '@/utils/pathUtils'

export default {
  name: 'ClientHome',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const companyInfo = ref({})
    const carouselImages = ref([])
    const services = ref([])

    const loadData = async () => {
      try {
        // 并行加载数据
        const [companyRes, carouselRes, servicesRes] = await Promise.all([
          getCompanyInfo(),
          getCarouselImages(),
          getServices()
        ])
        
        companyInfo.value = companyRes.data
        carouselImages.value = carouselRes.data
        services.value = servicesRes.data
      } catch (error) {
        console.error('加载数据失败:', error)
      }
    }

    onMounted(() => {
      loadData()
    })

    return {
      companyInfo,
      carouselImages,
      services,
      getClientPath
    }
  }
}
</script>

<style scoped>
.home-page {
  min-height: 100vh;
  overflow-x: hidden;
  display: flex;
  flex-direction: column;
  position: relative;
}

.main-content {
  padding-top: 120px; /* 为固定header留出空间 */
  flex: 1;
  min-height: calc(100vh - 120px);
  position: relative;
  z-index: 1;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* 轮播图区域 */
.carousel-section {
  margin-bottom: 0;
}

.carousel-container {
  width: 100%;
}

.carousel-item {
  position: relative;
  height: 500px;
}

.carousel-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.carousel-content {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.7));
  color: white;
  padding: 40px;
  text-align: center;
}

.carousel-title {
  font-size: 2rem;
  margin-bottom: 10px;
  font-weight: bold;
}

.carousel-description {
  font-size: 1.1rem;
  opacity: 0.9;
}

/* 公司信息区域 */
.company-section {
  background: var(--color-background);
  color: var(--color-text-primary);
  padding: 80px 0;
  position: relative;
  overflow: hidden;
}

.company-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 60px;
  align-items: center;
}

.company-title {
  font-size: 3rem;
  font-weight: bold;
  margin-bottom: 20px;
  line-height: 1.2;
}

.company-description {
  font-size: 1.1rem;
  margin-bottom: 30px;
  line-height: 1.6;
  color: var(--color-text-secondary);
}

.company-actions {
  display: flex;
  gap: 20px;
}

.btn-primary, .btn-secondary {
  padding: 12px 30px;
  border-radius: 6px;
  text-decoration: none;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-primary {
  background: var(--color-primary);
  color: white;
}

.btn-primary:hover {
  background: var(--color-primary-hover);
  transform: translateY(-2px);
}

.btn-secondary {
  background: transparent;
  color: var(--color-primary);
  border: 2px solid var(--color-primary);
}

.btn-secondary:hover {
  background: var(--color-primary);
  color: white;
}

.company-image {
  display: flex;
  justify-content: center;
  align-items: center;
}

.main-business-image {
  width: 100%;
  max-width: 400px;
  height: 300px;
  object-fit: cover;
  border-radius: 10px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

/* 主营业务区域 */
.services-section {
  padding: 80px 0;
  background: var(--color-background);
}

.section-header {
  text-align: center;
  margin-bottom: 60px;
}

.section-header h2 {
  font-size: 2.5rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.section-header p {
  font-size: 1.1rem;
  color: var(--color-text-muted);
  max-width: 600px;
  margin: 0 auto;
}

.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 30px;
}

.service-card {
  background: var(--color-background);
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s;
}

.service-card:hover {
  transform: translateY(-5px);
}

.service-image {
  height: 200px;
  overflow: hidden;
}

.service-img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  background-color: #f8f9fa;
}

.service-content {
  padding: 20px;
}

.service-title {
  font-size: 1.3rem;
  color: var(--color-text-primary);
  margin-bottom: 10px;
}

.service-description {
  color: var(--color-text-muted);
  line-height: 1.6;
}

/* 特色功能区域 */
.features-section {
  padding: 80px 0;
  background: var(--color-accent-light);
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
}

.feature-card {
  background: var(--color-background);
  padding: 30px;
  border-radius: 10px;
  text-align: center;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s;
}

.feature-card:hover {
  transform: translateY(-5px);
}

.feature-icon {
  font-size: 3rem;
  margin-bottom: 20px;
}

.feature-card h3 {
  font-size: 1.3rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
}

.feature-card p {
  color: var(--color-text-muted);
  line-height: 1.6;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .company-content {
    grid-template-columns: 1fr;
    gap: 40px;
  }
  
  .company-title {
    font-size: 2rem;
  }
  
  .company-actions {
    flex-direction: column;
  }
  
  .services-grid {
    grid-template-columns: 1fr;
  }
  
  .features-grid {
    grid-template-columns: 1fr;
  }
  
  .section-header h2 {
    font-size: 2rem;
  }
  
  .carousel-content {
    padding: 20px;
  }
  
  .carousel-title {
    font-size: 1.5rem;
  }
}
</style> 