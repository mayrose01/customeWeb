<template>
  <div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
      <h2 style="margin: 0;">购物车管理</h2>
    </div>
    
    <!-- 搜索区域 -->
    <el-card style="margin-bottom: 20px;">
      <el-form :model="searchForm" inline>
        <el-form-item label="用户ID">
          <el-input v-model="searchForm.user_id" placeholder="请输入用户ID" clearable style="width: 150px;" />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="searchForm.username" placeholder="请输入用户名" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="searchCarts">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    
    <!-- 购物车列表 -->
    <div class="table-container">
      <el-table :data="carts" style="width: 100%;" border stripe>
        <el-table-column prop="id" label="购物车ID" width="100" align="center" />
        <el-table-column label="用户信息" width="200">
          <template #default="scope">
            <div v-if="scope.row.user">
              <div><strong>ID:</strong> {{ scope.row.user.id }}</div>
              <div><strong>用户名:</strong> {{ scope.row.user.username || '-' }}</div>
              <div><strong>邮箱:</strong> {{ scope.row.user.email || '-' }}</div>
            </div>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="商品数量" width="100" align="center">
          <template #default="scope">
            <el-tag type="info">{{ scope.row.items?.length || 0 }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="总价值" width="120" align="center">
          <template #default="scope">
            <span class="text-primary">¥{{ calculateTotalValue(scope.row) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="160" align="center">
          <template #default="scope">
            <span>{{ formatDateTime(scope.row.created_at) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="updated_at" label="更新时间" width="160" align="center">
          <template #default="scope">
            <span>{{ formatDateTime(scope.row.updated_at) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center">
          <template #default="scope">
            <el-button size="small" type="primary" @click="viewCartDetail(scope.row)">查看详情</el-button>
            <el-button size="small" type="danger" @click="clearCart(scope.row.id)">清空购物车</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
    
    <!-- 分页组件 -->
    <div class="pagination-container">
      <el-pagination
        v-model:current-page="pagination.currentPage"
        :page-size="pagination.pageSize"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="handlePageChange"
        @size-change="handleSizeChange"
      />
    </div>
    
    <!-- 购物车详情对话框 -->
    <el-dialog v-model="showDetail" title="购物车详情" width="800px">
      <div v-if="selectedCart">
        <el-descriptions :column="2" border style="margin-bottom: 20px;">
          <el-descriptions-item label="购物车ID">{{ selectedCart.id }}</el-descriptions-item>
          <el-descriptions-item label="用户ID">{{ selectedCart.user_id }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ formatDateTime(selectedCart.created_at) }}</el-descriptions-item>
          <el-descriptions-item label="更新时间">{{ formatDateTime(selectedCart.updated_at) }}</el-descriptions-item>
        </el-descriptions>
        
        <h4>商品列表</h4>
        <el-table :data="selectedCart.items || []" border>
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column label="商品图片" width="100">
            <template #default="scope">
              <el-image 
                v-if="scope.row.sku && scope.row.sku.product && scope.row.sku.product.images && scope.row.sku.product.images.length > 0"
                :src="getImageUrl(scope.row.sku.product.images[0])" 
                style="width: 60px; height: 60px; object-fit: cover;"
                :preview-src-list="scope.row.sku.product.images.map(img => getImageUrl(img))"
              />
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="商品信息" min-width="200">
            <template #default="scope">
              <div v-if="scope.row.sku && scope.row.sku.product">
                <div><strong>标题:</strong> {{ scope.row.sku.product.title }}</div>
                <div><strong>型号:</strong> {{ scope.row.sku.product.model }}</div>
                <div><strong>SKU:</strong> {{ scope.row.sku.sku_code }}</div>
              </div>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" width="80" align="center" />
          <el-table-column label="单价" width="100" align="center">
            <template #default="scope">
              <span v-if="scope.row.sku">¥{{ scope.row.sku.price }}</span>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="小计" width="100" align="center">
            <template #default="scope">
              <span class="text-primary" v-if="scope.row.sku">
                ¥{{ (scope.row.sku.price * scope.row.quantity).toFixed(2) }}
              </span>
              <span v-else>-</span>
            </template>
          </el-table-column>
        </el-table>
        
        <div style="margin-top: 20px; text-align: right;">
          <h3>总计: ¥{{ calculateTotalValue(selectedCart) }}</h3>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCarts, clearCart as clearCartApi } from '../api/cart'

// 响应式数据
const carts = ref([])
const searchForm = reactive({
  user_id: '',
  username: ''
})
const pagination = reactive({
  currentPage: 1,
  pageSize: 10,
  total: 0
})
const showDetail = ref(false)
const selectedCart = ref(null)

// 获取购物车列表
const fetchCarts = async () => {
  try {
    const params = {
      page: pagination.currentPage,
      page_size: pagination.pageSize,
      ...searchForm
    }
    const response = await getCarts(params)
    carts.value = response.data.items || []
    pagination.total = response.data.total || 0
  } catch (error) {
    console.error('获取购物车列表失败:', error)
    ElMessage.error('获取购物车列表失败')
  }
}

// 搜索购物车
const searchCarts = () => {
  pagination.currentPage = 1
  fetchCarts()
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  pagination.currentPage = 1
  fetchCarts()
}

// 查看购物车详情
const viewCartDetail = (cart) => {
  selectedCart.value = cart
  showDetail.value = true
}

// 清空购物车
const clearCart = async (cartId) => {
  try {
    await ElMessageBox.confirm('确定要清空这个购物车吗？此操作不可恢复。', '确认操作', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await clearCartApi(cartId)
    ElMessage.success('购物车已清空')
    fetchCarts()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('清空购物车失败:', error)
      ElMessage.error('清空购物车失败')
    }
  }
}

// 计算购物车总价值
const calculateTotalValue = (cart) => {
  if (!cart.items || cart.items.length === 0) return '0.00'
  
  const total = cart.items.reduce((sum, item) => {
    if (item.sku && item.sku.price) {
      return sum + (item.sku.price * item.quantity)
    }
    return sum
  }, 0)
  
  return total.toFixed(2)
}

// 分页处理
const handlePageChange = (page) => {
  pagination.currentPage = page
  fetchCarts()
}

const handleSizeChange = (size) => {
  pagination.pageSize = size
  pagination.currentPage = 1
  fetchCarts()
}

// 格式化日期时间
const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  return new Date(dateTime).toLocaleString('zh-CN')
}

// 获取图片URL
const getImageUrl = (imagePath) => {
  if (!imagePath) return ''
  if (imagePath.startsWith('http')) return imagePath
  return `${import.meta.env.VITE_API_BASE_URL}/uploads/${imagePath}`
}

// 组件挂载时获取数据
onMounted(() => {
  fetchCarts()
})
</script>

<style scoped>
.table-container {
  margin-bottom: 20px;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.text-primary {
  color: #409eff;
  font-weight: bold;
}
</style> 