<template>
  <div>
    <div class="header">
      <h2>业务板块管理</h2>
      <el-button type="primary" @click="showCreateDialog">新增业务</el-button>
    </div>

    <el-table :data="serviceList" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column label="配图" width="200">
        <template #default="scope">
          <el-image 
            v-if="scope.row.image_url" 
            :src="scope.row.image_url" 
            style="width: 150px; height: 100px"
            fit="cover"
            :preview-src-list="[scope.row.image_url]"
          />
          <span v-else>无图片</span>
        </template>
      </el-table-column>
      <el-table-column prop="name" label="业务名称" />
      <el-table-column prop="description" label="业务简介" show-overflow-tooltip />
      <el-table-column prop="sort_order" label="排序" width="80" />
      <el-table-column label="状态" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.is_active ? 'success' : 'danger'">
            {{ scope.row.is_active ? '启用' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" @click="showEditDialog(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/编辑对话框 -->
    <el-dialog 
      :title="dialogTitle" 
      v-model="dialogVisible" 
      width="600px"
      @close="resetForm"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="业务名称" prop="name">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="业务简介">
          <el-input v-model="form.description" type="textarea" :rows="4" />
        </el-form-item>
        <el-form-item label="配图">
          <div class="image-upload">
            <el-image 
              v-if="form.image_url" 
              :src="form.image_url" 
              style="width: 200px; height: 150px; margin-bottom: 10px"
              fit="cover"
            />
            <el-upload
              class="upload-demo"
              :action="uploadUrl"
              :on-success="handleImageSuccess"
              :on-error="handleImageError"
              :before-upload="beforeImageUpload"
              :show-file-list="false"
              accept="image/*"
            >
              <el-button type="primary">上传图片</el-button>
              <template #tip>
                <div class="el-upload__tip">
                  只能上传jpg/png文件，且不超过2MB
                </div>
              </template>
            </el-upload>
          </div>
        </el-form-item>
        <el-form-item label="排序" prop="sort_order">
          <el-input-number v-model="form.sort_order" :min="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.is_active" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSave" :loading="saving">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getServices, createService, updateService, deleteService as delService } from '../api/service';
import { API_BASE_URL, UPLOAD_PATH } from '../../env.config.js';
import { getImageUrl } from '../utils/imageUtils';

const serviceList = ref([]);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const saving = ref(false);
  const uploadUrl = `${API_BASE_URL}/upload/`;

const form = ref({
  name: '',
  description: '',
  image_url: '',
  sort_order: 0,
  is_active: true
});

const formRef = ref();

const rules = {
  name: [{ required: true, message: '请输入业务名称', trigger: 'blur' }],
  sort_order: [{ required: true, message: '请输入排序', trigger: 'blur' }]
};

const fetchData = async () => {
  try {
    const res = await getServices();
    serviceList.value = res.data;
  } catch (e) {
    ElMessage.error('获取业务列表失败');
  }
};

const showCreateDialog = () => {
  dialogTitle.value = '新增业务';
  dialogVisible.value = true;
  resetForm();
};

const showEditDialog = (row) => {
  dialogTitle.value = '编辑业务';
  dialogVisible.value = true;
  // 复制数据并转换is_active为布尔值
  Object.assign(form.value, {
    ...row,
    is_active: Boolean(row.is_active)
  });
};

const resetForm = () => {
  form.value = {
    name: '',
    description: '',
    image_url: '',
    sort_order: 0,
    is_active: true
  };
  formRef.value?.resetFields();
};

const handleSave = async () => {
  if (!formRef.value) return;
  
  try {
    await formRef.value.validate();
    saving.value = true;
    
    // 准备发送的数据，转换is_active为数字
    const sendData = {
      ...form.value,
      is_active: form.value.is_active ? 1 : 0
    };
    
    if (form.value.id) {
      await updateService(form.value.id, sendData);
      ElMessage.success('更新成功');
    } else {
      await createService(sendData);
      ElMessage.success('创建成功');
    }
    
    dialogVisible.value = false;
    await fetchData();
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '保存失败');
  } finally {
    saving.value = false;
  }
};

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除这个业务吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    
    await delService(row.id);
    ElMessage.success('删除成功');
    await fetchData();
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败');
    }
  }
};

// 图片上传相关方法
const beforeImageUpload = (file) => {
  const isJPG = file.type === 'image/jpeg' || file.type === 'image/png';
  const isLt2M = file.size / 1024 / 1024 < 2;

  if (!isJPG) {
    ElMessage.error('上传图片只能是 JPG/PNG 格式!');
  }
  if (!isLt2M) {
    ElMessage.error('上传图片大小不能超过 2MB!');
  }
  return isJPG && isLt2M;
};

const handleImageSuccess = (response) => {
  form.value.image_url = getImageUrl(response.url);
  ElMessage.success('图片上传成功');
};

const handleImageError = () => {
  ElMessage.error('图片上传失败');
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

.image-upload {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}
</style> 