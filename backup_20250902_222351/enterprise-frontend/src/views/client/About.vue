<template>
  <div class="about-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <!-- 页面标题 -->
        <div class="page-header">
          <h1>关于我们</h1>
          <p>了解我们的公司背景、发展历程和企业文化</p>
        </div>

        <!-- 公司信息 -->
        <div class="company-info" v-if="!loading && companyInfo">
          <div class="info-section">
            <div class="company-logo" v-if="companyInfo.logo_url">
              <img :src="companyInfo.logo_url" :alt="companyInfo.name" />
            </div>
            <div class="company-details">
              <h2>{{ companyInfo.name }}</h2>
              <p v-if="companyInfo.email" class="company-email">
                {{ companyInfo.email }}
              </p>
            </div>
          </div>
        </div>

        <!-- 公司介绍 -->
        <section class="about-section">
          <div class="section-header">
            <h2>公司介绍</h2>
          </div>
          <div class="section-content">
            <div class="background-text">
              <div v-if="companyInfo.about_text" v-html="companyInfo.about_text"></div>
              <p v-else class="placeholder-text">
                我们是一家专业的企业，致力于为客户提供优质的产品和服务。
                多年来，我们始终坚持"质量第一、客户至上"的经营理念，
                不断创新和发展，在行业内树立了良好的口碑和信誉。
              </p>
            </div>
            <div class="background-image" v-if="companyInfo.company_image">
              <img :src="companyInfo.company_image" :alt="companyInfo.name" class="company-intro-img">
            </div>
            <div class="background-image" v-else>
              <div class="office-building">
                <div class="building-structure">
                  <div class="building-floor"></div>
                  <div class="building-floor"></div>
                  <div class="building-floor"></div>
                  <div class="building-floor"></div>
                </div>
                <div class="building-windows">
                  <div class="window-row">
                    <div class="window"></div>
                    <div class="window"></div>
                    <div class="window"></div>
                  </div>
                  <div class="window-row">
                    <div class="window"></div>
                    <div class="window"></div>
                    <div class="window"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- 主营业务 -->
        <section class="about-section">
          <div class="section-header">
            <h2>主营业务</h2>
          </div>
          <div class="section-content">
            <div class="business-content">
              <div v-if="companyInfo.main_business" v-html="companyInfo.main_business"></div>
              <p v-else class="placeholder-text">
                我们的主营业务包括产品研发、生产制造、销售服务等多个领域。
                我们拥有先进的生产设备和专业的技术团队，能够为客户提供
                全方位的解决方案和优质的产品服务。
              </p>
            </div>
            <div class="business-image" v-if="companyInfo.main_pic_url">
              <img :src="companyInfo.main_pic_url" :alt="companyInfo.name" class="main-business-img">
            </div>
            <div class="business-image" v-else>
              <div class="factory-scene">
                <div class="production-line">
                  <div class="machine"></div>
                  <div class="conveyor"></div>
                  <div class="machine"></div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- 联系信息 -->
        <section class="contact-section">
          <div class="section-header">
            <h2>联系我们</h2>
          </div>
          <div class="contact-grid">
            <div class="contact-item">
              <div class="contact-icon">📍</div>
              <h3>公司地址</h3>
              <p>{{ companyInfo.address || '地址信息待完善' }}</p>
            </div>
            <div class="contact-item">
              <div class="contact-icon">📧</div>
              <h3>邮箱地址</h3>
              <p>{{ companyInfo.email || '邮箱信息待完善' }}</p>
            </div>
            <div class="contact-item">
              <div class="contact-icon">📞</div>
              <h3>联系电话</h3>
              <p>{{ companyInfo.phone || '电话信息待完善' }}</p>
            </div>
            <div class="contact-item">
              <div class="contact-icon">🕒</div>
              <h3>工作时间</h3>
              <p>{{ companyInfo.working_hours || '周一至周五: 9:00-18:00' }}</p>
            </div>
          </div>
        </section>

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载公司信息...</p>
        </div>
      </div>
    </main>

    <ClientFooter />
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getCompanyInfo } from '@/api/client'

export default {
  name: 'ClientAbout',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const companyInfo = ref({})
    const loading = ref(true)

    const loadCompanyInfo = async () => {
      try {
        loading.value = true
        const response = await getCompanyInfo()
        companyInfo.value = response.data
      } catch (error) {
        console.error('加载公司信息失败:', error)
      } finally {
        loading.value = false
      }
    }

    onMounted(() => {
      loadCompanyInfo()
    })

    return {
      companyInfo,
      loading
    }
  }
}
</script>

