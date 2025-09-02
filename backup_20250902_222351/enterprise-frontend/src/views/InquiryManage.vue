<template>
  <div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
      <h2 style="margin: 0;">询价管理</h2>
    </div>
    <el-table :data="inquiries" style="width: 100%;" border stripe>
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="product_id" label="产品ID" width="80" />
      <el-table-column prop="product_title" label="产品标题" min-width="150" />
      <el-table-column prop="product_model" label="产品型号" width="120" />
      <el-table-column label="产品主图" width="80" align="center">
        <template #default="scope">
          <img 
            v-if="scope.row.product && scope.row.product.images && scope.row.product.images.length > 0" 
            :src="getImageUrl(scope.row.product.images[0])" 
            style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;"
            @error="handleImageError"
          />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column prop="customer_name" label="客户姓名" width="100" />
      <el-table-column prop="customer_email" label="客户邮箱" min-width="150" />
      <el-table-column prop="customer_phone" label="客户手机号" width="120" />
      <el-table-column prop="inquiry_content" label="询价内容" min-width="200" show-overflow-tooltip />
      <el-table-column prop="created_at" label="创建时间" width="150" />
      <el-table-column label="操作" width="150" align="center">
        <template #default="scope">
          <el-button size="small" @click="viewInquiry(scope.row)">查看</el-button>
          <el-button size="small" type="danger" @click="deleteInquiry(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-dialog v-model="showDetail" title="询价详情" width="600px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="询价ID">{{ detail.id }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ detail.created_at }}</el-descriptions-item>
        <el-descriptions-item label="产品ID">{{ detail.product_id }}</el-descriptions-item>
        <el-descriptions-item label="产品标题">{{ detail.product_title }}</el-descriptions-item>
        <el-descriptions-item label="产品型号">{{ detail.product_model }}</el-descriptions-item>
        <el-descriptions-item label="客户姓名">{{ detail.customer_name }}</el-descriptions-item>
        <el-descriptions-item label="客户邮箱">{{ detail.customer_email }}</el-descriptions-item>
        <el-descriptions-item label="客户手机号">{{ detail.customer_phone }}</el-descriptions-item>
        <el-descriptions-item label="询价内容" :span="2">
          <div style="white-space: pre-wrap; max-height: 200px; overflow-y: auto;">
            {{ detail.inquiry_content }}
          </div>
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="showDetail = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getInquiries, getInquiry, deleteInquiry as deleteInquiryApi } from '../api/inquiry';
import { getImageUrl } from '../utils/imageUtils';

const inquiries = ref([]);
const showDetail = ref(false);
const detail = ref({});

const fetchInquiries = async () => {
  const res = await getInquiries();
  inquiries.value = res.data;
};

const viewInquiry = async (row) => {
  const res = await getInquiry(row.id);
  detail.value = res.data;
  showDetail.value = true;
};

const deleteInquiry = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除询价记录吗？\n客户：${row.customer_name}\n产品：${row.product_title}`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    );
    
    await deleteInquiryApi(row.id);
    ElMessage.success('删除成功');
    await fetchInquiries(); // 重新加载数据
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除询价失败:', error);
      ElMessage.error('删除失败');
    }
  }
};

const handleImageError = (event) => {
  event.target.style.display = 'none';
};

onMounted(fetchInquiries);

// 导出函数供模板使用
const exports = {
  inquiries,
  showDetail,
  detail,
  fetchInquiries,
  viewInquiry,
  deleteInquiry,
  getImageUrl,
  handleImageError
};
</script> 