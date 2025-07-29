<template>
  <div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
      <h2 style="margin: 0;">产品管理</h2>
      <el-button type="primary" @click="openAddDialog">新增产品</el-button>
    </div>
    
    <!-- 搜索区域 -->
    <el-card style="margin-bottom: 20px;">
      <el-form :model="searchForm" inline>
        <el-form-item label="产品标题">
          <el-input v-model="searchForm.title" placeholder="请输入产品标题" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="产品ID">
          <el-input v-model="searchForm.product_id" placeholder="请输入产品ID" clearable style="width: 150px;" />
        </el-form-item>
        <el-form-item label="产品型号">
          <el-input v-model="searchForm.model" placeholder="请输入产品型号" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="产品分类">
          <el-select v-model="searchForm.category_id" placeholder="请选择分类" clearable style="width: 200px;">
            <el-option 
              v-for="category in allCategories" 
              :key="category.id" 
              :label="category.name" 
              :value="category.id" 
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="searchProducts">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    
    <!-- 产品列表 -->
    <div class="table-container">
      <el-table :data="products" style="width: 100%;" border stripe>
        <el-table-column prop="id" label="ID" width="60" align="center" />
        <el-table-column prop="title" label="标题" min-width="200" />
        <el-table-column prop="model" label="型号" width="120" />
        <el-table-column label="分类" width="120">
          <template #default="scope">
            <span v-if="scope.row.category">{{ scope.row.category.name }}</span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="主图" width="80" align="center">
          <template #default="scope">
            <el-image 
              v-if="scope.row.images && scope.row.images.length > 0"
              :src="getImageUrl(scope.row.images[0])" 
              style="width: 40px; height: 40px; object-fit: cover;"
              :preview-src-list="scope.row.images.map(img => getImageUrl(img))"
            />
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" width="160" align="center">
          <template #default="scope">
            <span>{{ formatDateTime(scope.row.created_at) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="修改时间" width="160" align="center">
          <template #default="scope">
            <span>{{ formatDateTime(scope.row.updated_at) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center">
          <template #default="scope">
            <el-button size="small" type="primary" @click="editProduct(scope.row)">编辑</el-button>
            <el-button size="small" type="success" @click="copyProductHandler(scope.row)">复制</el-button>
            <el-button size="small" type="danger" @click="deleteProduct(scope.row.id)">删除</el-button>
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

    <!-- 新增/编辑产品弹窗 -->
    <el-dialog 
      v-model="showAdd" 
      title="新增/编辑产品" 
      width="80%" 
      :close-on-click-modal="false"
      top="5vh"
    >
      <el-form :model="editForm" :rules="rules" ref="formRef" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="产品标题" prop="title">
              <el-input v-model="editForm.title" placeholder="请输入产品标题" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品型号" prop="model">
              <el-input v-model="editForm.model" placeholder="请输入产品型号" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="大类目" prop="parentCategoryId">
              <el-select 
                v-model="editForm.parentCategoryId" 
                placeholder="请选择大类目"
                @change="onParentCategoryChange"
                clearable
              >
                <el-option 
                  v-for="category in parentCategories" 
                  :key="category.id" 
                  :label="category.name" 
                  :value="category.id" 
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="子分类" prop="category_id">
              <el-select 
                v-model="editForm.category_id" 
                placeholder="请选择子分类"
                :disabled="!editForm.parentCategoryId"
                clearable
              >
                <el-option 
                  v-for="category in subCategories" 
                  :key="category.id" 
                  :label="category.name" 
                  :value="category.id" 
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="产品主图" prop="images">
          <div style="display: flex; flex-wrap: wrap; gap: 10px;">

            
            <!-- 已上传的图片 -->
            <draggable 
              v-model="fileList" 
              item-key="name" 
              :animation="200"
              @end="onDragEnd"
            >
              <template #item="{element, index}">
                <div class="image-item" style="position: relative;">
                  <div class="upload-area">
                    <img v-if="element.url" :src="getImageUrl(element.url)" class="preview-image" />
                    <div v-else class="upload-placeholder">
                      <el-icon><Plus /></el-icon>
                    </div>
                  </div>
                  <el-button 
                    v-if="element.url"
                    type="danger" 
                    size="small" 
                    circle 
                    class="remove-btn"
                    @click="removeImage(index)"
                  >
                    <el-icon><Close /></el-icon>
                  </el-button>
                </div>
              </template>
            </draggable>
            
            <!-- 上传按钮 -->
            <el-upload
              v-if="fileList.length < 5"
              :key="`upload-${fileList.length}`"
              :action="uploadUrl"
              :headers="uploadHeaders"
              :show-file-list="false"
              :on-success="handleNewUploadSuccess"
              :before-upload="beforeUpload"
              accept="image/jpeg,image/png"
            >
              <div class="upload-area">
                <div class="upload-placeholder">
                  <el-icon><Plus /></el-icon>
                </div>
              </div>
            </el-upload>
          </div>
          <el-dialog v-model="previewVisible">
            <img w-full :src="previewImage" alt="Preview Image" />
          </el-dialog>
          <div style="color: #999; font-size: 12px; margin-top: 5px;">
            支持JPG/PNG格式，最多上传5张图片，至少上传1张。可拖拽调整顺序，首图为主图。
          </div>
        </el-form-item>

        <el-form-item label="简要介绍" prop="short_desc">
          <div style="border: 1px solid #dcdfe6; border-radius: 4px;">
            <Toolbar
              v-if="editorRef"
              style="border-bottom: 1px solid #ccc"
              :editor="editorRef"
              :defaultConfig="toolbarConfig"
              :mode="mode"
            />
            <Editor
              v-if="showAdd"
              style="height: 200px; overflow-y: hidden;"
              v-model="editForm.short_desc"
              :defaultConfig="getShortDescEditorConfig()"
              :mode="mode"
              @onCreated="handleCreated"
            />
          </div>
        </el-form-item>

        <el-form-item label="详情介绍" prop="detail">
          <div style="border: 1px solid #dcdfe6; border-radius: 4px;">
            <Toolbar
              v-if="editorRef2"
              style="border-bottom: 1px solid #ccc"
              :editor="editorRef2"
              :defaultConfig="toolbarConfigDetail"
              :mode="mode"
            />
            <Editor
              v-if="showAdd"
              style="height: 300px; overflow-y: hidden;"
              v-model="editForm.detail"
              :defaultConfig="getEditorConfig()"
              :mode="mode"
              @onCreated="handleCreated2"
            />
          </div>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="closeDialog">取消</el-button>
        <el-button type="primary" @click="saveProduct" :loading="saving">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, watch } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Plus, Close } from '@element-plus/icons-vue';
import { getProducts, createProduct, updateProduct, deleteProduct as delProduct, copyProduct } from '../api/product';
import { getCategoriesTree, getSubcategories, getCategories } from '../api/category';
import '@wangeditor/editor/dist/css/style.css';
import { Editor, Toolbar } from '@wangeditor/editor-for-vue';
import draggable from 'vuedraggable';

// 基础变量定义
const products = ref([]);
const showAdd = ref(false);
const saving = ref(false);
const formRef = ref();
const uploadRef = ref();
const previewVisible = ref(false);
const previewImage = ref('');

// 分页相关
const pagination = ref({
  currentPage: 1,
  pageSize: 10,
  total: 0,
  totalPages: 0
});

// 上传相关
const uploadUrl = 'http://localhost:8000/api/upload/';
const uploadHeaders = ref({
  Authorization: `Bearer ${localStorage.getItem('token')}`
});

// 更新上传headers的函数
const updateUploadHeaders = () => {
  uploadHeaders.value = {
    Authorization: `Bearer ${localStorage.getItem('token')}`
  };
};

// 富文本编辑器相关
const editorRef = ref();
const editorRef2 = ref();
const mode = 'default';

// 简要介绍的工具栏配置（不包含图片上传，但包含表格）
const toolbarConfig = {
  excludeKeys: [
    'uploadImage',
    'uploadVideo',
    'codeBlock',
    'fullScreen'
  ]
};

// 详情介绍的工具栏配置（包含图片上传）
const toolbarConfigDetail = {
  excludeKeys: [
    'uploadVideo',
    'codeBlock',
    'fullScreen'
  ]
};

// 简要介绍的编辑器配置（不包含图片上传，但包含表格）
const getShortDescEditorConfig = () => {
  return {
    placeholder: '请输入内容...',
    MENU_CONF: {
      // 表格配置
      insertTable: {
        // 表格默认配置
        maxRow: 20,
        maxCol: 10,
        // 表格样式配置
        tableStyle: {
          width: '100%',
          border: '1px solid #ccc',
          borderCollapse: 'collapse'
        },
        // 单元格样式配置
        cellStyle: {
          border: '1px solid #ccc',
          padding: '8px',
          textAlign: 'left'
        },
        // 表头样式配置
        headerStyle: {
          backgroundColor: '#f5f5f5',
          fontWeight: 'bold'
        }
      }
    }
  };
};

// 编辑器配置
const getEditorConfig = () => {
  console.log('获取编辑器配置，当前headers:', uploadHeaders.value);
  return {
    placeholder: '请输入内容...',
    MENU_CONF: {
      uploadImage: {
        server: uploadUrl,
        fieldName: 'file',
        headers: uploadHeaders.value,
        // 处理后端返回的图片URL
        customInsert(res, insertFn) {
          const fullUrl = getImageUrl(res.url);
          insertFn(fullUrl, '', '');
        },
        // 允许上传多张图片
        maxFileSize: 2 * 1024 * 1024, // 2MB
        maxNumberOfFiles: 10, // 最多10张图片
        allowedFileTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'],
        // 允许重复文件上传
        checkDuplicate: false,
        // 允许重复文件上传
        onBeforeUpload(file) {
          console.log('=== 富文本编辑器上传前验证开始 ===');
          console.log('传入的file对象:', file);
          console.log('file对象的类型:', typeof file);
          console.log('file对象的构造函数:', file.constructor);
          console.log('file对象的所有属性:', Object.keys(file));
          console.log('file.name:', file.name);
          console.log('file.type:', file.type);
          console.log('file.size:', file.size);
          console.log('file.data:', file.data);
          console.log('file.source:', file.source);
          console.log('file.meta:', file.meta);
          console.log('file.progress:', file.progress);
          console.log('file.response:', file.response);
          console.log('file.isRemote:', file.isRemote);
          console.log('file.remote:', file.remote);
          console.log('file.preview:', file.preview);
          console.log('file.thumbnail:', file.thumbnail);
          console.log('file.uploadURL:', file.uploadURL);
          console.log('file.response.body:', file.response?.body);
          console.log('file.response.uploadURL:', file.response?.uploadURL);
          console.log('=== 富文本编辑器上传前验证结束 ===');

          // 临时：先让所有文件通过，根据日志结果再调整
          console.log('临时：允许所有文件上传，等待日志分析');
          return true;
        },
        // 上传失败处理
        onError(file, err, res) {
          ElMessage.error('图片上传失败');
          console.error('图片上传失败:', err, res);
        }
      },
      // 表格配置
      insertTable: {
        // 表格默认配置
        maxRow: 20,
        maxCol: 10,
        // 表格样式配置
        tableStyle: {
          width: '100%',
          border: '1px solid #ccc',
          borderCollapse: 'collapse'
        },
        // 单元格样式配置
        cellStyle: {
          border: '1px solid #ccc',
          padding: '8px',
          textAlign: 'left'
        },
        // 表头样式配置
        headerStyle: {
          backgroundColor: '#f5f5f5',
          fontWeight: 'bold'
        }
      }
    }
  };
};

// 分类相关
const parentCategories = ref([]);
const subCategories = ref([]);
const allCategories = ref([]); // 所有分类，用于搜索

// 搜索表单
const searchForm = ref({
  title: '',
  product_id: '',
  model: '',
  category_id: ''
});

// 当前搜索参数
const currentSearchParams = ref({});

// 表单数据
const editForm = ref({
  id: null,
  title: '',
  model: '',
  parentCategoryId: null,
  category_id: null,
  short_desc: '',
  detail: '',
  images: []
});

// 文件列表
const fileList = ref([]);

// 表单验证规则
const rules = {
  title: [{ required: true, message: '请输入产品标题', trigger: 'blur' }],
  model: [{ required: true, message: '请输入产品型号', trigger: 'blur' }],
  category_id: [{ required: true, message: '请选择子分类', trigger: 'change' }],
  images: [{ 
    validator: (rule, value, callback) => {
      if (!value || value.length === 0) {
        callback(new Error('至少上传1张产品主图'));
      } else {
        callback();
      }
    }, 
    trigger: 'change' 
  }]
};

// 获取产品列表
const fetchProducts = async (searchParams = {}) => {
  try {
    const params = {
      page: pagination.value.currentPage,
      page_size: pagination.value.pageSize,
      ...searchParams
    };
    const res = await getProducts(params);
    products.value = res.data.items;
    pagination.value.total = res.data.total;
    pagination.value.totalPages = res.data.total_pages;
  } catch (error) {
    ElMessage.error('获取产品列表失败');
  }
};

// 搜索产品
const searchProducts = async () => {
  const params = {};
  if (searchForm.value.title) params.title = searchForm.value.title;
  if (searchForm.value.product_id) params.product_id = parseInt(searchForm.value.product_id);
  if (searchForm.value.model) params.model = searchForm.value.model;
  if (searchForm.value.category_id) params.category_id = parseInt(searchForm.value.category_id);
  
  // 保存当前搜索参数
  currentSearchParams.value = { ...params };
  
  pagination.value.currentPage = 1;
  await fetchProducts(params);
};

// 重置搜索
const resetSearch = () => {
  searchForm.value = {
    title: '',
    product_id: '',
    model: '',
    category_id: ''
  };
  // 清空当前搜索参数
  currentSearchParams.value = {};
  pagination.value.currentPage = 1;
  fetchProducts();
};

// 获取分类数据
const fetchCategories = async () => {
  try {
    const res = await getCategoriesTree();
    parentCategories.value = res.data;
    
    // 获取所有分类，然后过滤出子分类用于搜索
    const allCategoriesRes = await getCategories();
    // 只保留有父级分类的子分类
    allCategories.value = allCategoriesRes.data.filter(category => category.parent_id !== null);
  } catch (error) {
    ElMessage.error('获取分类数据失败');
  }
};

// 大类目变化时获取子分类
const onParentCategoryChange = async (parentId, keepCategoryId = false) => {
  if (!keepCategoryId) {
    editForm.value.category_id = null;
  }
  subCategories.value = [];
  
  if (parentId) {
    try {
      const res = await getSubcategories(parentId);
      subCategories.value = res.data;
    } catch (error) {
      ElMessage.error('获取子分类失败');
    }
  }
};

// 编辑产品
const editProduct = async (row) => {
  // 先重置表单，销毁现有编辑器
  resetForm();
  
  editForm.value = {
    id: row.id,
    title: row.title,
    model: row.model,
    parentCategoryId: row.category?.parent_id || null,
    category_id: row.category_id,
    short_desc: row.short_desc || '',
    detail: row.detail || '',
    images: row.images || []
  };
  
  // 设置文件列表
  fileList.value = (row.images || []).map((url, index) => ({
    name: `image_${index + 1}.jpg`,
    url: url
  }));
  
  // 如果有父分类，先获取子分类，保持原有的category_id
  if (editForm.value.parentCategoryId) {
    await onParentCategoryChange(editForm.value.parentCategoryId, true);
  }
  
  showAdd.value = true;
};

// 保存产品
const saveProduct = async () => {
  if (!formRef.value) return;
  
  try {
    await formRef.value.validate();
    saving.value = true;
    
    const data = {
      title: editForm.value.title,
      model: editForm.value.model,
      category_id: editForm.value.category_id,
      short_desc: editForm.value.short_desc,
      detail: editForm.value.detail,
      images: editForm.value.images
    };
    
    if (editForm.value.id) {
      await updateProduct(editForm.value.id, data);
      ElMessage.success('更新成功');
    } else {
      await createProduct(data);
      ElMessage.success('创建成功');
    }
    
    closeDialog();
    // 新增产品后回到第一页
    pagination.value.currentPage = 1;
    fetchProducts(currentSearchParams.value);
  } catch (error) {
    if (error.response?.data?.detail) {
      ElMessage.error(error.response.data.detail);
    } else {
      ElMessage.error('保存失败');
    }
  } finally {
    saving.value = false;
  }
};

// 删除产品
const deleteProduct = async (id) => {
  try {
    await ElMessageBox.confirm('确定要删除这个产品吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    
    await delProduct(id);
    ElMessage.success('删除成功');
    // 如果当前页没有数据了，回到上一页
    if (products.value.length === 1 && pagination.value.currentPage > 1) {
      pagination.value.currentPage--;
    }
    fetchProducts(currentSearchParams.value);
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败');
    }
  }
};

// 复制产品
const copyProductHandler = async (row) => {
  try {
    await ElMessageBox.confirm('确定要复制这个产品吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'info'
    });
    
    const res = await copyProduct(row.id);
    ElMessage.success('复制成功');
    
    // 复制成功后刷新产品列表，回到第一页
    pagination.value.currentPage = 1;
    fetchProducts(currentSearchParams.value);
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('复制失败');
    }
  }
};

