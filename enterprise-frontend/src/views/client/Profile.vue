<template>
  <div class="profile-page">
    <ClientHeader />
    
    <div class="profile-container">
      <div class="profile-card">
        <div class="profile-header">
          <h2>个人中心</h2>
          <p>管理您的个人信息和账户设置</p>
        </div>
        
        <el-tabs v-model="activeTab" class="profile-tabs">
          <el-tab-pane label="基本信息" name="basic">
            <el-form 
              :model="userForm" 
              :rules="userRules" 
              ref="userFormRef" 
              label-width="100px"
            >
              <el-form-item label="头像" prop="avatar">
                <div class="avatar-upload">
                  <el-avatar 
                    :size="80" 
                    :src="userForm.avatar_url || userInfo.avatar_url" 
                    class="avatar-preview"
                  />
                  <div class="avatar-actions">
                    <el-upload
                      ref="uploadRef"
                      :show-file-list="false"
                      :before-upload="beforeAvatarUpload"
                      :on-success="handleAvatarSuccess"
                      :on-error="handleAvatarError"
                      action="http://localhost:8000/api/upload/"
                      accept="image/*"
                    >
                      <el-button type="primary" size="small">更换头像</el-button>
                    </el-upload>
                    <el-button 
                      v-if="userForm.avatar_url || userInfo.avatar_url" 
                      type="danger" 
                      size="small" 
                      @click="removeAvatar"
                      style="display: none;"
                    >
                      删除头像
                    </el-button>
                  </div>
                </div>
              </el-form-item>
              
              <el-form-item label="用户名" prop="username">
                <el-input v-model="userForm.username" />
              </el-form-item>
              
              <el-form-item label="邮箱" prop="email">
                <el-input v-model="userForm.email" />
              </el-form-item>
              
              <el-form-item label="手机号" prop="phone">
                <el-input v-model="userForm.phone" />
              </el-form-item>
              
              <el-form-item>
                <el-button type="primary" @click="updateUserInfo" :loading="updating">
                  保存修改
                </el-button>
              </el-form-item>
            </el-form>
          </el-tab-pane>
          
          <el-tab-pane label="询价列表" name="inquiries">
            <div class="inquiries-section">
              <div class="section-header">
                <h3>我的询价记录</h3>
                <p>查看您提交的所有产品询价</p>
              </div>
              
              <div v-if="inquiries.length === 0" class="empty-state">
                <div class="empty-icon">📋</div>
                <p>暂无询价记录</p>
                <router-link to="/all-products" class="browse-link">浏览产品</router-link>
              </div>
              
              <div v-else class="inquiries-list">
                <div 
                  v-for="inquiry in inquiries" 
                  :key="inquiry.id" 
                  class="inquiry-item"
                >
                  <div class="inquiry-header">
                    <div class="product-info">
                      <img 
                        v-if="inquiry.product_image" 
                        :src="getImageUrl(inquiry.product_image)" 
                        :alt="inquiry.product_name"
                        class="product-image"
                      />
                      <div class="product-details">
                        <h4>{{ inquiry.product_name }}</h4>
                        <p v-if="inquiry.product_model">型号: {{ inquiry.product_model }}</p>
                      </div>
                    </div>
                    <div class="inquiry-date">
                      {{ formatDate(inquiry.created_at) }}
                    </div>
                  </div>
                  <div class="inquiry-content">
                    <p><strong>询价内容:</strong></p>
                    <p>{{ inquiry.content }}</p>
                  </div>
                  <div class="inquiry-footer">
                    <span class="status">已提交</span>
                  </div>
                </div>
              </div>
            </div>
          </el-tab-pane>
          
          <el-tab-pane label="咨询列表" name="consultations">
            <div class="consultations-section">
              <div class="section-header">
                <h3>我的咨询记录</h3>
                <p>查看您提交的所有咨询信息</p>
              </div>
              
              <div v-if="consultations.length === 0" class="empty-state">
                <div class="empty-icon">💬</div>
                <p>暂无咨询记录</p>
                <router-link to="/contact" class="browse-link">联系我们</router-link>
              </div>
              
              <div v-else class="consultations-list">
                <div 
                  v-for="consultation in consultations" 
                  :key="consultation.id" 
                  class="consultation-item"
                >
                  <div class="consultation-header">
                    <div class="consultation-info">
                      <h4>{{ consultation.subject || '在线咨询' }}</h4>
                      <p>姓名: {{ consultation.name }}</p>
                    </div>
                    <div class="consultation-date">
                      {{ formatDate(consultation.created_at) }}
                    </div>
                  </div>
                  <div class="consultation-content">
                    <p><strong>咨询内容:</strong></p>
                    <p>{{ consultation.message }}</p>
                  </div>
                  <div class="consultation-footer">
                    <span class="status">已提交</span>
                  </div>
                </div>
              </div>
            </div>
          </el-tab-pane>
          
          <el-tab-pane label="修改密码" name="password">
            <el-form 
              :model="passwordForm" 
              :rules="passwordRules" 
              ref="passwordFormRef" 
              label-width="100px"
            >
              <el-form-item label="当前密码" prop="oldPassword">
                <el-input 
                  v-model="passwordForm.oldPassword" 
                  type="password" 
                  show-password
                />
              </el-form-item>
              
              <el-form-item label="新密码" prop="newPassword">
                <el-input 
                  v-model="passwordForm.newPassword" 
                  type="password" 
                  show-password
                />
              </el-form-item>
              
              <el-form-item label="确认密码" prop="confirmPassword">
                <el-input 
                  v-model="passwordForm.confirmPassword" 
                  type="password" 
                  show-password
                />
              </el-form-item>
              
              <el-form-item>
                <el-button type="primary" @click="changePassword" :loading="changing">
                  修改密码
                </el-button>
              </el-form-item>
            </el-form>
          </el-tab-pane>
        </el-tabs>
        
        <div class="profile-footer">
          <router-link to="/" class="back-link">返回首页</router-link>
        </div>
      </div>
    </div>
    
    <ClientFooter />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { changePassword as changePasswordAPI } from '@/api/user'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { useRouter } from 'vue-router'
