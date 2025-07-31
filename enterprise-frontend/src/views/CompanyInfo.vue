<template>
    <div>
      <div class="header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <h2 style="margin: 0;">公司信息管理</h2>
        <el-button 
          v-if="!isEditing && companyInfo.id" 
          type="primary" 
          @click="startEdit"
        >
          修改信息
        </el-button>
        <el-button 
          v-if="!isEditing && !companyInfo.id" 
          type="primary" 
          @click="startEdit"
        >
          创建公司信息
        </el-button>
      </div>
  
      <!-- 查看模式 -->
      <div v-if="!isEditing && companyInfo.id" class="view-mode">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="公司名称">
            {{ companyInfo.name || '未设置' }}
          </el-descriptions-item>
          <el-descriptions-item label="公司邮箱">
            {{ companyInfo.email || '未设置' }}
          </el-descriptions-item>
          <el-descriptions-item label="公司电话">
            {{ companyInfo.phone || '未设置' }}
          </el-descriptions-item>
          <el-descriptions-item label="公司地址" :span="2">
            {{ companyInfo.address || '未设置' }}
          </el-descriptions-item>
          <el-descriptions-item label="工作时间" :span="2">
            {{ companyInfo.working_hours || '未设置' }}
          </el-descriptions-item>
          <el-descriptions-item label="公司图片" :span="2">
            <el-image 
              v-if="companyInfo.company_image" 
              :src="companyInfo.company_image" 
              style="width: 200px; height: 150px"
              fit="contain"
            />
            <span v-else>未设置</span>
          </el-descriptions-item>
          <el-descriptions-item label="Logo" :span="2">
            <el-image 
              v-if="companyInfo.logo_url" 
              :src="companyInfo.logo_url" 
              style="width: 100px; height: 100px"
              fit="contain"
            />
            <span v-else>未设置</span>
          </el-descriptions-item>
          <el-descriptions-item label="主营业务" :span="2">
            {{ companyInfo.main_business || '未设置' }}
          </el-descriptions-item>
          <el-descriptions-item label="主营业务配图" :span="2">
            <el-image 
              v-if="companyInfo.main_pic_url" 
              :src="companyInfo.main_pic_url" 
              style="width: 200px; height: 150px"
              fit="contain"
            />
            <span v-else>未设置</span>
          </el-descriptions-item>
          <el-descriptions-item label="公司介绍" :span="2">
            {{ companyInfo.about_text || '未设置' }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
  
      <!-- 编辑模式 -->
      <div v-if="isEditing" class="edit-mode">
        <el-form :model="form" label-width="120px">
          <el-form-item label="公司名称">
            <el-input v-model="form.name" />
          </el-form-item>
          <el-form-item label="公司邮箱">
            <el-input v-model="form.email" />
          </el-form-item>
          <el-form-item label="公司电话">
            <el-input v-model="form.phone" />
          </el-form-item>
          <el-form-item label="公司地址">
            <el-input v-model="form.address" />
          </el-form-item>
          <el-form-item label="工作时间">
            <el-input v-model="form.working_hours" placeholder="例如：周一至周五 9:00-18:00" />
          </el-form-item>

          <el-form-item label="Logo">
            <div class="logo-upload">
              <el-image 
                v-if="form.logo_url" 
                :src="form.logo_url" 
                style="width: 100px; height: 100px; margin-bottom: 10px"
                fit="contain"
              />
              <el-upload
                class="upload-demo"
                :action="uploadUrl"
                :on-success="handleLogoSuccess"
                :on-error="handleLogoError"
                :before-upload="beforeLogoUpload"
                :show-file-list="false"
                accept="image/*"
              >
                <el-button type="primary">上传Logo</el-button>
                <template #tip>
                  <div class="el-upload__tip">
                    只能上传jpg/png文件，且不超过2MB
                  </div>
                </template>
              </el-upload>
            </div>
          </el-form-item>
          <el-form-item label="主营业务">
            <el-input v-model="form.main_business" type="textarea" :rows="4" />
          </el-form-item>
          <el-form-item label="主营业务配图">
            <div class="logo-upload">
              <el-image 
                v-if="form.main_pic_url" 
                :src="form.main_pic_url" 
                style="width: 200px; height: 150px; margin-bottom: 10px"
                fit="contain"
              />
              <el-upload
                class="upload-demo"
                :action="uploadUrl"
                :on-success="handleMainPicSuccess"
                :on-error="handleMainPicError"
                :before-upload="beforeMainPicUpload"
                :show-file-list="false"
                accept="image/*"
              >
                <el-button type="primary">上传配图</el-button>
                <template #tip>
                  <div class="el-upload__tip">
                    只能上传jpg/png文件，且不超过2MB
                  </div>
                </template>
              </el-upload>
            </div>
          </el-form-item>
          <el-form-item label="公司介绍">
            <el-input v-model="form.about_text" type="textarea" :rows="6" />
          </el-form-item>
          <el-form-item label="公司介绍图片">
            <div class="logo-upload">
              <el-image 
                v-if="form.company_image" 
                :src="form.company_image" 
                style="width: 200px; height: 150px; margin-bottom: 10px"
                fit="contain"
              />
              <el-upload
                class="upload-demo"
                :action="uploadUrl"
                :on-success="handleCompanyImageSuccess"
                :on-error="handleCompanyImageError"
                :before-upload="beforeCompanyImageUpload"
                :show-file-list="false"
                accept="image/*"
              >
                <el-button type="primary">上传公司介绍图片</el-button>
                <template #tip>
                  <div class="el-upload__tip">
                    只能上传jpg/png文件，且不超过2MB
                  </div>
                </template>
              </el-upload>
            </div>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onSave" :loading="saving">保存</el-button>
            <el-button @click="cancelEdit">取消</el-button>
            <el-button type="danger" @click="onDelete" v-if="form.id">删除</el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, reactive, onMounted } from 'vue';
  import { ElMessage } from 'element-plus';
  import { getCompanyInfo, updateCompanyInfo, createCompanyInfo, deleteCompanyInfo } from '../api/company';
  import { API_BASE_URL, UPLOAD_PATH } from '../../env.config.js';
  import { getImageUrl } from '../utils/imageUtils';
  
  const isEditing = ref(false);
  const saving = ref(false);
  const uploadUrl = `${API_BASE_URL}/upload/`;
  
  const companyInfo = ref({});
  const form = ref({
    name: '',
    logo_url: '',
    email: '',
    phone: '',
    address: '',
    working_hours: '',
    company_image: '',
    main_business: '',
    main_pic_url: '',
    about_text: '',
    id: null
  });
  
  const fetchInfo = async () => {
    try {
      const res = await getCompanyInfo();
      companyInfo.value = res.data;
      Object.assign(form.value, res.data);
    } catch {
      // 未设置公司信息
      companyInfo.value = {};
    }
  };
  
  const startEdit = () => {
    isEditing.value = true;
    // 如果是编辑现有信息，复制数据到表单
    if (companyInfo.value.id) {
      Object.assign(form.value, companyInfo.value);
    } else {
      // 如果是新建，清空表单
      Object.keys(form.value).forEach(k => form.value[k] = '');
      form.value.id = null;
    }
  };
  
  const cancelEdit = () => {
    isEditing.value = false;
    fetchInfo(); // 重新获取数据
  };
  
  const onSave = async () => {
    saving.value = true;
    try {
      if (form.value.id) {
        await updateCompanyInfo(form.value);
        ElMessage.success('更新成功');
      } else {
        // 创建时不发送id字段
        const { id, ...createData } = form.value;
        await createCompanyInfo(createData);
        ElMessage.success('创建成功');
      }
      await fetchInfo();
      isEditing.value = false; // 保存成功后退出编辑模式
    } catch (e) {
      ElMessage.error(e.response?.data?.detail || '保存失败');
    } finally {
      saving.value = false;
    }
  };
  
  const onDelete = async () => {
    try {
      await deleteCompanyInfo();
      ElMessage.success('删除成功');
      companyInfo.value = {};
      isEditing.value = false;
    } catch (e) {
      ElMessage.error(e.response?.data?.detail || '删除失败');
    }
  };
  
  // 图片上传相关方法
  const beforeLogoUpload = (file) => {
    const isJPG = file.type === 'image/jpeg' || file.type === 'image/png';
    const isLt2M = file.size / 1024 / 1024 < 2;
  
    if (!isJPG) {
      ElMessage.error('上传Logo只能是 JPG/PNG 格式!');
    }
    if (!isLt2M) {
      ElMessage.error('上传Logo大小不能超过 2MB!');
    }
    return isJPG && isLt2M;
  };
  
  const handleLogoSuccess = (response) => {
    form.value.logo_url = getImageUrl(response.url);
    ElMessage.success('Logo上传成功');
  };
  
  const handleLogoError = () => {
    ElMessage.error('Logo上传失败');
  };

  // 公司介绍图片上传相关方法
  const beforeCompanyImageUpload = (file) => {
    const isJPG = file.type === 'image/jpeg' || file.type === 'image/png';
    const isLt2M = file.size / 1024 / 1024 < 2;

    if (!isJPG) {
      ElMessage.error('上传公司介绍图片只能是 JPG/PNG 格式!');
    }
    if (!isLt2M) {
      ElMessage.error('上传公司介绍图片大小不能超过 2MB!');
    }
    return isJPG && isLt2M;
  };

  const handleCompanyImageSuccess = (response) => {
    form.value.company_image = getImageUrl(response.url);
    ElMessage.success('公司图片上传成功');
  };

  const handleCompanyImageError = () => {
    ElMessage.error('公司图片上传失败');
  };

  // 主营业务配图上传相关方法
  const beforeMainPicUpload = (file) => {
    const isJPG = file.type === 'image/jpeg' || file.type === 'image/png';
    const isLt2M = file.size / 1024 / 1024 < 2;

    if (!isJPG) {
      ElMessage.error('上传配图只能是 JPG/PNG 格式!');
    }
    if (!isLt2M) {
      ElMessage.error('上传配图大小不能超过 2MB!');
    }
    return isJPG && isLt2M;
  };

  const handleMainPicSuccess = (response) => {
    form.value.main_pic_url = getImageUrl(response.url);
    ElMessage.success('主图上传成功');
  };

  const handleMainPicError = () => {
    ElMessage.error('配图上传失败');
  };
  
  onMounted(fetchInfo);
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
  
  .logo-upload {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
  }
  
  .view-mode {
    margin-top: 20px;
  }
  </style>