// 富文本编辑器创建完成
const handleCreated = (editor) => {
  console.log('简要介绍编辑器创建完成');
  editorRef.value = editor;
};

const handleCreated2 = (editor) => {
  console.log('详情介绍编辑器创建完成');
  editorRef2.value = editor;
};

// 图片上传相关
const handlePictureCardPreview = (file) => {
  previewImage.value = file.url;
  previewVisible.value = true;
};

const handleRemove = (file, fileList) => {
  const index = editForm.value.images.indexOf(file.url);
  if (index > -1) {
    editForm.value.images.splice(index, 1);
  }
};

// 处理新上传的图片
const handleNewUploadSuccess = (response, file) => {
  const newFile = {
    name: file.name,
    url: response.url
  };
  fileList.value.push(newFile);
  updateImagesFromFileList();
};

// 处理已上传图片的更新（用于编辑时）
const handleUploadSuccess = (response, file, index) => {
  fileList.value[index].url = response.url;
  updateImagesFromFileList();
};

// 同步images顺序
const updateImagesFromFileList = () => {
  editForm.value.images = fileList.value.map(f => f.url).filter(Boolean);
};

// 拖拽结束事件
const onDragEnd = () => {
  updateImagesFromFileList();
};

// 移除图片
const removeImage = (index) => {
  fileList.value.splice(index, 1);
  updateImagesFromFileList();
};

