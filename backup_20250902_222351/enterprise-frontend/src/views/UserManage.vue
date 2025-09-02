<template>
  <div>
    <div class="header">
      <h2>用户管理</h2>
      <el-button type="primary" @click="showCreateDialog">新增用户</el-button>
    </div>

    <el-table :data="userList" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="username" label="用户名" width="150" />
      <el-table-column prop="email" label="邮箱" width="200" />
      <el-table-column prop="phone" label="电话" width="150" />
      <el-table-column prop="role" label="角色" width="100">
        <template #default="scope">
          <el-tag :type="getRoleTagType(scope.row.role)">
            {{ getRoleLabel(scope.row.role) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="微信OpenID" width="200">
        <template #default="scope">
          <span v-if="scope.row.wx_openid">{{ scope.row.wx_openid.substring(0, 20) }}...</span>
          <span v-else class="text-gray">-</span>
        </template>
      </el-table-column>
      <el-table-column label="App OpenID" width="200">
        <template #default="scope">
          <span v-if="scope.row.app_openid">{{ scope.row.app_openid.substring(0, 20) }}...</span>
          <span v-else class="text-gray">-</span>
        </template>
      </el-table-column>
      <el-table-column label="头像" width="100">
        <template #default="scope">
          <el-avatar v-if="scope.row.avatar_url" :src="scope.row.avatar_url" size="small" />
          <span v-else class="text-gray">-</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.status ? 'success' : 'danger'">
            {{ scope.row.status ? '启用' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="created_at" label="创建时间" width="180">
        <template #default="scope">
          {{ formatDate(scope.row.created_at) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="280">
        <template #default="scope">
          <el-button size="small" @click="showEditDialog(scope.row)">编辑</el-button>
          <el-button size="small" type="warning" @click="showChangePasswordDialog(scope.row)">修改密码</el-button>
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
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" :disabled="!!form.id" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!form.id">
          <el-input v-model="form.password" type="password" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" />
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="form.phone" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="form.role" placeholder="请选择角色">
            <el-option label="管理员" value="admin" />
            <el-option label="客户" value="customer" />
            <el-option label="微信用户" value="wx_user" />
            <el-option label="App用户" value="app_user" />
          </el-select>
        </el-form-item>
        <el-form-item label="微信OpenID">
          <el-input v-model="form.wx_openid" placeholder="微信小程序OpenID" />
        </el-form-item>
        <el-form-item label="App OpenID">
          <el-input v-model="form.app_openid" placeholder="App端OpenID" />
        </el-form-item>
        <el-form-item label="头像地址">
          <el-input v-model="form.avatar_url" placeholder="头像图片URL" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.status" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSave" :loading="saving">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 修改密码对话框 -->
    <el-dialog 
      title="修改密码" 
      v-model="passwordDialogVisible" 
      width="400px"
      @close="resetPasswordForm"
    >
      <el-form :model="passwordForm" :rules="passwordRules" ref="passwordFormRef" label-width="100px">
        <el-form-item label="用户名">
          <el-input v-model="passwordForm.username" disabled />
        </el-form-item>
        <el-form-item label="新密码" prop="new_password">
          <el-input v-model="passwordForm.new_password" type="password" show-password />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirm_password">
          <el-input v-model="passwordForm.confirm_password" type="password" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="passwordDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleChangePassword" :loading="changingPassword">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getUsers, createUser, updateUser, deleteUser, adminChangePassword } from '../api/user';

const userList = ref([]);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const saving = ref(false);
const passwordDialogVisible = ref(false);
const changingPassword = ref(false);

const form = ref({
  username: '',
  password: '',
  email: '',
  phone: '',
  role: 'customer',
  wx_openid: '',
  app_openid: '',
  avatar_url: '',
  status: true
});

const passwordForm = ref({
  username: '',
  new_password: '',
  confirm_password: ''
});

const formRef = ref();
const passwordFormRef = ref();

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
};

const passwordRules = {
  new_password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  confirm_password: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.value.new_password) {
          callback(new Error('两次输入的密码不一致'));
        } else {
          callback();
        }
      },
      trigger: 'blur'
    }
  ]
};

const fetchData = async () => {
  try {
    const res = await getUsers();
    userList.value = res.data;
  } catch (e) {
    ElMessage.error('获取用户列表失败');
  }
};

const showCreateDialog = () => {
  dialogTitle.value = '新增用户';
  dialogVisible.value = true;
  resetForm();
};

const showEditDialog = (row) => {
  dialogTitle.value = '编辑用户';
  dialogVisible.value = true;
  // 复制数据并转换status为布尔值
  Object.assign(form.value, {
    ...row,
    status: Boolean(row.status)
  });
  // 编辑时不显示密码字段
  delete form.value.password;
};

const resetForm = () => {
  form.value = {
    username: '',
    password: '',
    email: '',
    phone: '',
    role: 'customer',
    wx_openid: '',
    app_openid: '',
    avatar_url: '',
    status: true
  };
  formRef.value?.resetFields();
};

const handleSave = async () => {
  if (!formRef.value) return;
  
  try {
    await formRef.value.validate();
    saving.value = true;
    
    // 准备发送的数据，转换status为数字
    const sendData = {
      ...form.value,
      status: form.value.status ? 1 : 0
    };
    
    if (form.value.id) {
      await updateUser(form.value.id, sendData);
      ElMessage.success('更新成功');
    } else {
      await createUser(sendData);
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
    await ElMessageBox.confirm('确定要删除这个用户吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    
    await deleteUser(row.id);
    ElMessage.success('删除成功');
    await fetchData();
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败');
    }
  }
};

const showChangePasswordDialog = (row) => {
  passwordForm.value.username = row.username;
  passwordForm.value.new_password = '';
  passwordForm.value.confirm_password = '';
  passwordDialogVisible.value = true;
};

const resetPasswordForm = () => {
  passwordForm.value = {
    username: '',
    new_password: '',
    confirm_password: ''
  };
  passwordFormRef.value?.resetFields();
};

const handleChangePassword = async () => {
  if (!passwordFormRef.value) return;
  
  try {
    await passwordFormRef.value.validate();
    changingPassword.value = true;
    
    await adminChangePassword(
      passwordForm.value.username,
      passwordForm.value.new_password
    );
    
    ElMessage.success('密码修改成功');
    passwordDialogVisible.value = false;
  } catch (e) {
    ElMessage.error(e.response?.data?.detail || '密码修改失败');
  } finally {
    changingPassword.value = false;
  }
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleString('zh-CN');
};

const getRoleTagType = (role) => {
  const typeMap = {
    'admin': 'danger',
    'customer': 'info',
    'wx_user': 'success',
    'app_user': 'warning'
  };
  return typeMap[role] || 'info';
};

const getRoleLabel = (role) => {
  const labelMap = {
    'admin': '管理员',
    'customer': '客户',
    'wx_user': '微信用户',
    'app_user': 'App用户'
  };
  return labelMap[role] || '未知';
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