<style scoped>
.about-page {
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
  margin-bottom: 60px;
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

.company-info {
  margin-bottom: 60px;
}

.info-section {
  display: flex;
  align-items: center;
  gap: 30px;
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.company-logo img {
  width: 80px;
  height: 80px;
  object-fit: contain;
}

.company-details h2 {
  font-size: 2rem;
  color: var(--color-text-primary);
  margin-bottom: 5px;
}

.company-email {
  color: var(--color-text-muted);
  font-size: 1.1rem;
}

.about-section {
  margin-bottom: 60px;
}

.section-header {
  margin-bottom: 30px;
}

.section-header h2 {
  font-size: 2rem;
  color: var(--color-text-primary);
  position: relative;
  padding-bottom: 10px;
}

.section-header h2::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 60px;
  height: 3px;
  background: var(--color-primary);
}

.section-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
  align-items: center;
}

.background-text,
.business-content,
.factory-content {
  color: var(--color-text-muted);
  line-height: 1.8;
  font-size: 1rem;
}

.placeholder-text {
  color: var(--color-text-muted);
  line-height: 1.8;
  font-size: 1rem;
}

.background-image,
.business-image,
.factory-image {
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 办公室建筑样式 */
.office-building {
  width: 200px;
  height: 150px;
  position: relative;
}

.building-structure {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #1e40af, #3b82f6);
  border-radius: 8px;
  position: relative;
}

.building-floor {
  height: 25%;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.building-windows {
  position: absolute;
  top: 10px;
  left: 10px;
  right: 10px;
}

.window-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 15px;
}

.window {
  width: 20px;
  height: 15px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 2px;
}

/* 工厂场景样式 */
.factory-scene {
  width: 250px;
  height: 120px;
  position: relative;
}

.production-line {
  display: flex;
  align-items: center;
  gap: 20px;
}

.machine {
  width: 60px;
  height: 40px;
  background: #64748b;
  border-radius: 4px;
  position: relative;
}

.machine::before {
  content: '';
  position: absolute;
  top: 5px;
  left: 5px;
  right: 5px;
  height: 8px;
  background: #94a3b8;
  border-radius: 2px;
}

.conveyor {
  width: 80px;
  height: 10px;
  background: #cbd5e1;
  border-radius: 2px;
}

/* 工厂建筑样式 */
.factory-building {
  width: 180px;
  height: 120px;
  position: relative;
}

.factory-structure {
  width: 100%;
  height: 100%;
  background: #475569;
  border-radius: 8px;
  position: relative;
}

.factory-roof {
  height: 20px;
  background: #1e293b;
  border-radius: 8px 8px 0 0;
}

.factory-body {
  height: 80px;
  padding: 10px;
}

.factory-door {
  width: 30px;
  height: 50px;
  background: #1e293b;
  border-radius: 4px;
  margin: 0 auto 10px;
}

.factory-windows {
  display: flex;
  justify-content: space-around;
}

.factory-window {
  width: 15px;
  height: 12px;
  background: #60a5fa;
  border-radius: 2px;
}

.smoke-stack {
  position: absolute;
  top: -20px;
  right: 20px;
  width: 20px;
  height: 30px;
  background: #64748b;
  border-radius: 2px;
}

.smoke {
  position: absolute;
  top: -10px;
  left: 50%;
  transform: translateX(-50%);
  width: 8px;
  height: 15px;
  background: #94a3b8;
  border-radius: 4px;
}

/* 联系信息样式 */
.contact-section {
  background: #f8fafc;
  padding: 60px 0;
  border-radius: 12px;
}

.contact-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
}

.contact-item {
  text-align: center;
  padding: 30px 20px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s;
}

.contact-item:hover {
  transform: translateY(-5px);
}

.contact-icon {
  font-size: 2.5rem;
  margin-bottom: 15px;
}

.contact-item h3 {
  font-size: 1.2rem;
  color: #1e293b;
  margin-bottom: 10px;
}

.contact-item p {
  color: #64748b;
  line-height: 1.6;
}

.main-business-img {
  width: 100%;
  max-width: 400px;
  height: 250px;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  background-color: #f8f9fa;
}

.company-intro-img {
  width: 100%;
  max-width: 400px;
  height: 250px;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  background-color: #f8f9fa;
}

.loading-section {
  text-align: center;
  padding: 60px 0;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e5e7eb;
  border-top: 4px solid #1e40af;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header h1 {
    font-size: 2rem;
  }
  
  .section-content {
    grid-template-columns: 1fr;
    gap: 30px;
  }
  
  .info-section {
    flex-direction: column;
    text-align: center;
  }
  
  .contact-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .section-header h2 {
    font-size: 1.5rem;
  }
}
</style> 