<!--
LoginForm 组件使用说明：

这是一个可复用的登录/注册表单组件，支持以下功能：

1. 登录和注册功能集成在一个组件中
2. 支持通过 initialMode 属性设置初始模式（'login' 或 'register'）
3. 支持通过 redirectTo 属性设置登录成功后的跳转地址
4. 支持通过 onSuccess 回调函数处理登录/注册成功事件
5. 支持通过 @login-success 和 @register-success 事件监听成功事件

使用示例：

1. 在页面中使用：
<template>
  <div>
    <LoginForm 
      initial-mode="login"
      :redirect-to="/profile"
      @login-success="handleLoginSuccess"
    />
  </div>
</template>

2. 在弹窗中使用：
<template>
  <div v-if="showLogin" class="modal">
    <LoginForm 
      initial-mode="register"
      :redirect-to="/"
      @register-success="handleRegisterSuccess"
    />
  </div>
</template>

Props:
- initialMode: String - 初始模式，'login' 或 'register'，默认为 'login'
- onSuccess: Function - 登录/注册成功回调函数
- redirectTo: String - 登录成功后的跳转地址，默认为 '/'

Events:
- login-success: 登录成功时触发，参数为用户数据
- register-success: 注册成功时触发，参数为注册响应数据
-->

<template>
  <div class="auth-form-container">
    <div class="auth-card">
      <div class="auth-header">
        <h2>{{ isLogin ? '用户登录' : '用户注册' }}</h2>
        <p>{{ isLogin ? '欢迎回到我们的企业官网' : '加入我们的企业官网，享受更多服务' }}</p>
      </div>
      
      <!-- 登录表单 -->
      <form v-if="isLogin" @submit.prevent="handleLogin" class="auth-form">
        <div class="form-group">
          <label for="username">用户名/邮箱/手机号</label>
          <input
            id="username"
            v-model="loginForm.username"
            type="text"
            placeholder="请输入用户名、邮箱或手机号"
            required
          />
        </div>
        
        <div class="form-group">
          <label for="password">密码</label>
          <div class="password-input-wrapper">
            <input
              id="password"
              v-model="loginForm.password"
              :type="showLoginPassword ? 'text' : 'password'"
              placeholder="请输入密码"
              required
            />
            <button 
              type="button" 
              class="password-toggle-btn"
              @click="toggleLoginPassword"
              :title="showLoginPassword ? '隐藏密码' : '显示密码'"
            >
              <span v-if="showLoginPassword">👁️</span>
              <span v-else>👁️‍🗨️</span>
            </button>
          </div>
        </div>
        
        <div class="form-actions">
          <button type="submit" class="btn-primary" :disabled="loading">
            {{ loading ? '登录中...' : '登录' }}
          </button>
        </div>
        
        <div class="form-footer">
          <span>还没有账号？</span>
          <button type="button" class="link-btn" @click="switchToRegister">
            立即注册
          </button>
        </div>
      </form>
      
      <!-- 注册表单 -->
      <form v-else @submit.prevent="handleRegister" class="auth-form">
        <div class="form-group">
          <label for="reg-username">用户名</label>
          <input
            id="reg-username"
            v-model="registerForm.username"
            type="text"
            placeholder="请输入用户名"
            required
          />
        </div>
        
        <div class="form-group">
          <label for="reg-email">邮箱</label>
          <input
            id="reg-email"
            v-model="registerForm.email"
            type="email"
            placeholder="请输入邮箱"
            required
          />
        </div>
        
        <div class="form-group">
          <label for="reg-phone">手机号</label>
          <input
            id="reg-phone"
            v-model="registerForm.phone"
            type="tel"
            placeholder="请输入手机号"
            required
          />
        </div>
        
        <div class="form-group">
          <label for="reg-password">密码</label>
          <div class="password-input-wrapper">
            <input
              id="reg-password"
              v-model="registerForm.password"
              :type="showRegisterPassword ? 'text' : 'password'"
              placeholder="请输入密码"
              required
            />
            <button 
              type="button" 
              class="password-toggle-btn"
              @click="toggleRegisterPassword"
              :title="showRegisterPassword ? '隐藏密码' : '显示密码'"
            >
              <span v-if="showRegisterPassword">👁️</span>
              <span v-else>👁️‍🗨️</span>
            </button>
          </div>
        </div>
        
        <div class="form-group">
          <label for="reg-confirm-password">确认密码</label>
          <div class="password-input-wrapper">
            <input
              id="reg-confirm-password"
              v-model="registerForm.confirmPassword"
              :type="showConfirmPassword ? 'text' : 'password'"
              placeholder="请再次输入密码"
              required
            />
            <button 
              type="button" 
              class="password-toggle-btn"
              @click="toggleConfirmPassword"
              :title="showConfirmPassword ? '隐藏密码' : '显示密码'"
            >
              <span v-if="showConfirmPassword">👁️</span>
              <span v-else>👁️‍🗨️</span>
            </button>
          </div>
        </div>
        
        <div class="form-actions">
          <button type="submit" class="btn-primary" :disabled="loading">
            {{ loading ? '注册中...' : '注册' }}
          </button>
        </div>
        
        <div class="form-footer">
          <span>已有账号？</span>
          <button type="button" class="link-btn" @click="switchToLogin">
            立即登录
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import { ref, reactive, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { userStore } from '../../store/user'
import { clientLogin, clientRegister } from '../../api/user'

export default {
  name: 'LoginForm',
  props: {
    initialMode: {
      type: String,
      default: 'login', // 'login' or 'register'
      validator: (value) => ['login', 'register'].includes(value)
    },
    onSuccess: {
      type: Function,
      default: null
    },
    redirectTo: {
      type: String,
      default: '/'
    }
  },
  emits: ['login-success', 'register-success'],
  setup(props, { emit }) {
    const router = useRouter()
    const route = useRoute()
    const loading = ref(false)
    const isLogin = ref(props.initialMode === 'login')
    
    // 密码显示状态控制
    const showLoginPassword = ref(false)
    const showRegisterPassword = ref(false)
    const showConfirmPassword = ref(false)
    
    // 监听路由变化，同步组件状态
    watch(() => route.path, (newPath) => {
      if (newPath === '/login') {
        isLogin.value = true
      } else if (newPath === '/register') {
        isLogin.value = false
      }
    }, { immediate: true })
    
    const loginForm = reactive({
      username: '',
      password: ''
    })
    
    const registerForm = reactive({
      username: '',
      email: '',
      phone: '',
      password: '',
      confirmPassword: ''
    })
    
    const switchToRegister = () => {
      isLogin.value = false
      // 更新路由到注册页面
      router.push('/register')
    }
    
    const switchToLogin = () => {
      isLogin.value = true
      // 更新路由到登录页面
      router.push('/login')
    }
    
    // 密码显示切换方法
    const toggleLoginPassword = () => {
      showLoginPassword.value = !showLoginPassword.value
    }
    
    const toggleRegisterPassword = () => {
      showRegisterPassword.value = !showRegisterPassword.value
    }
    
    const toggleConfirmPassword = () => {
      showConfirmPassword.value = !showConfirmPassword.value
    }
    
    const handleLogin = async () => {
      if (loading.value) return
      
      loading.value = true
      try {
        const response = await clientLogin(loginForm.username, loginForm.password)
        const data = response.data
        
        localStorage.setItem('client_token', data.access_token)
        localStorage.setItem('client_user', JSON.stringify(data.user))
        userStore.setUserInfo(data.user)
        
        // 调用成功回调
        if (props.onSuccess) {
          props.onSuccess(data.user)
        }
        
        emit('login-success', data.user)
        
        // 显示成功消息
        if (typeof window !== 'undefined' && window.ElMessage) {
          window.ElMessage.success('登录成功！')
        } else {
          alert('登录成功！')
        }
        
        // 跳转到指定页面
        router.push(props.redirectTo)
      } catch (error) {
        console.error('登录失败:', error)
        const errorMessage = error.response?.data?.detail || '登录失败，请检查用户名和密码'
        // 使用更友好的错误提示
        if (typeof window !== 'undefined' && window.ElMessage) {
          window.ElMessage.error(errorMessage)
        } else {
          alert(errorMessage)
        }
      } finally {
        loading.value = false
      }
    }
    
    const handleRegister = async () => {
      if (loading.value) return
      
      // 验证密码
      if (registerForm.password !== registerForm.confirmPassword) {
        if (typeof window !== 'undefined' && window.ElMessage) {
          window.ElMessage.error('两次输入的密码不一致')
        } else {
          alert('两次输入的密码不一致')
        }
        return
      }
      
      if (registerForm.password.length < 6) {
        if (typeof window !== 'undefined' && window.ElMessage) {
          window.ElMessage.error('密码长度至少6位')
        } else {
          alert('密码长度至少6位')
        }
        return
      }
      
      loading.value = true
      try {
        const response = await clientRegister({
          username: registerForm.username,
          email: registerForm.email,
          phone: registerForm.phone || null,
          password: registerForm.password
        })
        
        emit('register-success', response.data)
        
        // 注册成功后自动登录
        try {
          const loginResponse = await clientLogin(registerForm.username, registerForm.password)
          const loginData = loginResponse.data
          
          localStorage.setItem('client_token', loginData.access_token)
          localStorage.setItem('client_user', JSON.stringify(loginData.user))
          userStore.setUserInfo(loginData.user)
          
          if (typeof window !== 'undefined' && window.ElMessage) {
            window.ElMessage.success('注册成功！已自动登录')
          } else {
            alert('注册成功！已自动登录')
          }
          
          // 跳转到个人中心页面
          router.push('/profile')
        } catch (loginError) {
          console.error('自动登录失败:', loginError)
          if (typeof window !== 'undefined' && window.ElMessage) {
            window.ElMessage.success('注册成功！请手动登录')
          } else {
            alert('注册成功！请手动登录')
          }
          switchToLogin()
        }
        
        // 清空注册表单
        Object.keys(registerForm).forEach(key => {
          registerForm[key] = ''
        })
      } catch (error) {
        console.error('注册失败:', error)
        const errorMessage = error.response?.data?.detail || '注册失败，请稍后重试'
        // 使用更友好的错误提示
        if (typeof window !== 'undefined' && window.ElMessage) {
          window.ElMessage.error(errorMessage)
        } else {
          alert(errorMessage)
        }
      } finally {
        loading.value = false
      }
    }
    
    return {
      loading,
      isLogin,
      loginForm,
      registerForm,
      showLoginPassword,
      showRegisterPassword,
      showConfirmPassword,
      switchToRegister,
      switchToLogin,
      toggleLoginPassword,
      toggleRegisterPassword,
      toggleConfirmPassword,
      handleLogin,
      handleRegister
    }
  }
}
</script>

<style scoped>
.auth-form-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f8f9fa;
  padding: 20px;
  width: 100%;
}

