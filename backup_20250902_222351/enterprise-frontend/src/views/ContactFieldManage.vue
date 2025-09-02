<template>
  <div>
    <div class="header">
      <h2>联系我们字段管理</h2>
      <el-button type="primary" @click="showCreateDialog">新增字段</el-button>
    </div>

    <el-table :data="fieldList" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="field_name" label="字段名" />
      <el-table-column prop="field_label" label="显示名称" />
      <el-table-column prop="field_type" label="字段类型" width="120" />
      <el-table-column label="是否必填" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.is_required ? 'danger' : 'info'">
            {{ scope.row.is_required ? '必填' : '可选' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="sort_order" label="排序" width="80" />
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
      width="500px"
      @close="resetForm"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="字段名" prop="field_name">
          <el-input v-model="form.field_name" placeholder="如：name、email、phone" />
        </el-form-item>
        <el-form-item label="显示名称" prop="field_label">
          <el-input v-model="form.field_label" placeholder="如：姓名、邮箱、电话" />
        </el-form-item>
        <el-form-item label="字段类型" prop="field_type">
          <el-select v-model="form.field_type" placeholder="请选择字段类型">
            <el-option label="文本" value="text" />
            <el-option label="邮箱" value="email" />
            <el-option label="电话" value="tel" />
            <el-option label="文本域" value="textarea" />
          </el-select>
        </el-form-item>
        <el-form-item label="是否必填">
          <el-switch v-model="form.is_required" />
        </el-form-item>
        <el-form-item label="排序" prop="sort_order">
          <el-input-number v-model="form.sort_order" :min="0" />
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
import { ref, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getContactFields, createContactField, updateContactField, deleteContactField } from '../api/contactField';

const fieldList = ref([]);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const saving = ref(false);

const form = ref({
  field_name: '',
  field_label: '',
  field_type: 'text',
  is_required: false,
  sort_order: 0
});

const formRef = ref();

const rules = {
  field_name: [{ required: true, message: '请输入字段名', trigger: 'blur' }],
  field_label: [{ required: true, message: '请输入显示名称', trigger: 'blur' }],
  field_type: [{ required: true, message: '请选择字段类型', trigger: 'change' }],
  sort_order: [{ required: true, message: '请输入排序', trigger: 'blur' }]
};

const fetchData = async () => {
  try {
    const res = await getContactFields();
    fieldList.value = res.data;
  } catch (e) {
    ElMessage.error('获取字段列表失败');
  }
};

const showCreateDialog = () => {
  dialogTitle.value = '新增字段';
  dialogVisible.value = true;
  resetForm();
};

const showEditDialog = (row) => {
  dialogTitle.value = '编辑字段';
  dialogVisible.value = true;
  Object.assign(form.value, row);
};

const resetForm = () => {
  form.value = {
    field_name: '',
    field_label: '',
    field_type: 'text',
    is_required: false,
    sort_order: 0
  };
  formRef.value?.resetFields();
};

const handleSave = async () => {
  if (!formRef.value) return;
  
  try {
    await formRef.value.validate();
    saving.value = true;
    
    if (form.value.id) {
      await updateContactField(form.value.id, form.value);
      ElMessage.success('更新成功');
    } else {
      await createContactField(form.value);
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
    await ElMessageBox.confirm('确定要删除这个字段吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    
    await deleteContactField(row.id);
    ElMessage.success('删除成功');
    await fetchData();
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败');
    }
  }
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