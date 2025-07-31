<template>
  <div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
      <h2 style="margin: 0;">分类管理</h2>
      <el-button type="primary" @click="addCategory">新增分类</el-button>
    </div>
    
    <!-- 分类列表 -->
    <el-table :data="categories" style="width: 100%;" row-key="id" border stripe>
      <el-table-column prop="id" label="ID" width="60" align="center" />
      <el-table-column prop="name" label="分类名称" min-width="150" />
      <el-table-column prop="parent_id" label="父级分类" min-width="120">
        <template #default="scope">
          <span v-if="scope.row.parent_id">{{ getParentName(scope.row.parent_id) }}</span>
          <span v-else class="text-primary">顶级分类</span>
        </template>
      </el-table-column>
      <el-table-column prop="sort_order" label="排序" width="80" align="center" />
      <el-table-column label="图片" width="100" align="center">
        <template #default="scope">
          <el-image 
            v-if="scope.row.image" 
            :src="scope.row.image" 
            style="width: 50px; height: 50px; border-radius: 4px;"
            fit="cover"
            :preview-src-list="[scope.row.image]"
          />
          <span v-else style="color: #909399;">无图片</span>
        </template>
      </el-table-column>
              <el-table-column label="操作" width="150" align="center">
          <template #default="scope">
            <el-button size="small" type="primary" @click="editCategory(scope.row)">编辑</el-button>
            <el-button size="small" type="danger" @click="onDeleteClick(scope.row)">删除</el-button>
          </template>
        </el-table-column>
    </el-table>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="showAdd" :title="editForm.id ? '编辑分类' : '新增分类'" width="700px" :close-on-click-modal="false">
      <el-form :model="editForm" label-width="100px">
        <el-form-item label="分类名称" required>
          <el-input v-model="editForm.name" placeholder="请输入分类名称" />
        </el-form-item>
        
        <el-form-item label="父级分类">
          <el-select
            v-model="editForm.parent_id"
            placeholder="请选择父级分类"
            clearable
            :disabled="editForm.id && hasChildren(editForm.id)"
          >
            <el-option label="顶级分类" :value="0" style="font-weight: bold; color: #409EFF;" />
            <el-option 
              v-for="category in parentCategories" 
              :key="category.id" 
              :label="category.name" 
              :value="category.id" 
            />
          </el-select>
          <div style="margin-top: 5px; font-size: 12px; color: #909399;">
            选择"顶级分类"将创建顶级分类，选择其他分类将创建子分类
          </div>
          <div style="margin-top: 5px; font-size: 12px; color: #606266;">
            当前选择: {{ editForm.parent_id === 0 ? '顶级分类' : getParentName(editForm.parent_id) }}
          </div>
          <div v-if="editForm.id && hasChildren(editForm.id)" style="margin-top: 5px; font-size: 12px; color: #E6A23C;">
            ⚠️ 注意：此分类下有子分类，不能修改父级分类
          </div>
        </el-form-item>
        
        <el-form-item label="排序">
          <el-input-number v-model="editForm.sort_order" :min="0" placeholder="数字越小越靠前" />
        </el-form-item>
        
        <el-form-item label="分类图片">
          <el-upload
            :action="uploadUrl"
            :before-upload="beforeImageUpload"
            :on-success="handleImageSuccess"
            :on-error="handleImageError"
            :show-file-list="false"
            accept="image/*"
          >
            <el-image 
              v-if="editForm.image" 
              :src="editForm.image" 
              style="width: 100px; height: 100px; margin-right: 10px;"
              fit="cover"
            />
            <el-button v-else type="primary">上传图片</el-button>
          </el-upload>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" @click="saveCategory" :loading="saving">保存</el-button>
      </template>
    </el-dialog>

    <!-- 删除确认对话框 -->
    <el-dialog
      v-model="deleteConfirmId"
      title="确认删除"
      width="350px"
      :before-close="() => { deleteConfirmId = null }"
    >
      <div>确定要删除该分类吗？此操作不可恢复。</div>
      <template #footer>
        <el-button @click="deleteConfirmId = null">取消</el-button>
        <el-button type="danger" @click="handleDeleteCategory" :loading="saving">确认删除</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { ElMessage } from 'element-plus';
import { getCategories, createCategory, updateCategory, deleteCategory as delCategory } from '../api/category';
import { API_BASE_URL, UPLOAD_PATH } from '../../env.config.js';
import { getImageUrl } from '../utils/imageUtils';