const beforeUpload = (file) => {
  const isJPG = file.type === 'image/jpeg';
  const isPNG = file.type === 'image/png';
  const isLt2M = file.size / 1024 / 1024 < 2;

  if (!isJPG && !isPNG) {
    ElMessage.error('上传图片只能是 JPG/PNG 格式!');
    return false;
  }
  if (!isLt2M) {
    ElMessage.error('上传图片大小不能超过 2MB!');
    return false;
  }
  return true;
};

// 重置表单
const resetForm = () => {
  // 先销毁现有编辑器
  if (editorRef.value) {
    try {
      editorRef.value.destroy();
    } catch (error) {
      // 忽略销毁错误
    }
    editorRef.value = null;
  }
  if (editorRef2.value) {
    try {
      editorRef2.value.destroy();
    } catch (error) {
      // 忽略销毁错误
    }
    editorRef2.value = null;
  }
  
  // 重置表单数据
  editForm.value = {
    id: null,
    title: '',
    model: '',
    parentCategoryId: null,
    category_id: null,
    short_desc: '',
    detail: '',
    images: []
  };
  fileList.value = [];
  subCategories.value = [];
  updateUploadHeaders();
};

// 关闭弹窗
const closeDialog = () => {
  // 先销毁编辑器
  if (editorRef.value) {
    try {
      editorRef.value.destroy();
    } catch (error) {
      // 忽略销毁错误
    }
    editorRef.value = null;
  }
  if (editorRef2.value) {
    try {
      editorRef2.value.destroy();
    } catch (error) {
      // 忽略销毁错误
    }
    editorRef2.value = null;
  }
  
  // 然后关闭弹窗
  showAdd.value = false;
};

