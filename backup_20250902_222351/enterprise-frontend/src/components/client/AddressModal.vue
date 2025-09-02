<template>
  <el-dialog
    :title="address ? '编辑地址' : '新增地址'"
    v-model="dialogVisible"
    width="600px"
    @close="handleClose"
    :close-on-click-modal="false"
  >
    <el-form
      ref="addressFormRef"
      :model="addressForm"
      :rules="addressRules"
      label-width="100px"
    >
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="收货人" prop="contact_name">
            <el-input
              v-model="addressForm.contact_name"
              placeholder="请输入收货人姓名"
              maxlength="20"
              show-word-limit
            />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="联系电话" prop="phone">
            <el-input
              v-model="addressForm.phone"
              placeholder="请输入联系电话"
              maxlength="11"
            />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="省份" prop="province">
            <el-select
              v-model="addressForm.province"
              placeholder="请选择省份"
              @change="handleProvinceChange"
              style="width: 100%"
            >
              <el-option
                v-for="province in provinces"
                :key="province.code"
                :label="province.name"
                :value="province.name"
              />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="城市" prop="city">
            <el-select
              v-model="addressForm.city"
              placeholder="请选择城市"
              @change="handleCityChange"
              style="width: 100%"
              :disabled="!addressForm.province"
            >
              <el-option
                v-for="city in cities"
                :key="city.code"
                :label="city.name"
                :value="city.name"
              />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="区县" prop="district">
            <el-select
              v-model="addressForm.district"
              placeholder="请选择区县"
              style="width: 100%"
              :disabled="!addressForm.city"
            >
              <el-option
                v-for="district in districts"
                :key="district.code"
                :label="district.name"
                :value="district.name"
              />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="详细地址" prop="detail_address">
        <el-input
          v-model="addressForm.detail_address"
          type="textarea"
          :rows="3"
          placeholder="请输入详细地址，如街道、门牌号等"
          maxlength="100"
          show-word-limit
        />
      </el-form-item>

      <el-form-item label="设为默认">
        <el-switch v-model="addressForm.is_default" />
      </el-form-item>
    </el-form>

    <template #footer>
      <div class="dialog-footer">
        <el-button @click="handleClose">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">
          {{ address ? '更新' : '新增' }}
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script>
import { ref, reactive, watch, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { createAddress, updateAddress } from '@/api/address'
import { userStore } from '@/store/user'

export default {
  name: 'AddressModal',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    address: {
      type: Object,
      default: null
    }
  },
  emits: ['close', 'success'],
  setup(props, { emit }) {

    const addressFormRef = ref()
    const submitting = ref(false)
    const dialogVisible = ref(false)

    // 地址表单数据
    const addressForm = reactive({
      contact_name: '',
      phone: '',
      province: '',
      city: '',
      district: '',
      detail_address: '',
      is_default: false
    })

    // 表单验证规则
    const addressRules = {
      contact_name: [
        { required: true, message: '请输入收货人姓名', trigger: 'blur' },
        { min: 2, max: 20, message: '姓名长度在 2 到 20 个字符', trigger: 'blur' }
      ],
      phone: [
        { required: true, message: '请输入联系电话', trigger: 'blur' },
        { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
      ],
      province: [
        { required: true, message: '请选择省份', trigger: 'change' }
      ],
      city: [
        { required: true, message: '请选择城市', trigger: 'change' }
      ],
      district: [
        { required: true, message: '请选择区县', trigger: 'change' }
      ],
      detail_address: [
        { required: true, message: '请输入详细地址', trigger: 'blur' },
        { min: 5, max: 100, message: '详细地址长度在 5 到 100 个字符', trigger: 'blur' }
      ]
    }

    // 省市区数据（简化版，实际项目中应该从API获取）
    const provinces = ref([
      { code: '110000', name: '北京市' },
      { code: '120000', name: '天津市' },
      { code: '130000', name: '河北省' },
      { code: '140000', name: '山西省' },
      { code: '150000', name: '内蒙古自治区' },
      { code: '210000', name: '辽宁省' },
      { code: '220000', name: '吉林省' },
      { code: '230000', name: '黑龙江省' },
      { code: '310000', name: '上海市' },
      { code: '320000', name: '江苏省' },
      { code: '330000', name: '浙江省' },
      { code: '340000', name: '安徽省' },
      { code: '350000', name: '福建省' },
      { code: '360000', name: '江西省' },
      { code: '370000', name: '山东省' },
      { code: '410000', name: '河南省' },
      { code: '420000', name: '湖北省' },
      { code: '430000', name: '湖南省' },
      { code: '440000', name: '广东省' },
      { code: '450000', name: '广西壮族自治区' },
      { code: '460000', name: '海南省' },
      { code: '500000', name: '重庆市' },
      { code: '510000', name: '四川省' },
      { code: '520000', name: '贵州省' },
      { code: '530000', name: '云南省' },
      { code: '540000', name: '西藏自治区' },
      { code: '610000', name: '陕西省' },
      { code: '620000', name: '甘肃省' },
      { code: '630000', name: '青海省' },
      { code: '640000', name: '宁夏回族自治区' },
      { code: '650000', name: '新疆维吾尔自治区' }
    ])

    const cities = ref([])
    const districts = ref([])

    // 监听省份变化
    const handleProvinceChange = () => {
      addressForm.city = ''
      addressForm.district = ''
      cities.value = []
      districts.value = []
      
      if (addressForm.province) {
        // 根据省份加载城市数据（简化版）
        loadCities(addressForm.province)
      }
    }

    // 监听城市变化
    const handleCityChange = () => {
      addressForm.district = ''
      districts.value = []
      
      if (addressForm.city) {
        // 根据城市加载区县数据（简化版）
        loadDistricts(addressForm.city)
      }
    }

    // 加载城市数据（简化版）
    const loadCities = (provinceName) => {
      // 这里应该根据省份从API获取城市数据
      // 暂时使用模拟数据
      if (provinceName === '北京市') {
        cities.value = [
          { code: '110100', name: '北京市' }
        ]
      } else if (provinceName === '上海市') {
        cities.value = [
          { code: '310100', name: '上海市' }
        ]
      } else if (provinceName === '广东省') {
        cities.value = [
          { code: '440100', name: '广州市' },
          { code: '440300', name: '深圳市' },
          { code: '440600', name: '佛山市' },
          { code: '441900', name: '东莞市' }
        ]
      } else {
        // 其他省份的模拟数据
        cities.value = [
          { code: '000001', name: '省会城市' },
          { code: '000002', name: '地级市1' },
          { code: '000003', name: '地级市2' }
        ]
      }
    }

    // 加载区县数据（简化版）
    const loadDistricts = (cityName) => {
      // 这里应该根据城市从API获取区县数据
      // 暂时使用模拟数据
      if (cityName === '广州市') {
        districts.value = [
          { code: '440103', name: '荔湾区' },
          { code: '440104', name: '越秀区' },
          { code: '440105', name: '海珠区' },
          { code: '440106', name: '天河区' },
          { code: '440111', name: '白云区' },
          { code: '440112', name: '黄埔区' },
          { code: '440113', name: '番禺区' },
          { code: '440114', name: '花都区' },
          { code: '440115', name: '南沙区' },
          { code: '440117', name: '从化区' },
          { code: '440118', name: '增城区' }
        ]
      } else if (cityName === '深圳市') {
        districts.value = [
          { code: '440303', name: '罗湖区' },
          { code: '440304', name: '福田区' },
          { code: '440305', name: '南山区' },
          { code: '440306', name: '宝安区' },
          { code: '440307', name: '龙岗区' },
          { code: '440308', name: '盐田区' },
          { code: '440309', name: '龙华区' },
          { code: '440310', name: '坪山区' },
          { code: '440311', name: '光明区' }
        ]
      } else {
        // 其他城市的模拟数据
        districts.value = [
          { code: '000001', name: '区县1' },
          { code: '000002', name: '区县2' },
          { code: '000003', name: '区县3' }
        ]
      }
    }

    // 初始化表单数据
    const initForm = () => {
      if (props.address) {
        // 编辑模式
        Object.assign(addressForm, {
          contact_name: props.address.contact_name || '',
          phone: props.address.phone || '',
          province: props.address.province || '',
          city: props.address.city || '',
          district: props.address.district || '',
          detail_address: props.address.detail_address || '',
          is_default: props.address.is_default || false
        })
        
        // 加载城市和区县数据
        if (addressForm.province) {
          loadCities(addressForm.province)
        }
        if (addressForm.city) {
          loadDistricts(addressForm.city)
        }
      } else {
        // 新增模式
        Object.assign(addressForm, {
          contact_name: '',
          phone: '',
          province: '',
          city: '',
          district: '',
          detail_address: '',
          is_default: false
        })
        cities.value = []
        districts.value = []
      }
    }

    // 提交表单
    const handleSubmit = async () => {
      try {
        await addressFormRef.value.validate()
        
        submitting.value = true
        
        const addressData = {
          user_id: userStore.userInfo?.id,
          contact_name: addressForm.contact_name,
          phone: addressForm.phone,
          province: addressForm.province,
          city: addressForm.city,
          district: addressForm.district,
          detail_address: addressForm.detail_address,
          is_default: addressForm.is_default
        }
        
        if (props.address) {
          // 更新地址
          await updateAddress(props.address.id, addressData)
          ElMessage.success('地址更新成功')
        } else {
          // 新增地址
          await createAddress(addressData)
          ElMessage.success('地址新增成功')
        }
        
        emit('success')
        
      } catch (error) {
        if (error !== false) { // 不是表单验证错误
          console.error('保存地址失败:', error)
          ElMessage.error('保存地址失败，请重试')
        }
      } finally {
        submitting.value = false
      }
    }

    // 关闭弹窗
    const handleClose = () => {
      dialogVisible.value = false
      emit('close')
    }

    // 监听visible变化，初始化表单
    watch(() => props.visible, (newVal) => {
      dialogVisible.value = !!newVal
      if (newVal) {
        nextTick(() => {
          initForm()
        })
      }
    })

    // 监听对话框关闭（v-model 改变）
    watch(dialogVisible, (val) => {
      if (!val && props.visible) {
        emit('close')
      }
    })

    return {
      addressFormRef,
      addressForm,
      addressRules,
      submitting,
      dialogVisible,
      provinces,
      cities,
      districts,
      handleProvinceChange,
      handleCityChange,
      handleSubmit,
      handleClose
    }
  }
}
</script>

<style scoped>
.dialog-footer {
  text-align: right;
}

.el-form-item {
  margin-bottom: 20px;
}

.el-select {
  width: 100%;
}

.el-textarea {
  width: 100%;
}
</style> 