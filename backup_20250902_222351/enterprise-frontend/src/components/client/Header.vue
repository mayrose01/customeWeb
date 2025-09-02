<template>
  <header class="header">
    <!-- 顶部联系信息栏 -->
    <div class="top-bar">
      <div class="container">
        <div class="top-bar-content">
          <div class="company-name">
            <span v-if="companyInfo.name">{{ companyInfo.name }}</span>
            <span v-else>企业官网</span>
          </div>
          <div class="contact-info">
            <div class="contact-item" v-if="companyInfo.email">
              <i class="icon-email"></i>
              <span>{{ companyInfo.email }}</span>
            </div>
            <div class="contact-item" v-if="companyInfo.phone">
              <i class="icon-phone"></i>
              <span>{{ companyInfo.phone }}</span>
            </div>
            <router-link :to="getClientPath('/contact')" class="consult-btn">免费咨询</router-link>
            
            <!-- 用户登录区域 -->
            <div class="user-section">
              <div v-if="!userStore.isLoggedIn" class="login-buttons">
                <router-link :to="getClientPath('/login')" class="login-btn">登录</router-link>
                <router-link :to="getClientPath('/register')" class="register-btn">注册</router-link>
              </div>
              <div v-else class="user-info">
                <div class="user-dropdown" @click="toggleUserDropdown">
                  <div class="user-avatar">
                    <img v-if="userStore.userInfo.avatar_url" :src="userStore.userInfo.avatar_url" :alt="userStore.userInfo.username" />
                    <div v-else class="avatar-placeholder">{{ userStore.userInfo.username?.charAt(0) || 'U' }}</div>
                  </div>
                  <span class="username">{{ userStore.userInfo.username }}</span>
                  <span class="dropdown-arrow" :class="{ 'rotated': isUserDropdownVisible }">▼</span>
                </div>
                <div class="user-dropdown-menu" v-show="isUserDropdownVisible">
                  <div class="dropdown-item" @click="goToProfile">
                    <i class="icon-user"></i>
                    <span>个人中心</span>
                  </div>
                  <div class="dropdown-item" @click="goToInquiries">
                    <i class="icon-inquiry"></i>
                    <span>询价列表</span>
                  </div>
                  <div class="dropdown-item" @click="goToConsultations">
                    <i class="icon-consultation"></i>
                    <span>咨询列表</span>
                  </div>
                  <div class="dropdown-divider"></div>
                  <div class="dropdown-item" @click="handleLogout">
                    <i class="icon-logout"></i>
                    <span>退出登录</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 导航栏 -->
    <nav class="navbar">
      <div class="container">
        <div class="nav-content">
          <div class="logo">
            <router-link :to="getClientPath('/')">
              <img v-if="companyInfo.logo_url" :src="companyInfo.logo_url" :alt="companyInfo.name" />
              <span v-else>{{ companyInfo.name || '企业官网' }}</span>
            </router-link>
          </div>
          
          <div class="nav-menu">
            <router-link :to="getClientPath('/')" class="nav-item" active-class="active">首页</router-link>
            <div class="nav-item dropdown" :class="{ active: isCategoriesDropdownVisible }">
              <span class="dropdown-trigger" @click="toggleCategoriesDropdown">分类</span>
              <div class="dropdown-menu" v-show="isCategoriesDropdownVisible">
                <div class="dropdown-content">
                  <div 
                    v-for="category in topCategories" 
                    :key="category.id"
                    class="dropdown-item category-item"
                  >
                    <div class="category-header" @click="toggleSubcategories(category.id)">
                      <span class="category-name">{{ category.name }}</span>
                      <span class="category-arrow" :class="{ 'rotated': activeCategoryId === category.id }">▶</span>
                    </div>
                    <div class="subcategories-container" v-show="activeCategoryId === category.id">
                      <div 
                        v-for="subcategory in subcategories" 
                        :key="subcategory.id"
                        class="subcategory-item"
                        @click="goToSubCategories(subcategory.id)"
                      >
                        {{ subcategory.name }}
                      </div>
                    </div>
                  </div>
                  <div class="dropdown-item view-all" @click="goToAllProducts">
                    <span>查看所有产品</span>
                  </div>
                </div>
              </div>
            </div>
            <router-link :to="getClientPath('/about')" class="nav-item" active-class="active">关于</router-link>
            <router-link :to="getClientPath('/contact')" class="nav-item" active-class="active">联系我们</router-link>
          </div>

          <div class="search-box">
            <input type="text" placeholder="搜索" v-model="searchKeyword" @keyup.enter="handleSearch" />
            <button @click="handleSearch">
              <i class="icon-search"></i>
            </button>
          </div>
          
          <!-- 购物车图标 -->
          <div class="cart-icon" @click="goToCart">
            <i class="icon-cart"></i>
            <span v-if="cartItemCount > 0" class="cart-badge">{{ cartItemCount }}</span>
          </div>
        </div>
      </div>
    </nav>
    

  </header>