import { userStore } from '@/store/user'
import { getImageUrl } from '@/utils/imageUtils'
import axios from '@/api/axios'

const router = useRouter()
const activeTab = ref('basic')
const userFormRef = ref()
const passwordFormRef = ref()
const uploadRef = ref()
const updating = ref(false)
const changing = ref(false)

const userInfo = ref({})
const userForm = reactive({
  username: '',
  email: '',
  phone: '',
  avatar_url: ''
})

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const inquiries = ref([])
const consultations = ref([])

const userRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
  ]
}

const validateConfirmPassword = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请再次输入密码'))
  } else if (value !== passwordForm.newPassword) {
    callback(new Error('两次输入密码不一致'))
  } else {
    callback()
  }
}

const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入当前密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const loadUserInfo = async () => {
  try {
    const token = localStorage.getItem('client_token')
    if (!token) {
      router.push('/login')
      return
    }

    const response = await axios.get('/client-user/profile', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })

    const userData = response.data
    userInfo.value = userData
    userForm.username = userData.username || ''
    userForm.email = userData.email || ''
    userForm.phone = userData.phone || ''
    userForm.avatar_url = userData.avatar_url || ''
  } catch (error) {
    console.error('加载用户信息失败:', error)
    ElMessage.error('加载用户信息失败')
  }
}

const loadInquiries = async () => {
  try {
    const token = localStorage.getItem('client_token')
    if (!token) return

    const response = await axios.get('/client-user/inquiries', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })

    const data = response.data
    inquiries.value = data.items || []
  } catch (error) {
    console.error('加载询价列表失败:', error)
  }
}

const loadConsultations = async () => {
  try {
    const token = localStorage.getItem('client_token')
    if (!token) return

    const response = await axios.get('/client-user/consultations', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })

    const data = response.data
    consultations.value = data.items || []
  } catch (error) {
    console.error('加载咨询列表失败:', error)
  }
}

const beforeAvatarUpload = (file) => {
  const isJPG = file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/gif'
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isJPG) {
    ElMessage.error('头像只能是 JPG/PNG/GIF 格式!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('头像大小不能超过 2MB!')
    return false
  }
  return true
}

const handleAvatarSuccess = (response) => {
  // 构建完整的头像URL
  const fullAvatarUrl = `http://localhost:8000${response.url}`
  userForm.avatar_url = fullAvatarUrl
  
  ElMessage.success('头像上传成功')
}

const handleAvatarError = () => {
  ElMessage.error('头像上传失败')
}

const removeAvatar = () => {
  userForm.avatar_url = ''
  ElMessage.success('头像已删除')
}

