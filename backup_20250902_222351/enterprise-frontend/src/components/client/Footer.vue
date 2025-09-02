<template>
  <footer class="footer">
    <div class="container">

      
      <div class="footer-content">
        <div class="footer-section">
          <h3>联系我们</h3>
          <div class="contact-info">
            <p v-if="companyInfo.address">
              <i class="icon-location"></i>
              {{ companyInfo.address }}
            </p>
            <p v-if="companyInfo.email">
              <i class="icon-email"></i>
              {{ companyInfo.email }}
            </p>
            <p v-if="companyInfo.phone">
              <i class="icon-phone"></i>
              {{ companyInfo.phone }}
            </p>
          </div>
        </div>

        <div class="footer-section">
          <h3>快速导航</h3>
          <ul class="nav-links">
            <li><router-link :to="getClientPath('/')">首页</router-link></li>
            <li><router-link :to="getClientPath('/all-products')">产品列表</router-link></li>
            <!-- <li><router-link :to="getClientPath('/mall')">商城</router-link></li> -->
            <li><router-link :to="getClientPath('/about')">关于我们</router-link></li>
            <li><router-link :to="getClientPath('/contact')">联系我们</router-link></li>
          </ul>
        </div>

        <div class="footer-section">
          <h3>公司信息</h3>
          <div class="company-info">
            <p v-if="companyInfo.name">{{ companyInfo.name }}</p>
            <p v-if="companyInfo.main_business">{{ companyInfo.main_business }}</p>
          </div>
        </div>
      </div>

      <div class="footer-bottom">
        <p>&copy; {{ new Date().getFullYear() }} {{ companyInfo.name || '企业官网' }}. 版权所有.</p>
      </div>
    </div>
  </footer>
</template>

<script>
import { ref, onMounted } from 'vue'
import { getCompanyInfo } from '@/api/client'
import { getClientPath } from '@/utils/pathUtils'

export default {
  name: 'ClientFooter',
  setup() {
    const companyInfo = ref({})

    const loadCompanyInfo = async () => {
      try {
        const response = await getCompanyInfo()
        companyInfo.value = response.data
      } catch (error) {
        console.error('加载公司信息失败:', error)
      }
    }

    onMounted(() => {
      loadCompanyInfo()
    })

    return {
      companyInfo,
      getClientPath
    }
  }
}
</script>

<style scoped>
.footer {
  background: var(--color-navbar-bg);
  color: white;
  padding: 40px 0 20px;
  margin-top: auto;
  flex-shrink: 0;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.footer-content {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 40px;
  margin-bottom: 30px;
}

.footer-section h3 {
  color: var(--color-primary-light);
  margin-bottom: 15px;
  font-size: 18px;
}

.contact-info p {
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.nav-links {
  list-style: none;
  padding: 0;
}

.nav-links li {
  margin-bottom: 8px;
}

.nav-links a {
  color: var(--color-accent-light);
  text-decoration: none;
  transition: color 0.3s;
  background: transparent;
}

.nav-links a:hover {
  color: var(--color-primary-light);
  background: transparent;
}

.company-info p {
  margin-bottom: 8px;
  color: var(--color-accent-light);
}

.footer-bottom {
  border-top: 1px solid var(--color-accent-dark);
  padding-top: 20px;
  text-align: center;
  color: var(--color-text-muted);
}

/* 图标样式 */
.icon-location::before {
  content: '📍';
}

.icon-email::before {
  content: '📧';
}

.icon-phone::before {
  content: '📞';
}

/* 响应式设计 */
@media (max-width: 768px) {
  .footer-content {
    grid-template-columns: 1fr;
    gap: 30px;
  }
  
  .footer {
    padding: 30px 0 15px;
  }
}
</style> 