</template>

<script>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { getCompanyInfo } from '@/api/client'
import { getCategories, getSubcategories } from '@/api/category'
import { userStore } from '@/store/user'
import { getClientPath } from '@/utils/pathUtils'

export default {
  name: 'ClientHeader',

  setup() {
    const router = useRouter()
    const companyInfo = ref({})
    const searchKeyword = ref('')
    
    // 用户下拉菜单状态
    const isUserDropdownVisible = ref(false)
    
    // 下拉菜单相关状态
    const isCategoriesDropdownVisible = ref(false)
    const topCategories = ref([])
    const subcategories = ref([])
    const activeCategoryId = ref(null)

    const loadCompanyInfo = async () => {
      try {
        const response = await getCompanyInfo()
        companyInfo.value = response.data
      } catch (error) {
        console.error('加载公司信息失败:', error)
      }
    }



    // 切换用户下拉菜单
    const toggleUserDropdown = () => {
      isUserDropdownVisible.value = !isUserDropdownVisible.value
    }

    // 跳转到个人中心
    const goToProfile = () => {
      router.push(getClientPath('/profile'))
      isUserDropdownVisible.value = false
    }

    // 跳转到询价列表
    const goToInquiries = () => {
      router.push(getClientPath('/inquiries'))
      isUserDropdownVisible.value = false
    }

    // 跳转到咨询列表
    const goToConsultations = () => {
      router.push(getClientPath('/consultations'))
      isUserDropdownVisible.value = false
    }

    // 处理登出
    const handleLogout = () => {
      userStore.logout()
      isUserDropdownVisible.value = false
      router.push(getClientPath('/'))
    }

    const loadTopCategories = async () => {
      try {
        const response = await getCategories()
        // 只获取顶级分类（parent_id为null）
        topCategories.value = response.data.filter(cat => !cat.parent_id)
      } catch (error) {
        console.error('加载分类失败:', error)
      }
    }

    const toggleCategoriesDropdown = () => {
      isCategoriesDropdownVisible.value = !isCategoriesDropdownVisible.value
      if (!isCategoriesDropdownVisible.value) {
        activeCategoryId.value = null
        subcategories.value = []
      }
    }

    const toggleSubcategories = async (categoryId) => {
      if (activeCategoryId.value === categoryId) {
        activeCategoryId.value = null
        subcategories.value = []
      } else {
        activeCategoryId.value = categoryId
        try {
          const response = await getSubcategories(categoryId)
          subcategories.value = response.data
        } catch (error) {
          console.error('加载子分类失败:', error)
        }
      }
    }

    const goToSubCategories = (categoryId) => {
      router.push(getClientPath(`/categories/${categoryId}`))
      isCategoriesDropdownVisible.value = false
      activeCategoryId.value = null
    }

    const goToAllProducts = () => {
      router.push(getClientPath('/all-products'))
      isCategoriesDropdownVisible.value = false
    }

    const handleSearch = () => {
      if (searchKeyword.value.trim()) {
        router.push({
          path: getClientPath('/all-products'),
          query: { search: searchKeyword.value }
        })
      }
    }

    // 点击外部关闭下拉菜单
    const handleClickOutside = (event) => {
      const userDropdown = event.target.closest('.user-dropdown')
      const categoriesDropdown = event.target.closest('.dropdown')
      
      if (!userDropdown) {
        isUserDropdownVisible.value = false
      }
      
      if (!categoriesDropdown) {
        isCategoriesDropdownVisible.value = false
        activeCategoryId.value = null
      }
    }

    // 检查登录状态
    const checkLoginStatus = () => {
      userStore.checkLoginStatus()
    }

    // 监听userStore的变化
    watch(() => userStore.userInfo, (newUserInfo) => {
      console.log('用户信息已更新:', newUserInfo)
    }, { deep: true })

    onMounted(() => {
      checkLoginStatus()
      loadCompanyInfo()
      loadTopCategories()
      document.addEventListener('click', handleClickOutside)
    })

    onUnmounted(() => {
      document.removeEventListener('click', handleClickOutside)
    })

          return {
        companyInfo,
        searchKeyword,
        userStore,
        isUserDropdownVisible,
        isCategoriesDropdownVisible,
        topCategories,
        subcategories,
        activeCategoryId,
        toggleUserDropdown,
        goToProfile,
        goToInquiries,
        goToConsultations,
        handleLogout,
        toggleCategoriesDropdown,
        toggleSubcategories,
        goToSubCategories,
        goToAllProducts,
        handleSearch,
        getClientPath
      }
  }
}
</script>