.auth-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  padding: 40px;
  width: 50vw;
  max-width: 600px;
  min-width: 400px;
  border: 1px solid #e9ecef;
}

.auth-header {
  text-align: center;
  margin-bottom: 30px;
}

.auth-header h2 {
  color: #333;
  margin-bottom: 10px;
  font-size: 28px;
  font-weight: 600;
}

.auth-header p {
  color: #666;
  font-size: 16px;
}

.auth-form {
  margin-bottom: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  color: #333;
  font-weight: 500;
}

.form-group input {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  box-sizing: border-box;
}

.form-group input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
}

.password-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.password-input-wrapper input {
  padding-right: 40px;
}

.password-toggle-btn {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  font-size: 16px;
  color: #666;
  border-radius: 4px;
  transition: color 0.2s;
}

.password-toggle-btn:hover {
  color: #333;
  background-color: #f0f0f0;
}

.password-toggle-btn:focus {
  outline: none;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
}

.form-actions {
  margin-top: 30px;
}

.btn-primary {
  width: 100%;
  padding: 12px;
  background-color: #3b82f6;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-primary:hover:not(:disabled) {
  background-color: #2563eb;
}

.btn-primary:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}

.form-footer {
  margin-top: 20px;
  text-align: center;
  color: #666;
}

.link-btn {
  background: none;
  border: none;
  color: #3b82f6;
  cursor: pointer;
  text-decoration: underline;
  font-size: 14px;
  margin-left: 5px;
}

.link-btn:hover {
  color: #2563eb;
}

/* 响应式设计 */
@media (min-width: 1200px) {
  .auth-card {
    width: 50vw;
    max-width: 700px;
    min-width: 500px;
    padding: 50px;
  }
}

@media (min-width: 768px) and (max-width: 1199px) {
  .auth-card {
    width: 50vw;
    max-width: 600px;
    min-width: 400px;
    padding: 45px;
  }
}

@media (max-width: 767px) {
  .auth-card {
    width: 80vw;
    max-width: 500px;
    min-width: 300px;
    padding: 35px 25px;
    margin: 10px;
  }
  
  .auth-header h2 {
    font-size: 24px;
  }
}

@media (max-width: 480px) {
  .auth-card {
    width: 90vw;
    max-width: 400px;
    min-width: 280px;
    padding: 30px 20px;
    margin: 10px;
  }
  
  .auth-header h2 {
    font-size: 22px;
  }
}
</style> 