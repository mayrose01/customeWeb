<template>
  <div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
      <h2 style="margin: 0;">订单管理</h2>
    </div>
    
    <!-- 搜索区域 -->
    <el-card style="margin-bottom: 20px;">
      <el-form :model="searchForm" inline>
        <el-form-item label="订单号">
          <el-input v-model="searchForm.order_no" placeholder="请输入订单号" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="用户ID">
          <el-input v-model="searchForm.user_id" placeholder="请输入用户ID" clearable style="width: 150px;" />
        </el-form-item>
        <el-form-item label="订单状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable style="width: 150px;">
            <el-option label="待付款" value="pending" />
            <el-option label="已付款" value="paid" />
            <el-option label="已发货" value="shipped" />
            <el-option label="已送达" value="delivered" />
            <el-option label="已完成" value="completed" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item label="支付状态">
          <el-select v-model="searchForm.payment_status" placeholder="请选择支付状态" clearable style="width: 150px;">
            <el-option label="未支付" value="unpaid" />
            <el-option label="已支付" value="paid" />
            <el-option label="支付失败" value="failed" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="searchOrders">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    
    <!-- 订单列表 -->
    <div class="table-container">
      <el-table :data="orders" style="width: 100%;" border stripe>
        <el-table-column prop="id" label="订单ID" width="80" align="center" />
        <el-table-column prop="order_no" label="订单号" width="180" />
        <el-table-column label="用户信息" width="150">
          <template #default="scope">
            <div v-if="scope.row.user_id">
              <div><strong>ID:</strong> {{ scope.row.user_id }}</div>
              <div v-if="scope.row.user && scope.row.user.username">
                <strong>用户名:</strong> {{ scope.row.user.username }}
              </div>
              <div v-else>
                <strong>用户名:</strong> -
              </div>
            </div>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="订单状态" width="100" align="center">
          <template #default="scope">
            <el-tag :type="getStatusTagType(scope.row.status || '')">
              {{ getStatusText(scope.row.status || '') }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="支付状态" width="100" align="center">
          <template #default="scope">
            <el-tag :type="getPaymentStatusTagType(scope.row.payment_status || '')">
              {{ getPaymentStatusText(scope.row.payment_status || '') }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="total_amount" label="订单金额" width="120" align="center">
          <template #default="scope">
            <span class="text-primary">¥{{ scope.row.total_amount || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column label="商品数量" width="100" align="center">
          <template #default="scope">
            <el-tag type="info">{{ scope.row.items?.length || 0 }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="160" align="center">
          <template #default="scope">
            <span>{{ formatDateTime(scope.row.created_at) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center">
          <template #default="scope">
            <el-button size="small" type="primary" @click="viewOrderDetail(scope.row)">查看详情</el-button>
            <el-button 
              v-if="scope.row.status === 'pending'" 
              size="small" 
              type="success" 
              @click="updateOrderStatus(scope.row.id, 'paid')"
            >
              标记已付款
            </el-button>
            <el-button 
              v-if="scope.row.status === 'paid'" 
              size="small" 
              type="warning" 
              @click="updateOrderStatus(scope.row.id, 'shipped')"
            >
              标记已发货
            </el-button>
            <el-button 
              v-if="scope.row.status === 'shipped'" 
              size="small" 
              type="success" 
              @click="updateOrderStatus(scope.row.id, 'delivered')"
            >
              标记已送达
            </el-button>
            <el-button 
              v-if="scope.row.status === 'delivered'" 
              size="small" 
              type="success" 
              @click="updateOrderStatus(scope.row.id, 'completed')"
            >
              标记已完成
            </el-button>
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
    
    <!-- 订单详情对话框 -->
    <el-dialog v-model="showDetail" title="订单详情" width="900px">
      <div v-if="selectedOrder">
        <el-descriptions :column="2" border style="margin-bottom: 20px;">
          <el-descriptions-item label="订单ID">{{ selectedOrder.id }}</el-descriptions-item>
          <el-descriptions-item label="订单号">{{ selectedOrder.order_no }}</el-descriptions-item>
          <el-descriptions-item label="用户ID">{{ selectedOrder.user_id }}</el-descriptions-item>
          <el-descriptions-item label="订单状态">
            <el-tag :type="getStatusTagType(selectedOrder.status || '')">
              {{ getStatusText(selectedOrder.status || '') }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="支付状态">
            <el-tag :type="getPaymentStatusTagType(selectedOrder.payment_status || '')">
              {{ getPaymentStatusText(selectedOrder.payment_status || '') }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="支付方式">{{ selectedOrder.payment_method || '-' }}</el-descriptions-item>
          <el-descriptions-item label="订单金额">¥{{ selectedOrder.total_amount || 0 }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ formatDateTime(selectedOrder.created_at) }}</el-descriptions-item>
          <el-descriptions-item label="支付时间">{{ selectedOrder.payment_time ? formatDateTime(selectedOrder.payment_time) : '-' }}</el-descriptions-item>
          <el-descriptions-item label="发货时间">{{ selectedOrder.shipping_time ? formatDateTime(selectedOrder.shipping_time) : '-' }}</el-descriptions-item>
          <el-descriptions-item label="送达时间">{{ selectedOrder.delivery_time ? formatDateTime(selectedOrder.delivery_time) : '-' }}</el-descriptions-item>
        </el-descriptions>
        
        <el-descriptions :column="1" border style="margin-bottom: 20px;">
          <el-descriptions-item label="收货地址">{{ selectedOrder.shipping_address || '-' }}</el-descriptions-item>
          <el-descriptions-item label="收货人">{{ selectedOrder.shipping_contact || '-' }}</el-descriptions-item>
          <el-descriptions-item label="收货人电话">{{ selectedOrder.shipping_phone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="物流公司">{{ selectedOrder.shipping_company || '-' }}</el-descriptions-item>
          <el-descriptions-item label="物流单号">{{ selectedOrder.tracking_number || '-' }}</el-descriptions-item>
          <el-descriptions-item label="订单备注">{{ selectedOrder.remark || '-' }}</el-descriptions-item>
        </el-descriptions>
        
        <h4>商品列表</h4>
        <el-table :data="selectedOrder.items || []" border>
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
              <div>
                <div><strong>标题:</strong> {{ scope.row.product_title || '-' }}</div>
                <div><strong>SKU:</strong> {{ scope.row.sku_code || '-' }}</div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" width="80" align="center" />
          <el-table-column prop="price" label="单价" width="100" align="center">
            <template #default="scope">
              ¥{{ scope.row.price || 0 }}
            </template>
          </el-table-column>
          <el-table-column label="小计" width="100" align="center">
            <template #default="scope">
              <span class="text-primary">¥{{ (parseFloat(scope.row.price || 0) * (scope.row.quantity || 0)).toFixed(2) }}</span>
            </template>
          </el-table-column>
        </el-table>
        
        <div style="margin-top: 20px; text-align: right;">
          <h3>总计: ¥{{ selectedOrder.total_amount || 0 }}</h3>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onActivated } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getOrders, updateOrderStatus as updateOrderStatusApi } from '../api/order'

// 响应式数据
const orders = ref([])
const searchForm = reactive({
  order_no: '',
  user_id: '',
  status: '',
  payment_status: ''
})
const pagination = reactive({
  currentPage: 1,
  pageSize: 10,
  total: 0
})
const showDetail = ref(false)
const selectedOrder = ref(null)

// 获取订单列表
const fetchOrders = async () => {
  try {
    const params = {
      page: pagination.currentPage,
      page_size: pagination.pageSize,
      ...searchForm
    }
    console.log('获取订单列表参数:', params);
    
    const response = await getOrders(params)
    console.log('订单列表响应:', response);
    
    // 检查响应数据结构
    if (response && response.data) {
      orders.value = response.data.items || []
      pagination.total = response.data.total || 0
      console.log('订单列表更新完成，总数:', pagination.total, '订单数据:', orders.value);
    } else {
      console.warn('订单列表响应数据格式异常:', response);
      orders.value = []
      pagination.total = 0
    }
  } catch (error) {
    console.error('获取订单列表失败:', error)
    ElMessage.error('获取订单列表失败')
    // 设置空列表，避免页面崩溃
    orders.value = []
    pagination.total = 0
  }
}

// 搜索订单
const searchOrders = () => {
  pagination.currentPage = 1
  fetchOrders()
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  pagination.currentPage = 1
  fetchOrders()
}

// 查看订单详情
const viewOrderDetail = (order) => {
  try {
    console.log('查看订单详情:', order);
    if (!order) {
      ElMessage.error('订单数据无效');
      return;
    }
    selectedOrder.value = order
    showDetail.value = true
  } catch (error) {
    console.error('查看订单详情失败:', error);
    ElMessage.error('查看订单详情失败');
  }
}

// 更新订单状态
const updateOrderStatus = async (orderId, newStatus) => {
  try {
    const statusText = getStatusText(newStatus)
    await ElMessageBox.confirm(`确定要将订单状态更新为"${statusText}"吗？`, '确认操作', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    console.log('更新订单状态:', orderId, newStatus);
    await updateOrderStatusApi(orderId, { status: newStatus })
    ElMessage.success(`订单状态已更新为"${statusText}"`)
    fetchOrders()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('更新订单状态失败:', error)
      ElMessage.error('更新订单状态失败')
    }
  }
}

// 获取状态标签类型
const getStatusTagType = (status) => {
  if (!status) return 'info';
  const typeMap = {
    'pending': 'warning',
    'paid': 'primary',
    'shipped': 'info',
    'delivered': 'success',
    'completed': 'success',
    'cancelled': 'danger'
  }
  return typeMap[status] || 'info'
}

// 获取状态文本
const getStatusText = (status) => {
  if (!status) return '未知';
  const textMap = {
    'pending': '待付款',
    'paid': '已付款',
    'shipped': '已发货',
    'delivered': '已送达',
    'completed': '已完成',
    'cancelled': '已取消'
  }
  return textMap[status] || status
}

// 获取支付状态标签类型
const getPaymentStatusTagType = (paymentStatus) => {
  if (!paymentStatus) return 'info';
  const typeMap = {
    'unpaid': 'warning',
    'paid': 'success',
    'failed': 'danger'
  }
  return typeMap[paymentStatus] || 'info'
}

// 获取支付状态文本
const getPaymentStatusText = (paymentStatus) => {
  if (!paymentStatus) return '未知';
  const textMap = {
    'unpaid': '未支付',
    'paid': '已支付',
    'failed': '支付失败'
  }
  return textMap[paymentStatus] || paymentStatus
}

// 分页处理
const handlePageChange = (page) => {
  pagination.currentPage = page
  fetchOrders()
}

const handleSizeChange = (size) => {
  pagination.pageSize = size
  pagination.currentPage = 1
  fetchOrders()
}

// 格式化日期时间
const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  try {
    return new Date(dateTime).toLocaleString('zh-CN')
  } catch (error) {
    console.error('日期格式化失败:', dateTime, error);
    return '-'
  }
}

// 获取图片URL
const getImageUrl = (imagePath) => {
  if (!imagePath) return ''
  try {
    if (imagePath.startsWith('http')) return imagePath
    return `${import.meta.env.VITE_API_BASE_URL}/uploads/${imagePath}`
  } catch (error) {
    console.error('图片URL处理失败:', imagePath, error);
    return ''
  }
}

// 组件挂载时获取数据
onMounted(() => {
  console.log('订单管理页面挂载开始');
  try {
    fetchOrders();
    console.log('订单管理页面挂载完成');
  } catch (error) {
    console.error('订单管理页面初始化失败:', error);
    ElMessage.error('页面初始化失败');
  }
});

// 页面激活时刷新数据
onActivated(() => {
  console.log('订单管理页面激活，刷新数据');
  fetchOrders();
});
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