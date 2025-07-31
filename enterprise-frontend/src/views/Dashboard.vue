<template>
  <div class="dashboard-container">
    <el-aside width="200px" class="sidebar">
      <div class="sidebar-header">
        <h3>企业后台管理系统</h3>
      </div>
      <el-menu :default-active="activeMenu" router class="sidebar-menu">
        <el-menu-item :index="getMenuPath('/admin/company')">
          <el-icon><Document /></el-icon>
          <span>公司信息</span>
        </el-menu-item>
        <el-menu-item :index="getMenuPath('/admin/carousel')">
          <el-icon><Picture /></el-icon>
          <span>轮播图管理</span>
        </el-menu-item>
        <el-menu-item :index="getMenuPath('/admin/service')">
          <el-icon><Star /></el-icon>
          <span>业务板块</span>
        </el-menu-item>
        <el-menu-item :index="getMenuPath('/admin/category')">
          <el-icon><Menu /></el-icon>
          <span>分类管理</span>
        </el-menu-item>
        <el-menu-item :index="getMenuPath('/admin/product')">
          <el-icon><Goods /></el-icon>
          <span>产品管理</span>
        </el-menu-item>
        <el-menu-item :index="getMenuPath('/admin/inquiry')">
          <el-icon><Message /></el-icon>
          <span>询价管理</span>
        </el-menu-item>
        <el-menu-item :index="getMenuPath('/admin/contact-message')">
          <el-icon><ChatDotRound /></el-icon>
          <span>联系消息</span>
        </el-menu-item>
        <el-menu-item :index="getMenuPath('/admin/user')">
          <el-icon><UserFilled /></el-icon>
          <span>用户管理</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <div class="main-content">
      <el-header class="main-header">
        <span class="header-title">企业后台管理系统</span>
        <el-button @click="logout" type="danger" size="small">退出</el-button>
      </el-header>
      <div class="content-area">
        <ContentContainer>
          <router-view />
        </ContentContainer>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter, useRoute } from 'vue-router';
import { computed } from 'vue';
import { Document, Menu, Goods, Message, Picture, Star, ChatDotRound, UserFilled } from '@element-plus/icons-vue';
import ContentContainer from '../components/ContentContainer.vue';

const router = useRouter();
const route = useRoute();

// 检测当前环境
const isTestEnvironment = () => {
  return window.location.pathname.startsWith('/test')
}

// 根据环境获取菜单路径
const getMenuPath = (path) => {
  if (isTestEnvironment()) {
    return path.replace('/admin/', '/test/admin/')
  }
  return path
}

const activeMenu = computed(() => {
  // 确保路径格式一致
  const path = route.path;
  if (path === '/admin' || path === '/test/admin') {
    return isTestEnvironment() ? '/test/admin/company' : '/admin/company';
  }
  return path;
});

const logout = () => {
  localStorage.removeItem('token');
  // 根据当前环境跳转到对应的登录页面
  if (isTestEnvironment()) {
    router.push('/test/admin/login');
  } else {
    router.push('/admin/login');
  }
};
</script>

<style scoped>
.dashboard-container {
  display: flex;
  height: 100vh;
  width: 100vw;
  margin: 0;
  padding: 0;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
}

/* 确保没有全局边距 */
:global(body), :global(html) {
  margin: 0;
  padding: 0;
  overflow: hidden;
}

.sidebar {
  background-color: #f5f5f5;
  border-right: 1px solid #e6e6e6;
  flex-shrink: 0;
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.sidebar-header {
  padding: 20px 0;
  text-align: center;
  border-bottom: 1px solid #e6e6e6;
}

.sidebar-header h3 {
  margin: 0;
  color: #409EFF;
}

.sidebar-menu {
  border-right: none;
  flex: 1;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0; /* 重要：防止flex子元素溢出 */
}

.main-header {
  background-color: #fff;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  flex-shrink: 0;
}

.header-title {
  font-size: 18px;
  font-weight: bold;
}

.content-area {
  flex: 1;
  background-color: #f9f9f9;
  overflow-y: auto;
  overflow-x: hidden;
  min-height: 0; /* 重要：允许flex子元素收缩 */
  width: 100%;
  padding: 0;
}
</style> 