// 监听弹窗关闭
const handleDialogClose = () => {
  resetForm();
  if (editorRef.value) {
    editorRef.value.destroy();
  }
  if (editorRef2.value) {
    editorRef2.value.destroy();
  }
};

onMounted(() => {
  updateUploadHeaders();
  fetchProducts();
  fetchCategories();
});

onUnmounted(() => {
  // 组件卸载时销毁编辑器
  if (editorRef.value) {
    try {
      editorRef.value.destroy();
    } catch (error) {
      // 忽略销毁错误
    }
  }
  if (editorRef2.value) {
    try {
      editorRef2.value.destroy();
    } catch (error) {
      // 忽略销毁错误
    }
  }
});

// 打开新增产品弹窗
const openAddDialog = () => {
  resetForm();
  showAdd.value = true;
  nextTick(() => {
    console.log('弹窗已打开，准备创建编辑器');
  });
};

// 获取完整的图片URL
const getImageUrl = (url) => {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  return `http://localhost:8000${url}`;
};

// 格式化日期时间
const formatDateTime = (dateTimeStr) => {
  if (!dateTimeStr) return '-';
  const date = new Date(dateTimeStr);
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  });
};

// 分页处理函数
const handlePageChange = (page) => {
  pagination.value.currentPage = page;
  fetchProducts(currentSearchParams.value);
};

