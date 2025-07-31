<template>
  <div class="environment-test">
    <el-card class="test-card">
      <template #header>
        <div class="card-header">
          <h2>环境配置测试</h2>
        </div>
      </template>
      
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card class="info-card">
            <template #header>
              <h3>当前环境信息</h3>
            </template>
            
            <el-descriptions :column="1" border>
              <el-descriptions-item label="当前环境">
                <el-tag :type="getEnvTagType(currentEnv)">{{ currentEnv }}</el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="API基础URL">
                {{ apiBaseUrl }}
              </el-descriptions-item>
              <el-descriptions-item label="当前域名">
                {{ currentHostname }}
              </el-descriptions-item>
              <el-descriptions-item label="当前端口">
                {{ currentPort }}
              </el-descriptions-item>
              <el-descriptions-item label="完整URL">
                {{ currentFullUrl }}
              </el-descriptions-item>
            </el-descriptions>
          </el-card>
        </el-col>
        
        <el-col :span="12">
          <el-card class="test-card">
            <template #header>
              <h3>API连接测试</h3>
            </template>
            
            <el-button 
              type="primary" 
              @click="testApiConnection"
              :loading="testing"
              style="margin-bottom: 20px;"
            >
              测试API连接
            </el-button>
            
            <div v-if="apiTestResult">
              <el-alert
                :title="apiTestResult.success ? 'API连接成功' : 'API连接失败'"
                :type="apiTestResult.success ? 'success' : 'error'"
                :description="apiTestResult.message"
                show-icon
                style="margin-bottom: 10px;"
              />
              
              <el-card v-if="apiTestResult.data" class="response-card">
                <template #header>
                  <h4>API响应数据</h4>
                </template>
                <pre>{{ JSON.stringify(apiTestResult.data, null, 2) }}</pre>
              </el-card>
            </div>
          </el-card>
        </el-col>
      </el-row>
      
      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="24">
          <el-card class="config-card">
            <template #header>
              <h3>环境配置详情</h3>
            </template>
            
            <el-tabs v-model="activeTab">
              <el-tab-pane label="开发环境" name="development">
                <el-descriptions :column="2" border>
                  <el-descriptions-item label="访问地址">http://localhost:3000</el-descriptions-item>
                  <el-descriptions-item label="API地址">http://localhost:8000/api</el-descriptions-item>
                  <el-descriptions-item label="端口">3000</el-descriptions-item>
                  <el-descriptions-item label="数据库">本地MySQL</el-descriptions-item>
                </el-descriptions>
              </el-tab-pane>
              
              <el-tab-pane label="测试环境" name="test">
                <el-descriptions :column="2" border>
                  <el-descriptions-item label="访问地址">http://test.catusfoto.top:3001</el-descriptions-item>
                  <el-descriptions-item label="API地址">http://test.catusfoto.top:8000/api</el-descriptions-item>
                  <el-descriptions-item label="端口">3001</el-descriptions-item>
                  <el-descriptions-item label="数据库">测试MySQL</el-descriptions-item>
                </el-descriptions>
              </el-tab-pane>
              
              <el-tab-pane label="生产环境" name="production">
                <el-descriptions :column="2" border>
                  <el-descriptions-item label="访问地址">https://catusfoto.top</el-descriptions-item>
                  <el-descriptions-item label="API地址">https://catusfoto.top/api</el-descriptions-item>
                  <el-descriptions-item label="端口">443</el-descriptions-item>
                  <el-descriptions-item label="数据库">生产MySQL</el-descriptions-item>
                </el-descriptions>
              </el-tab-pane>
            </el-tabs>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { config, API_BASE_URL, APP_ENV } from '../../env.config.js'
import axios from 'axios'

export default {
  name: 'EnvironmentTest',
  setup() {
    const testing = ref(false)
    const apiTestResult = ref(null)
    const activeTab = ref('development')
    
    // 环境信息
    const currentEnv = computed(() => APP_ENV)
    const apiBaseUrl = computed(() => API_BASE_URL)
    const currentHostname = computed(() => window.location.hostname)
    const currentPort = computed(() => window.location.port || (window.location.protocol === 'https:' ? '443' : '80'))
    const currentFullUrl = computed(() => window.location.href)
    
    // 获取环境标签类型
    const getEnvTagType = (env) => {
      switch (env) {
        case 'development': return 'info'
        case 'test': return 'warning'
        case 'production': return 'success'
        default: return 'info'
      }
    }
    
    // 测试API连接
    const testApiConnection = async () => {
      testing.value = true
      apiTestResult.value = null
      
      try {
        const response = await axios.get(`${apiBaseUrl.value}/company/`)
        apiTestResult.value = {
          success: true,
          message: 'API连接成功，数据正常',
          data: response.data
        }
      } catch (error) {
        apiTestResult.value = {
          success: false,
          message: `API连接失败: ${error.message}`,
          data: null
        }
      } finally {
        testing.value = false
      }
    }
    
    // 页面加载时自动测试
    onMounted(() => {
      testApiConnection()
    })
    
    return {
      testing,
      apiTestResult,
      activeTab,
      currentEnv,
      apiBaseUrl,
      currentHostname,
      currentPort,
      currentFullUrl,
      getEnvTagType,
      testApiConnection
    }
  }
}
</script>

<style scoped>
.environment-test {
  padding: 20px;
}

.test-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.info-card, .test-card, .config-card {
  height: 100%;
}

.response-card {
  margin-top: 10px;
}

.response-card pre {
  background-color: #f5f5f5;
  padding: 10px;
  border-radius: 4px;
  overflow-x: auto;
  font-size: 12px;
}

h2, h3, h4 {
  margin: 0;
  color: #303133;
}

h2 {
  font-size: 24px;
}

h3 {
  font-size: 18px;
}

h4 {
  font-size: 14px;
}
</style> 