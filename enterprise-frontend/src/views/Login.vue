<template>
  <div class="login-bg">
    <div class="login-container">
      <el-card>
        <h2 style="text-align:center;">后台登录</h2>
        <el-form :model="form" @submit.prevent="onLogin">
          <el-form-item label="用户名">
            <el-input v-model="form.username" autocomplete="off" />
          </el-form-item>
          <el-form-item label="密码">
            <el-input v-model="form.password" type="password" autocomplete="off" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onLogin" :loading="loading" style="width:100%;">登录</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { login } from '../api/user';
import { ElMessage } from 'element-plus'

const router = useRouter();
const form = ref({ username: '', password: '' });
const loading = ref(false);

// 检测当前环境
const isTestEnvironment = () => {
  return window.location.pathname.startsWith('/test')
}

const onLogin = async () => {
  loading.value = true;
  try {
    const res = await login(form.value.username, form.value.password);
    localStorage.setItem('token', res.data.access_token);
    ElMessage.success('登录成功')
    
    // 根据当前环境跳转到对应的管理页面
    if (isTestEnvironment()) {
      router.push('/test/admin');
    } else {
      router.push('/admin');
    }
  } catch (e) {
    // 显示后端返回的具体错误信息
    const errorMessage = e.response?.data?.detail || '登录失败，请稍后重试';
    ElMessage.error(errorMessage);
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-bg {
  width: 100vw;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f6fffa;
}
.login-container {
  width: 50vw;
  min-width: 320px;
  max-width: 600px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style> 