const categories = ref([]);
const showAdd = ref(false);
const saving = ref(false);
const deleteConfirmId = ref(null);
  const uploadUrl = `${API_BASE_URL}/upload/`;

const editForm = ref({ 
  id: null, 
  name: '', 
  parent_id: 0, 
  image: '', 
  sort_order: 0 
});

// 获取父级分类选项（只显示顶级分类）
const parentCategories = computed(() => {
  return categories.value.filter(cat => cat.parent_id === null || cat.parent_id === undefined || cat.parent_id === 0);
});

// 获取父级分类名称
const getParentName = (parentId) => {
  const parent = categories.value.find(cat => cat.id === parentId);
  return parent ? parent.name : '未知';
};

const fetchCategories = async () => {
  try {
    const res = await getCategories();
    categories.value = res.data;
  } catch (e) {
    ElMessage.error('获取分类列表失败');
  }
};

const editCategory = (row) => {
  editForm.value = { ...row };
  // 确保编辑时正确设置父级分类的值
  if (editForm.value.parent_id === null || editForm.value.parent_id === undefined) {
    editForm.value.parent_id = 0; // 顶级分类显示为0
  }
  showAdd.value = true;
};

const saveCategory = async () => {
  if (!editForm.value.name.trim()) {
    ElMessage.error('请输入分类名称');
    return;
  }
  
  saving.value = true;
  try {
    if (editForm.value.id) {
      // 更新分类 - 移除id字段，确保parent_id正确处理
      const updateData = { ...editForm.value };
      delete updateData.id;
      
      // 确保parent_id为0时更新为顶级分类
      if (updateData.parent_id === 0) {
        updateData.parent_id = null;
      }
      
      await updateCategory(editForm.value.id, updateData);
      ElMessage.success('更新成功');
    } else {
      // 创建分类 - 移除id字段，确保parent_id正确处理
      const createData = { ...editForm.value };
      delete createData.id;
      
      // 确保parent_id为0时创建顶级分类
      if (createData.parent_id === 0) {
        createData.parent_id = null;
      }
      
      await createCategory(createData);
      ElMessage.success('创建成功');
    }
    showAdd.value = false;
    await fetchCategories();
    resetForm();
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '保存失败');
  } finally {
    saving.value = false;
  }
};

const deleteCategory = async (id) => {
  try {
    await delCategory(id);
    ElMessage.success('删除成功');
    await fetchCategories();
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '删除失败');
  }
};

const handleDeleteCategory = async () => {
  if (!deleteConfirmId.value) return;
  try {
    await delCategory(deleteConfirmId.value);
    ElMessage.success('删除成功');
    await fetchCategories();
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '删除失败');
  } finally {
    deleteConfirmId.value = null;
  }
};

const onDeleteClick = (row) => {
  if (hasChildren(row.id)) {
    ElMessage.error('该分类下有子分类，请先删除子分类');
    return;
  }
  deleteConfirmId.value = row.id;
};

const resetForm = () => {
  editForm.value = { 
    id: null, 
    name: '', 
    parent_id: 0, 
    image: '', 
    sort_order: 0 
  };
};

// 添加新分类时，默认选择顶级分类
const addCategory = () => {
  resetForm();
  editForm.value.parent_id = 0; // 确保默认选择顶级分类
  showAdd.value = true;
  console.log('新增分类，默认parent_id:', editForm.value.parent_id); // 调试信息
};

// 图片上传相关方法
const beforeImageUpload = (file) => {
  const isImage = file.type.startsWith('image/');
  const isLt2M = file.size / 1024 / 1024 < 2;

  if (!isImage) {
    ElMessage.error('只能上传图片文件!');
    return false;
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!');
    return false;
  }
  return true;
};

const handleImageSuccess = (response) => {
  editForm.value.image = getImageUrl(response.url);
  ElMessage.success('图片上传成功');
};

const handleImageError = () => {
  ElMessage.error('图片上传失败');
};

const hasChildren = (categoryId) => {
  if (!categoryId) return false; // 新增时 categoryId 为 null，返回 false
  return categories.value.some(cat => cat.parent_id === categoryId);
};

onMounted(fetchCategories);
</script>

<style scoped>
.text-primary {
  color: #409eff;
}
</style> 