<style scoped>
.header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  background: white;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.top-bar {
  background: var(--color-background);
  color: var(--color-text-primary);
  padding: 8px 0;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.top-bar-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
}

.company-name {
  font-weight: bold;
}

.contact-info {
  display: flex;
  align-items: center;
  gap: 20px;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 5px;
}

.consult-btn {
  background: var(--color-btn-primary);
  color: white;
  padding: 6px 16px;
  border-radius: 4px;
  text-decoration: none;
  font-weight: 500;
  transition: background-color 0.3s;
}

.consult-btn:hover {
  background: var(--color-btn-primary-hover);
}

.navbar {
  background: var(--color-navbar-bg);
  padding: 15px 0;
}

.nav-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo a {
  display: flex;
  align-items: center;
  text-decoration: none;
  color: var(--color-navbar-text);
  font-size: 24px;
  font-weight: bold;
}

.logo img {
  height: 40px;
  margin-right: 10px;
}

.nav-menu {
  display: flex;
  gap: 30px;
}

.nav-item {
  text-decoration: none;
  color: var(--color-navbar-text);
  font-weight: 500;
  padding: 8px 0;
  position: relative;
  transition: color 0.3s;
}

.nav-item:hover,
.nav-item.active {
  color: var(--color-navbar-active);
  background: transparent;
}

.nav-item.active::after {
  content: '';
  position: absolute;
  bottom: -15px;
  left: 0;
  right: 0;
  height: 2px;
  background: var(--color-navbar-active);
}

/* 下拉菜单样式 */
.dropdown {
  position: relative;
  cursor: pointer;
}

.dropdown-trigger {
  display: flex;
  align-items: center;
  gap: 5px;
  cursor: pointer;
}

.dropdown-trigger::after {
  content: '▼';
  font-size: 10px;
  margin-left: 5px;
  transition: transform 0.3s;
}

.dropdown.active .dropdown-trigger::after {
  transform: rotate(180deg);
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  left: 0;
  background: var(--color-background);
  border: 1px solid var(--color-accent-dark);
  border-radius: 8px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  min-width: 200px;
  z-index: 1000;
  margin-top: 5px;
  padding: 5px 0;
}

.dropdown-content {
  padding: 8px 0;
}

.dropdown-item {
  position: relative;
  padding: 10px 16px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.dropdown-item:hover {
  background: var(--color-accent-light);
  color: var(--color-text-primary);
}

.category-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  padding: 5px 0;
}

.category-header:hover {
  background: var(--color-accent);
  color: var(--color-text-primary);
}