const handleSizeChange = (size) => {
  pagination.value.pageSize = size;
  pagination.value.currentPage = 1;
  fetchProducts(currentSearchParams.value);
};

// 监听弹窗打开，更新headers
watch(showAdd, (newVal) => {
  if (newVal) {
    updateUploadHeaders();
  }
});
</script>

<style scoped>
.table-container {
  margin-bottom: 20px;
  overflow-x: auto;
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.pagination-container {
  display: flex;
  justify-content: center;
  padding: 20px 0;
  background-color: #f5f5f5;
  border-radius: 4px;
  margin-top: 20px;
  position: relative;
  z-index: 1;
}

.image-item {
  position: relative;
  display: inline-block;
  cursor: move;
  transition: transform 0.2s ease;
}

.image-item:hover {
  transform: scale(1.05);
}

.image-item.sortable-ghost {
  opacity: 0.5;
}

.image-item.sortable-chosen {
  transform: scale(1.1);
  z-index: 1000;
}

.upload-area {
  width: 100px;
  height: 100px;
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #fafafa;
}

.upload-area:hover {
  border-color: #409eff;
}

.preview-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.upload-placeholder {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  color: #8c939d;
  font-size: 28px;
}

.remove-btn {
  position: absolute;
  top: -8px;
  right: -8px;
  z-index: 10;
}
</style> 