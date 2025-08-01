import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Dashboard from '../views/Dashboard.vue'
import CompanyInfo from '../views/CompanyInfo.vue'
import CategoryManage from '../views/CategoryManage.vue'
import ProductManage from '../views/ProductManage.vue'
import InquiryManage from '../views/InquiryManage.vue'
import CarouselManage from '../views/CarouselManage.vue'
import ContactMessageManage from '../views/ContactMessageManage.vue'
import ServiceManage from '../views/ServiceManage.vue'
import UserManage from '../views/UserManage.vue'

// 前端客户展示网站页面
import ClientHome from '../views/client/Home.vue'
import ClientCategories from '../views/client/Categories.vue'
import ClientSubCategories from '../views/client/SubCategories.vue'
import ClientProductDetail from '../views/client/ProductDetail.vue'
import ClientAbout from '../views/client/About.vue'
import ClientContact from '../views/client/Contact.vue'
import ClientAllProducts from '../views/client/AllProducts.vue'
import ClientLogin from '../views/client/Login.vue'
import ClientRegister from '../views/client/Register.vue'
import ClientProfile from '../views/client/Profile.vue'
import ClientInquiries from '../views/client/Inquiries.vue'
import ClientConsultations from '../views/client/Consultations.vue'

// 检测当前环境
const isTestEnvironment = () => {
  return window.location.pathname.startsWith('/test')
}

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    // 测试环境路由（带/test前缀）
    {
      path: '/test',
      children: [
        // 测试环境后台管理路由
        {
          path: 'admin/login',
          name: 'test-login',
          component: Login
        },
        {
          path: 'admin',
          name: 'test-dashboard',
          component: Dashboard,
          redirect: '/test/admin/company',
          meta: { requiresAuth: true, environment: 'test' },
          children: [
            {
              path: 'company',
              name: 'test-company',
              component: CompanyInfo
            },
            {
              path: 'category',
              name: 'test-category',
              component: CategoryManage
            },
            {
              path: 'product',
              name: 'test-product',
              component: ProductManage
            },
            {
              path: 'inquiry',
              name: 'test-inquiry',
              component: InquiryManage
            },
            {
              path: 'carousel',
              name: 'test-carousel',
              component: CarouselManage
            },
            {
              path: 'contact-message',
              name: 'test-contact-message',
              component: ContactMessageManage
            },
            {
              path: 'service',
              name: 'test-service',
              component: ServiceManage
            },
            {
              path: 'user',
              name: 'test-user',
              component: UserManage
            }
          ]
        },
        
        // 测试环境前端客户展示网站路由
        {
          path: '',
          name: 'test-client-home',
          component: ClientHome
        },
        {
          path: 'categories',
          name: 'test-client-categories',
          component: ClientCategories
        },
        {
          path: 'all-products',
          name: 'test-client-all-products',
          component: ClientAllProducts
        },
        {
          path: 'categories/:id',
          name: 'test-client-subcategories',
          component: ClientSubCategories
        },
        {
          path: 'product/:id',
          name: 'test-client-product-detail',
          component: ClientProductDetail
        },
        {
          path: 'about',
          name: 'test-client-about',
          component: ClientAbout
        },
        {
          path: 'contact',
          name: 'test-client-contact',
          component: ClientContact
        },
        {
          path: 'login',
          name: 'test-client-login',
          component: ClientLogin
        },
        {
          path: 'register',
          name: 'test-client-register',
          component: ClientRegister
        },
        {
          path: 'profile',
          name: 'test-client-profile',
          component: ClientProfile
        },
        {
          path: 'inquiries',
          name: 'test-client-inquiries',
          component: ClientInquiries
        },
        {
          path: 'consultations',
          name: 'test-client-consultations',
          component: ClientConsultations
        }
      ]
    },
    
    // 开发环境后台管理路由
    {
      path: '/admin/login',
      name: 'login',
      component: Login
    },
    {
      path: '/admin',
      name: 'dashboard',
      component: Dashboard,
      redirect: '/admin/company',
      meta: { requiresAuth: true, environment: 'development' },
      children: [
        {
          path: 'company',
          name: 'company',
          component: CompanyInfo
        },
        {
          path: 'category',
          name: 'category',
          component: CategoryManage
        },
        {
          path: 'product',
          name: 'product',
          component: ProductManage
        },
        {
          path: 'inquiry',
          name: 'inquiry',
          component: InquiryManage
        },
        {
          path: 'carousel',
          name: 'carousel',
          component: CarouselManage
        },
        {
          path: 'contact-message',
          name: 'contact-message',
          component: ContactMessageManage
        },
        {
          path: 'service',
          name: 'service',
          component: ServiceManage
        },
        {
          path: 'user',
          name: 'user',
          component: UserManage
        }
      ]
    },
    
    // 开发环境前端客户展示网站路由
    {
      path: '/',
      name: 'client-home',
      component: ClientHome
    },
    {
      path: '/categories',
      name: 'client-categories',
      component: ClientCategories
    },
    {
      path: '/all-products',
      name: 'client-all-products',
      component: ClientAllProducts
    },
    {
      path: '/categories/:id',
      name: 'client-subcategories',
      component: ClientSubCategories
    },
    {
      path: '/product/:id',
      name: 'client-product-detail',
      component: ClientProductDetail
    },
    {
      path: '/about',
      name: 'client-about',
      component: ClientAbout
    },
    {
      path: '/contact',
      name: 'client-contact',
      component: ClientContact
    },
    {
      path: '/login',
      name: 'client-login',
      component: ClientLogin
    },
    {
      path: '/register',
      name: 'client-register',
      component: ClientRegister
    },
    {
      path: '/profile',
      name: 'client-profile',
      component: ClientProfile
    },
    {
      path: '/inquiries',
      name: 'client-inquiries',
      component: ClientInquiries
    },
    {
      path: '/consultations',
      name: 'client-consultations',
      component: ClientConsultations
    }
  ]
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  
  if (to.meta.requiresAuth && !token) {
    // 根据当前环境重定向到对应的登录页面
    if (isTestEnvironment()) {
      next('/test/admin/login')
    } else {
      next('/admin/login')
    }
  } else {
    next()
  }
})

export default router 