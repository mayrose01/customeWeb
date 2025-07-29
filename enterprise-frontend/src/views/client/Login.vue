<template>
  <div class="login-page">
    <ClientHeader />
    
    <div class="login-container">
      <LoginForm 
        initial-mode="login"
        :redirect-to="redirectTo"
        @login-success="handleLoginSuccess"
      />
    </div>
    
    <ClientFooter />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import LoginForm from '@/components/client/LoginForm.vue'

const route = useRoute()

// 获取重定向地址，默认为首页
const redirectTo = computed(() => {
  return route.query.redirect || '/'
})

const handleLoginSuccess = (userData) => {
  console.log('登录成功:', userData)
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  background: #f8f9fa;
  padding-top: 80px;
}

.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 80px - 200px);
  padding: 20px;
  width: 100%;
  max-width: 100%;
}

@media (min-width: 1200px) {
  .login-container {
    padding: 40px 20px;
  }
}

@media (max-width: 767px) {
  .login-container {
    padding: 15px;
  }
}
</style> 