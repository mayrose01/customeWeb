<template>
  <div class="mall-categories-page">
    <ClientHeader />
    
    <main class="main-content">
      <div class="container">
        <div class="page-header">
          <h1>商品分类</h1>
          <p>浏览所有商品分类，找到您需要的产品</p>
        </div>

        <div class="categories-grid">
          <div 
            v-for="category in categories" 
            :key="category.id"
            class="category-card"
            @click="goToCategory(category.id)"
          >
            <div class="category-icon">
              <span>📦</span>
            </div>
            <h3>{{ category.name }}</h3>
            <p>{{ category.description || '暂无描述' }}</p>
            <div class="category-stats">
              <span>{{ category.product_count || 0 }} 个产品</span>
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
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { getClientPath } from '@/utils/pathUtils'

export default {
  name: 'MallCategories',
  components: {
    ClientHeader,
    ClientFooter
  },
  setup() {
    const router = useRouter()
    const categories = ref([])
    
    const loadCategories = async () => {
      try {
        // TODO: 调用API加载分类数据
        // 模拟数据
        categories.value = [
          { id: 1, name: '电子产品', description: '手机、电脑、配件等', product_count: 25 },
          { id: 2, name: '服装鞋帽', description: '男装、女装、童装等', product_count: 18 },
          { id: 3, name: '家居用品', description: '家具、装饰、厨具等', product_count: 32 },
          { id: 4, name: '美妆护肤', description: '护肤品、彩妆、香水等', product_count: 15 },
          { id: 5, name: '运动户外', description: '运动装备、户外用品等', product_count: 22 },
          { id: 6, name: '图书音像', description: '图书、音乐、电影等', product_count: 28 }
        ]
      } catch (error) {
        console.error('加载分类失败:', error)
      }
    }
    
    const goToCategory = (categoryId) => {
      router.push(getClientPath(`/mall/products?category=${categoryId}`))
    }
    
    onMounted(() => {
      loadCategories()
    })
    
    return {
      categories,
      goToCategory,
      getClientPath
    }
  }
}
</script>

<style scoped>
.mall-categories-page {
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
  margin-bottom: 50px;
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

.categories-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 30px;
}

.category-card {
  background: white;
  padding: 40px 30px;
  border-radius: 16px;
  text-align: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
}

.category-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
}

.category-icon {
  font-size: 4rem;
  margin-bottom: 25px;
}

.category-card h3 {
  font-size: 1.5rem;
  color: var(--color-text-primary);
  margin-bottom: 15px;
  font-weight: 600;
}

.category-card p {
  color: var(--color-text-secondary);
  line-height: 1.6;
  margin-bottom: 20px;
}

.category-stats {
  color: var(--color-primary);
  font-weight: 500;
  font-size: 0.9rem;
}

@media (max-width: 768px) {
  .categories-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .page-header h1 {
    font-size: 2rem;
  }
}
</style>
