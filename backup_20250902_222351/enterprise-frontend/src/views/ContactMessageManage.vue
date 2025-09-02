<template>
  <div>
    <div class="header">
      <h2>联系我们消息管理</h2>
    </div>

    <el-table :data="messageList" style="width: 100%" border stripe>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="姓名" width="120" />
      <el-table-column prop="email" label="邮箱" width="200" />
      <el-table-column prop="phone" label="电话" width="150" />
      <el-table-column prop="subject" label="咨询主题" width="200" show-overflow-tooltip />
      <el-table-column prop="message" label="咨询内容" min-width="200" show-overflow-tooltip />
      <el-table-column prop="created_at" label="提交时间" width="180">
        <template #default="scope">
          {{ formatDate(scope.row.created_at) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150">
        <template #default="scope">
          <el-button size="small" @click="showDetailDialog(scope.row)">查看详情</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 详情对话框 -->
    <el-dialog 
      title="消息详情" 
      v-model="detailVisible" 
      width="600px"
    >
      <el-descriptions :column="2" border>
        <el-descriptions-item label="ID">{{ detailMessage.id }}</el-descriptions-item>
        <el-descriptions-item label="提交时间">{{ formatDate(detailMessage.created_at) }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{ detailMessage.name }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ detailMessage.email }}</el-descriptions-item>
        <el-descriptions-item label="电话">{{ detailMessage.phone || '未填写' }}</el-descriptions-item>
        <el-descriptions-item label="咨询主题">{{ detailMessage.subject || '未填写' }}</el-descriptions-item>
        <el-descriptions-item label="咨询内容" :span="2">
          <div style="white-space: pre-wrap; max-height: 200px; overflow-y: auto;">
            {{ detailMessage.message }}
          </div>
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getContactMessages, deleteContactMessage } from '../api/contactMessage';

const messageList = ref([]);
const detailVisible = ref(false);
const detailMessage = ref({});

const fetchData = async () => {
  try {
    const res = await getContactMessages();
    messageList.value = res.data;
  } catch (e) {
    ElMessage.error('获取消息列表失败');
  }
};

const showDetailDialog = (row) => {
  detailMessage.value = row;
  detailVisible.value = true;
};

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除这条消息吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    
    await deleteContactMessage(row.id);
    ElMessage.success('删除成功');
    await fetchData();
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败');
    }
  }
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleString('zh-CN');
};

onMounted(fetchData);
</script>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header h2 {
  margin: 0;
}
</style> 