.category-name {
  font-weight: 500;
  color: var(--color-text-secondary);
}

.category-arrow {
  font-size: 10px;
  color: var(--color-text-muted);
  transition: transform 0.3s;
}

.category-arrow.rotated {
  transform: rotate(90deg);
}

.subcategories-container {
  position: absolute;
  left: 100%;
  top: 0;
  background: var(--color-background);
  border: 1px solid var(--color-accent-dark);
  border-radius: 8px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  min-width: 180px;
  z-index: 1001;
  margin-left: 2px;
  padding: 8px 0;
}

.subcategory-item {
  padding: 12px 16px;
  cursor: pointer;
  transition: background-color 0.2s;
  color: var(--color-text-secondary);
  white-space: nowrap;
  border-bottom: 1px solid var(--color-accent);
}

.subcategory-item:last-child {
  border-bottom: none;
}

.subcategory-item:hover {
  background: var(--color-accent-light);
  color: var(--color-primary);
}

.view-all {
  border-top: 1px solid var(--color-accent-dark);
  margin-top: 8px;
  padding-top: 8px;
}

.view-all span {
  color: var(--color-primary);
  font-weight: 500;
}

.search-box {
  display: flex;
  align-items: center;
  border: 1px solid transparent;
  border-radius: 4px;
  overflow: hidden;
  background: white;
}

.search-box input {
  border: none;
  padding: 8px 12px;
  outline: none;
  width: 200px;
  background: white;
}

.search-box button {
  background: var(--color-primary);
  color: white;
  border: none;
  padding: 8px 12px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.search-box button:hover {
  background: var(--color-primary-hover);
}

/* 用户登录区域样式 */
.user-section {
  display: flex;
  align-items: center;
}

.login-buttons {
  display: flex;
  gap: 10px;
}

.login-btn, .register-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
  display: inline-block;
}

.login-btn {
  background-color: #3b82f6;
  color: white;
}

.login-btn:hover {
  background-color: #2563eb;
  color: white;
  text-decoration: none;
}

.register-btn {
  background-color: #10b981;
  color: white;
}

.register-btn:hover {
  background-color: #059669;
  color: white;
  text-decoration: none;
}

.user-info {
  position: relative;
}

.user-dropdown {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.user-dropdown:hover {
  background-color: rgba(59, 130, 246, 0.1);
}

.user-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  overflow: hidden;
}

.user-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  background-color: #3b82f6;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 14px;
}

.username {
  font-size: 14px;
  color: #333;
  font-weight: 500;
}

.dropdown-arrow {
  font-size: 10px;
  color: #666;
  transition: transform 0.2s;
}

.dropdown-arrow.rotated {
  transform: rotate(180deg);
}

.user-dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  background: white;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  min-width: 150px;
  z-index: 1000;
  margin-top: 4px;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px;
  cursor: pointer;
  transition: background-color 0.2s;
  font-size: 14px;
}

.dropdown-item:hover {
  background-color: #f5f5f5;
}

.dropdown-item i {
  font-size: 16px;
  color: #666;
}

.dropdown-divider {
  height: 1px;
  background-color: #eee;
  margin: 4px 0;
}

/* 图标样式 */
.icon-email::before {
  content: '📧';
}

.icon-phone::before {
  content: '📞';
}

.icon-search::before {
  content: '🔍';
}

.icon-user::before { content: "👤"; }
.icon-inquiry::before { content: "📋"; }
.icon-consultation::before { content: "💬"; }
.icon-logout::before { content: "🚪"; }

/* 响应式设计 */
@media (max-width: 768px) {
  .top-bar-content {
    flex-direction: column;
    gap: 10px;
  }
  
  .contact-info {
    gap: 10px;
  }
  
  .nav-content {
    flex-direction: column;
    gap: 15px;
  }
  
  .nav-menu {
    gap: 15px;
  }
  
  .search-box input {
    width: 150px;
  }

  .user-dropdown {
    padding: 2px 4px;
  }
  
  .username {
    display: none;
  }
  
  .user-dropdown-menu {
    right: -50px;
  }
}
</style> 