const updateUserInfo = async () => {
  if (!userFormRef.value) return
  
  try {
    await userFormRef.value.validate()
    updating.value = true
    
    const token = localStorage.getItem('client_token')
    const response = await axios.put('/client-user/profile', {
      username: userForm.username,
      email: userForm.email,
      phone: userForm.phone,
      avatar_url: userForm.avatar_url
    }, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })

    const updatedUser = response.data
    userInfo.value = updatedUser
    ElMessage.success('信息更新成功')
  } catch (error) {
    ElMessage.error('更新失败')
  } finally {
    updating.value = false
  }
}

const changePassword = async () => {
  if (!passwordFormRef.value) return
  
  try {
    await passwordFormRef.value.validate()
    changing.value = true
    
    const userInfo = JSON.parse(localStorage.getItem('client_user') || '{}')
    await changePasswordAPI(userInfo.username, passwordForm.oldPassword, passwordForm.newPassword)
    
    ElMessage.success('密码修改成功，请重新登录')
    
    // 清除登录信息
    userStore.logout()
    
    // 延迟跳转，确保成功消息显示完成
    setTimeout(() => {
      router.push('/')
    }, 1000)
    
    return // 直接返回，避免执行后续的错误处理
  } catch (error) {
    ElMessage.error(error.response?.data?.detail || '密码修改失败')
  } finally {
    changing.value = false
  }
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  loadUserInfo()
  loadInquiries()
  loadConsultations()
})
</script>

<style scoped>
.profile-page {
  min-height: 100vh;
  background: #f8f9fa;
  padding-top: 80px;
}

.profile-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 40px 20px;
  min-height: calc(100vh - 80px - 200px);
}

.profile-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  padding: 40px;
  border: 1px solid #e9ecef;
}

.profile-header {
  text-align: center;
  margin-bottom: 30px;
}

.profile-header h2 {
  color: #333;
  margin-bottom: 10px;
  font-size: 28px;
  font-weight: 600;
}

.profile-header p {
  color: #666;
  font-size: 16px;
}

.profile-tabs {
  margin-bottom: 30px;
}

.avatar-upload {
  display: flex;
  align-items: center;
  gap: 20px;
}

.avatar-preview {
  border: 2px solid #e9ecef;
}

.avatar-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

/* 询价和咨询列表样式 */
.section-header {
  margin-bottom: 20px;
}

.section-header h3 {
  color: #333;
  margin-bottom: 5px;
  font-size: 18px;
}

.section-header p {
  color: #666;
  font-size: 14px;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: #666;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 10px;
}

.browse-link {
  color: #3b82f6;
  text-decoration: none;
  font-weight: 500;
}

.browse-link:hover {
  text-decoration: underline;
}

.inquiries-list,
.consultations-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.inquiry-item,
.consultation-item {
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 15px;
  background: #f8f9fa;
}

.inquiry-header,
.consultation-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 10px;
}

.product-info {
  display: flex;
  gap: 10px;
  align-items: center;
}

.product-image {
  width: 50px;
  height: 50px;
  object-fit: cover;
  border-radius: 4px;
}

.product-details h4 {
  margin: 0 0 5px 0;
  font-size: 16px;
  color: #333;
}

.product-details p {
  margin: 0;
  font-size: 14px;
  color: #666;
}

.consultation-info h4 {
  margin: 0 0 5px 0;
  font-size: 16px;
  color: #333;
}

.consultation-info p {
  margin: 0;
  font-size: 14px;
  color: #666;
}

.inquiry-date,
.consultation-date {
  font-size: 12px;
  color: #999;
}

.inquiry-content,
.consultation-content {
  margin-bottom: 10px;
}

.inquiry-content p,
.consultation-content p {
  margin: 5px 0;
  line-height: 1.5;
}

.inquiry-footer,
.consultation-footer {
  display: flex;
  justify-content: flex-end;
}

.status {
  background: #10b981;
  color: white;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
}

.profile-footer {
  text-align: center;
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #eee;
}

.back-link {
  color: #666;
  text-decoration: none;
  font-size: 14px;
}

.back-link:hover {
  color: #333;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .profile-container {
    padding: 20px 10px;
  }
  
  .profile-card {
    padding: 30px 20px;
  }
  
  .profile-header h2 {
    font-size: 24px;
  }
  
  .avatar-upload {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .inquiry-header,
  .consultation-header {
    flex-direction: column;
    gap: 10px;
  }
  
  .product-info {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style> 