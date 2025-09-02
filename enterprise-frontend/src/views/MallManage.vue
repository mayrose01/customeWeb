<template>
  <div class="mall-manage-page">
    <div class="page-header">
      <h1>商城管理</h1>
      <p>管理商城分类、产品、规格和订单</p>
    </div>

    <div class="mall-tabs">
      <el-tabs v-model="activeTab" type="card">
        <!-- 分类管理 -->
        <el-tab-pane label="分类管理" name="categories">
          <div class="tab-content">
            <div class="action-bar">
              <el-button type="primary" @click="showCategoryDialog('add')">
                <el-icon><Plus /></el-icon>
                新增分类
              </el-button>
            </div>
            
            <el-table :data="categories" v-loading="categoriesLoading" border>
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="name" label="分类名称" />
              <el-table-column prop="description" label="描述" />
              <el-table-column prop="sort_order" label="排序" width="100" />
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="row.status === 'active' ? 'success' : 'info'">
                    {{ row.status === 'active' ? '启用' : '禁用' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="200">
                <template #default="{ row }">
                  <el-button size="small" @click="showCategoryDialog('edit', row)">编辑</el-button>
                  <el-button size="small" type="danger" @click="deleteCategory(row.id)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-tab-pane>

        <!-- 产品管理 -->
        <el-tab-pane label="产品管理" name="products">
          <div class="tab-content">
            <div class="action-bar">
              <el-button type="primary" @click="showProductDialog('add')">
                <el-icon><Plus /></el-icon>
                新增产品
              </el-button>
              <el-select v-model="selectedCategory" placeholder="选择分类" clearable @change="filterProducts">
                <el-option
                  v-for="cat in categories"
                  :key="cat.id"
                  :label="cat.name"
                  :value="cat.id"
                />
              </el-select>
            </div>
            
            <el-table :data="filteredProducts" v-loading="productsLoading" border>
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column label="产品图片" width="100">
                <template #default="{ row }">
                  <el-image
                    v-if="row.images && row.images.length > 0 && getImageUrl(row.images[0])"
                    :src="getImageUrl(row.images[0])"
                    :preview-src-list="getProductImageList(row.images)"
                    fit="cover"
                    style="width: 60px; height: 60px; border-radius: 4px;"
                    @error="handleImageLoadError"
                  />
                  <div v-else class="no-image">
                    <el-icon><Picture /></el-icon>
                    <span>无图片</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="title" label="产品名称" />
              <el-table-column prop="category_name" label="分类" />
              <el-table-column prop="base_price" label="价格" width="100">
                <template #default="{ row }">
                  ¥{{ parseFloat(row.base_price || 0).toFixed(2) }}
                </template>
              </el-table-column>
              <el-table-column prop="stock" label="库存" width="100" />
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="row.status === 'active' ? 'success' : 'info'">
                    {{ row.status === 'active' ? '上架' : '下架' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="250">
                <template #default="{ row }">
                  <el-button size="small" @click="showProductDialog('edit', row)">编辑</el-button>
  
                  <el-button size="small" type="danger" @click="deleteProduct(row.id)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-tab-pane>



        <!-- 订单管理 -->
        <el-tab-pane label="订单管理" name="orders">
          <div class="tab-content">
            <div class="action-bar">
              <el-select v-model="orderStatus" placeholder="订单状态" clearable @change="filterOrders">
                <el-option label="待付款" value="pending" />
                <el-option label="已付款" value="paid" />
                <el-option label="已发货" value="shipped" />
                <el-option label="已完成" value="completed" />
                <el-option label="已取消" value="cancelled" />
              </el-select>
            </div>
            
            <el-table :data="filteredOrders" v-loading="ordersLoading" border>
              <el-table-column prop="id" label="订单号" width="120" />
              <el-table-column prop="user_name" label="用户名" />
              <el-table-column prop="total_amount" label="订单金额" width="120">
                <template #default="{ row }">
                  ¥{{ parseFloat(row.total_amount || 0).toFixed(2) }}
                </template>
              </el-table-column>
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="getOrderStatusType(row.status)">
                    {{ getOrderStatusText(row.status) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="created_at" label="创建时间" width="180" />
              <el-table-column label="操作" width="200">
                <template #default="{ row }">
                  <el-button size="small" @click="viewOrderDetail(row.id)">查看详情</el-button>
                  <el-button 
                    v-if="row.status === 'paid'" 
                    size="small" 
                    type="success"
                    @click="updateOrderStatus(row.id, 'shipped')"
                  >
                    发货
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- 分类对话框 -->
    <el-dialog 
      v-model="categoryDialogVisible" 
      :title="categoryDialogType === 'add' ? '新增分类' : '编辑分类'"
      width="500px"
    >
      <el-form :model="categoryForm" :rules="categoryRules" ref="categoryFormRef" label-width="80px">
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="categoryForm.name" placeholder="请输入分类名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="categoryForm.description" type="textarea" placeholder="请输入分类描述" />
        </el-form-item>
        <el-form-item label="排序" prop="sort_order">
          <el-input-number v-model="categoryForm.sort_order" :min="0" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="categoryForm.status">
            <el-option label="启用" value="active" />
            <el-option label="禁用" value="inactive" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="categoryDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveCategory">确定</el-button>
      </template>
    </el-dialog>

    <!-- 产品对话框 -->
    <el-dialog 
      v-model="productDialogVisible" 
      :title="productDialogType === 'add' ? '新增产品' : '编辑产品'"
      width="1000px"
    >
      <el-form :model="productForm" :rules="productRules" ref="productFormRef" label-width="100px">
        <el-form-item label="产品名称" prop="title">
          <el-input v-model="productForm.title" placeholder="请输入产品名称" />
        </el-form-item>
        <el-form-item label="产品分类" prop="category_id">
          <el-select v-model="productForm.category_id" placeholder="请选择分类">
            <el-option
              v-for="cat in categories"
              :key="cat.id"
              :label="cat.name"
              :value="cat.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="基础价格" prop="base_price">
          <el-input-number v-model="productForm.base_price" :min="0" :precision="2" />
          <span style="margin-left: 10px; color: #909399; font-size: 12px;">基础价格，规格价格会在此基础上调整</span>
        </el-form-item>
        <el-form-item label="基础库存" prop="stock">
          <el-input-number v-model="productForm.stock" :min="0" />
          <span style="margin-left: 10px; color: #909399; font-size: 12px;">基础库存，规格库存会在此基础上调整</span>
        </el-form-item>
        <el-form-item label="产品描述" prop="description">
          <el-input v-model="productForm.description" type="textarea" :rows="4" placeholder="请输入产品描述" />
        </el-form-item>
        
        <!-- 规格管理 -->
        <el-form-item label="产品规格">
          <div style="border: 1px solid #dcdfe6; border-radius: 4px; padding: 15px; background-color: #fafafa;">
            <div style="margin-bottom: 15px;">
              <el-button type="primary" size="small" @click="addSpecificationGroup">
                <el-icon><Plus /></el-icon>
                添加规格组
              </el-button>
              <span style="margin-left: 10px; color: #909399; font-size: 12px;">例如：颜色、尺寸、型号等</span>
            </div>
            
            <!-- 规格组列表 -->
            <div v-for="(specGroup, groupIndex) in productForm.specifications" :key="groupIndex" style="margin-bottom: 20px; padding: 15px; border: 1px solid #e4e7ed; border-radius: 4px; background-color: white;">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                <el-input 
                  v-model="specGroup.name" 
                  placeholder="规格名称，如：颜色" 
                  style="width: 200px;"
                  @blur="updateSpecificationCombinations"
                />
                <el-button type="danger" size="small" @click="removeSpecificationGroup(groupIndex)">
                  <el-icon><Delete /></el-icon>
                  删除规格组
                </el-button>
              </div>
              
              <!-- 规格值列表 -->
              <div style="margin-bottom: 10px;">
                <el-tag
                  v-for="(value, valueIndex) in specGroup.values"
                  :key="`${groupIndex}-${valueIndex}-${value || 'unknown'}`"
                  closable
                  @close="removeProductSpecificationValue(groupIndex, valueIndex)"
                  style="margin-right: 10px; margin-bottom: 10px;"
                >
                  {{ value || '未知' }}
                </el-tag>
                <el-input
                  v-if="specGroup.inputVisible"
                  v-model="specGroup.inputValue"
                  class="input-new-tag spec-input"
                  size="small"
                  style="width: 120px;"
                  @keyup.enter="addProductSpecificationValue(groupIndex)"
                  @blur="addProductSpecificationValue(groupIndex)"
                />
                <el-button v-else class="button-new-tag" size="small" @click="showSpecificationInput(groupIndex)">
                  + 添加规格值
                </el-button>
              </div>
            </div>
            
            <!-- 规格组合表格 -->
            <div v-if="productForm.specifications.length > 0 && productForm.specificationCombinations.length > 0" style="margin-top: 20px;">
              <h4 style="margin-bottom: 15px; color: #303133;">规格组合管理</h4>
              <el-table :data="productForm.specificationCombinations" border size="small">
                <el-table-column label="规格组合" min-width="200">
                  <template #default="{ row, $index }">
                    <el-tag v-for="(spec, specIndex) in row.specs" :key="`${$index}-${specIndex}-${spec.name || 'unknown'}`" style="margin-right: 5px;">
                      {{ spec.name || '未知' }}: {{ spec.value || '未知' }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="价格调整" width="150">
                  <template #default="{ row }">
                    <el-input-number 
                      v-model="row.price_adjustment" 
                      :min="-9999" 
                      :max="9999" 
                      :precision="2"
                      size="small"
                    />
                  </template>
                </el-table-column>
                <el-table-column label="库存调整" width="150">
                  <template #default="{ row }">
                    <el-input-number 
                      v-model="row.stock_adjustment" 
                      :min="-9999" 
                      :max="9999"
                      size="small"
                    />
                  </template>
                </el-table-column>
                <el-table-column label="最终价格" width="120">
                  <template #default="{ row }">
                    <span style="color: #e6a23c; font-weight: bold;">
                      ¥{{ (productForm.base_price + (row.price_adjustment || 0)).toFixed(2) }}
                    </span>
                  </template>
                </el-table-column>
                <el-table-column label="最终库存" width="120">
                  <template #default="{ row }">
                    <span style="color: #67c23a; font-weight: bold;">
                      {{ productForm.stock + (row.stock_adjustment || 0) }}
                    </span>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </div>
        </el-form-item>
        
        <el-form-item label="产品图片" prop="images">
          <!-- 图片上传组件 -->
          <el-upload
            ref="uploadRef"
            :action="uploadUrl"
            list-type="picture-card"
            :on-success="handleImageSuccess"
            :on-remove="handleImageRemove"
            :on-error="handleImageError"
            :before-upload="beforeImageUpload"
            :show-file-list="false"
            :limit="5"
            accept="image/*"
            :on-preview="handlePictureCardPreview"
            :headers="uploadHeaders"
            :auto-upload="true"
            :multiple="true"
            :on-change="handleImageChange"
          >
            <el-icon><Plus /></el-icon>
          </el-upload>
          
          <!-- 显示所有图片（包括新上传的） -->
          <div v-if="productForm.images && productForm.images.length > 0" style="margin-top: 15px;">
            <div style="display: flex; flex-wrap: wrap; gap: 10px;">
              <div 
                v-for="(img, index) in productForm.images" 
                :key="`img-${index}-${img.uid || 'unknown'}`"
                style="position: relative; width: 148px; height: 148px; border: 1px solid #d9d9d9; border-radius: 6px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"
              >
                <img 
                  :src="getImageUrl(typeof img === 'string' ? img : img.url || img.response?.url || '')" 
                  style="width: 100%; height: 100%; object-fit: cover;"
                  @error="handleImageLoadError"
                />
                <el-button 
                  type="danger" 
                  size="small" 
                  circle 
                  style="position: absolute; top: 8px; right: 8px; background-color: #f56c6c; border-color: #f56c6c; box-shadow: 0 2px 4px rgba(0,0,0,0.2); color: white; font-size: 16px; font-weight: bold; line-height: 1;"
                  @click="removeExistingImage(index)"
                >
                  ×
                </el-button>
              </div>
            </div>
          </div>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="productForm.status">
            <el-option label="上架" value="active" />
            <el-option label="下架" value="inactive" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="cancelProductDialog">取消</el-button>
        <el-button type="primary" @click="saveProduct">确定</el-button>
      </template>
    </el-dialog>

    <!-- 图片预览弹窗 -->
    <el-dialog v-model="imagePreviewVisible" title="图片预览" width="600px">
      <div style="text-align: center;">
        <img 
          v-if="previewImageUrl" 
          :src="previewImageUrl" 
          style="max-width: 100%; max-height: 400px; object-fit: contain;"
          alt="预览图片"
        />
      </div>
    </el-dialog>


  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Close, Delete, Picture } from '@element-plus/icons-vue'
import { getImageUrl } from '@/utils/imageUtils'
import { getUploadUrl } from '@/utils/config'
import { 
  getMallCategories, 
  createMallCategory, 
  updateMallCategory, 
  deleteMallCategory 
} from '@/api/mall_category'
import { 
  getMallProducts, 
  createMallProduct, 
  updateMallProduct, 
  deleteMallProduct,
  getMallProductSpecifications,
  createMallProductSpecification,
  updateMallProductSpecification,
  deleteMallProductSpecification,
  getMallProductSkus,
  createMallProductSku,
  updateMallProductSku,
  deleteMallProductSku
} from '@/api/mall_product'
import { 
  getMallOrders, 
  updateMallOrderStatus, 
  updateMallOrderShipping 
} from '@/api/mall_order'

export default {
  name: 'MallManage',
  components: {
    Plus,
    Delete
  },
  setup() {
    // 当前激活的标签页
    const activeTab = ref('categories')
    
    // 数据加载状态
    const categoriesLoading = ref(false)
    const productsLoading = ref(false)
    const ordersLoading = ref(false)
    
    // 上传URL配置 - 根据当前环境动态获取
    const uploadUrl = computed(() => {
      // 开发环境直接使用后端地址
      if (window.location.hostname === 'localhost' && window.location.port === '3000') {
        return 'http://localhost:8000/api/upload'
      }
      return getUploadUrl()
    })

    // 上传头部配置
    const uploadHeaders = computed(() => {
      const token = localStorage.getItem('token')
      return token ? { Authorization: `Bearer ${token}` } : {}
    })
    
    // 数据列表
    const categories = ref([])
    const products = ref([])
    const orders = ref([])
    
    // 筛选条件
    const selectedCategory = ref('')
    const orderStatus = ref('')
    
    // 对话框状态
    const categoryDialogVisible = ref(false)
    const categoryDialogType = ref('add')
    const productDialogVisible = ref(false)
    const productDialogType = ref('add')
    
    // 表单数据
    const categoryForm = reactive({
      name: '',
      description: '',
      sort_order: 0,
      status: 'active'
    })
    
    const productForm = reactive({
      title: '',
      category_id: '',
      base_price: 0,
      stock: 0,
      description: '',
      images: [],
      status: 'active',
      specifications: [], // 新增规格组
      specificationCombinations: [] // 新增规格组合
    })
    

    


    // 图片预览相关
    const imagePreviewVisible = ref(false)
    const previewImageUrl = ref('')
    
    // 表单引用
    const categoryFormRef = ref()
    const productFormRef = ref()
    const uploadRef = ref()
    
    // 表单验证规则
    const categoryRules = {
      name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }]
    }
    
    const productRules = {
      title: [{ required: true, message: '请输入产品名称', trigger: 'blur' }],
      category_id: [{ required: true, message: '请选择产品分类', trigger: 'change' }],
      base_price: [{ required: true, message: '请输入产品价格', trigger: 'blur' }],
      stock: [{ required: true, message: '请输入库存数量', trigger: 'blur' }]
    }
    

    
    // 计算属性
    const filteredProducts = computed(() => {
      if (!selectedCategory.value) return products.value
      return products.value.filter(p => p.category_id === selectedCategory.value)
    })
    
    const filteredOrders = computed(() => {
      if (!orderStatus.value) return orders.value
      return orders.value.filter(o => o.status === orderStatus.value)
    })
    
    // 加载产品规格数据
    const loadProductSpecifications = async (productId) => {
      try {
        // 首先尝试从产品列表中获取规格数据
        const productFromList = products.value.find(p => p.id === productId)
        if (productFromList && productFromList.specifications && productFromList.specifications.length > 0) {
          console.log('从产品列表获取规格数据:', productFromList.specifications)
          
          // 将规格数据转换为前端需要的格式
          const specs = productFromList.specifications
            .filter(spec => spec && spec.name && typeof spec.name === 'string' && spec.name.trim() !== '')
            .map(spec => ({
              id: spec.id || (Date.now() + Math.random() + 10000), // 临时ID从10000开始，避免与数据库ID冲突
              name: spec.name.trim(),
              values: Array.isArray(spec.values) ? spec.values.filter(v => v && typeof v === 'string' && v.trim() !== '').map(v => v.trim()) : [],
              inputVisible: false,
              inputValue: ''
            }))
            .filter(spec => spec.values.length > 0) // 只保留有值的规格
          
          productForm.specifications = specs
          
          // 如果有规格组合数据，也加载进来
          if (productFromList.specificationCombinations && productFromList.specificationCombinations.length > 0) {
            productForm.specificationCombinations = productFromList.specificationCombinations.map(comb => ({
              ...comb,
              price_adjustment: comb.price_adjustment || 0,
              stock_adjustment: comb.stock_adjustment || 0
            }))
          } else {
            // 生成默认的规格组合
            updateSpecificationCombinations()
          }
          
          return // 如果从列表获取到数据，就不需要调用API了
        }
        
        // 如果产品列表中没有规格数据，则调用API获取
        console.log('从API获取产品规格数据')
        const response = await getMallProductSpecifications(productId)
        
        // 先尝试从SKU数据中重建规格组
        try {
          const skuResponse = await getMallProductSkus(productId)
          if (skuResponse.data && skuResponse.data.length > 0) {
            console.log('从SKU数据重建规格组:', skuResponse.data)
            
            // 从SKU数据中提取所有唯一的规格名称和值
            const specMap = new Map() // 使用Map来去重和收集规格值
            
            skuResponse.data.forEach(sku => {
              if (sku.specifications && typeof sku.specifications === 'object') {
                Object.entries(sku.specifications).forEach(([name, value]) => {
                  if (name && value && typeof name === 'string' && typeof value === 'string' && 
                      name.trim() !== '' && value.trim() !== '') {
                    const specName = name.trim()
                    if (!specMap.has(specName)) {
                      specMap.set(specName, new Set())
                    }
                    specMap.get(specName).add(value.trim())
                  }
                })
              }
            })
            
            // 将Map转换为前端需要的规格格式
            const specs = Array.from(specMap.entries()).map(([name, valuesSet]) => ({
              id: Date.now() + Math.random() + 10000, // 临时ID
              name: name,
              values: Array.from(valuesSet),
              inputVisible: false,
              inputValue: ''
            }))
            
            productForm.specifications = specs
            console.log('从SKU重建的规格组:', specs)
            
            // 将SKU数据转换为规格组合格式
            const combinations = skuResponse.data
              .filter(sku => sku && sku.specifications && typeof sku.specifications === 'object')
              .map(sku => {
                const specs = []
                if (sku.specifications) {
                  Object.entries(sku.specifications).forEach(([name, value]) => {
                    if (name && value && typeof name === 'string' && typeof value === 'string' && 
                        name.trim() !== '' && value.trim() !== '') {
                      specs.push({ 
                        name: name.trim(), 
                        value: value.trim() 
                      })
                    }
                  })
                }
                
                return {
                  specs: specs.filter(spec => spec.name && spec.value),
                  price_adjustment: (sku.price - productForm.base_price) || 0,
                  stock_adjustment: (sku.stock - productForm.stock) || 0
                }
              })
              .filter(comb => comb.specs.length > 0)
            
            productForm.specificationCombinations = combinations
            console.log('从SKU重建的规格组合:', combinations)
            
          } else {
            // 如果没有SKU数据，尝试使用规格API的数据
            if (response.data && response.data.length > 0) {
              const specs = response.data
                .filter(spec => spec && spec.name && typeof spec.name === 'string' && spec.name.trim() !== '')
                .map(spec => ({
                  id: spec.id || (Date.now() + Math.random() + 10000),
                  name: spec.name.trim(),
                  values: spec.values ? spec.values
                    .filter(v => v && v.value && typeof v.value === 'string' && v.value.trim() !== '')
                    .map(v => v.value.trim()) : [],
                  inputVisible: false,
                  inputValue: ''
                }))
                .filter(spec => spec.values.length > 0)
              
              productForm.specifications = specs
              updateSpecificationCombinations()
            } else {
              productForm.specifications = []
              productForm.specificationCombinations = []
            }
          }
        } catch (skuError) {
          console.error('加载产品SKU失败:', skuError)
          // 如果SKU加载失败，回退到规格API
          if (response.data && response.data.length > 0) {
            const specs = response.data
              .filter(spec => spec && spec.name && typeof spec.name === 'string' && spec.name.trim() !== '')
              .map(spec => ({
                id: spec.id || (Date.now() + Math.random() + 10000),
                name: spec.name.trim(),
                values: spec.values ? spec.values
                  .filter(v => v && v.value && typeof v.value === 'string' && v.value.trim() !== '')
                  .map(v => v.value.trim()) : [],
                inputVisible: false,
                inputValue: ''
              }))
              .filter(spec => spec.values.length > 0)
            
            productForm.specifications = specs
            updateSpecificationCombinations()
          } else {
            productForm.specifications = []
            productForm.specificationCombinations = []
          }
        }
      } catch (error) {
        console.error('加载产品规格失败:', error)
        // 如果API失败，使用空数组
        productForm.specifications = []
        productForm.specificationCombinations = []
      }
    }

    // 加载数据
    const loadCategories = async () => {
      try {
        categoriesLoading.value = true
        const response = await getMallCategories()
        console.log('分类API响应:', response)
        
        if (response.data) {
          categories.value = response.data
        } else {
          categories.value = []
        }
        
        console.log('处理后的分类数据:', categories.value)
      } catch (error) {
        console.error('加载分类失败:', error)
        ElMessage.error('加载分类失败')
        // 如果API失败，使用模拟数据
        categories.value = [
          { id: 1, name: '电子产品', description: '手机、电脑、配件等', sort_order: 1, status: 'active' },
          { id: 2, name: '服装鞋帽', description: '男装、女装、童装等', sort_order: 2, status: 'active' },
          { id: 3, name: '家居用品', description: '家具、装饰、厨具等', sort_order: 3, status: 'active' },
          { id: 4, name: '美妆护肤', description: '护肤品、彩妆、香水等', sort_order: 4, status: 'active' },
          { id: 5, name: '运动户外', description: '运动装备、户外用品等', sort_order: 5, status: 'active' }
        ]
      } finally {
        categoriesLoading.value = false
      }
    }
    
    const loadProducts = async () => {
      try {
        productsLoading.value = true
        const response = await getMallProducts()
        console.log('产品API响应:', response)
        
        if (response.data && response.data.items) {
          // 处理分页响应
          products.value = response.data.items.map(item => ({
            ...item,
            category_name: item.category?.name || '未分类',
            price: item.base_price, // 兼容旧字段
            images: item.images || []
          }))
        } else if (Array.isArray(response.data)) {
          // 处理数组响应
          products.value = response.data.map(item => ({
            ...item,
            category_name: item.category?.name || '未分类',
            price: item.base_price, // 兼容旧字段
            images: item.images || []
          }))
        } else {
          products.value = []
        }
        
        console.log('处理后的产品数据:', products.value)
      } catch (error) {
        console.error('加载产品失败:', error)
        ElMessage.error('加载产品失败')
        // 如果API失败，使用模拟数据
        products.value = [
          { id: 1, title: '智能手机', category_name: '电子产品', base_price: 2999, price: 2999, stock: 50, status: 'active', images: [] },
          { id: 2, title: '无线耳机', category_name: '电子产品', base_price: 299, price: 299, stock: 100, status: 'active', images: [] },
          { id: 3, title: '智能手表', category_name: '电子产品', base_price: 899, price: 899, stock: 30, status: 'active', images: [] },
          { id: 4, title: '男士休闲鞋', category_name: '服装鞋帽', base_price: 299, price: 299, stock: 80, status: 'active', images: [] },
          { id: 5, title: '女士连衣裙', category_name: '服装鞋帽', base_price: 199, price: 199, stock: 60, status: 'active', images: [] },
          { id: 6, title: '厨房刀具套装', category_name: '家居用品', base_price: 399, price: 399, stock: 25, status: 'active', images: [] },
          { id: 7, title: '护肤精华液', category_name: '美妆护肤', base_price: 299, price: 299, stock: 40, status: 'active', images: [] }
        ]
      } finally {
        productsLoading.value = false
      }
    }
    

    
    const loadOrders = async () => {
      try {
        ordersLoading.value = true
        const response = await getMallOrders()
        console.log('订单API响应:', response)
        
        if (response.data && response.data.items) {
          // 处理分页响应
          orders.value = response.data.items.map(item => ({
            ...item,
            order_number: item.order_no || item.order_number,
            customer_name: item.user?.username || item.customer_name || '未知用户',
            total_amount: item.total_amount || 0
          }))
        } else if (Array.isArray(response.data)) {
          // 处理数组响应
          orders.value = response.data.map(item => ({
            ...item,
            order_number: item.order_no || item.order_number,
            customer_name: item.user?.username || item.customer_name || '未知用户',
            total_amount: item.total_amount || 0
          }))
        } else {
          orders.value = []
        }
        
        console.log('处理后的订单数据:', orders.value)
      } catch (error) {
        console.error('加载订单失败:', error)
        ElMessage.error('加载订单失败')
        // 如果API失败，使用模拟数据
        orders.value = [
          { id: 1, order_number: 'M202409020001', customer_name: '张三', total_amount: 3297, status: 'pending', created_at: '2024-09-02 10:00:00' },
          { id: 2, order_number: 'M202409010001', customer_name: '李四', total_amount: 899, status: 'shipped', created_at: '2024-09-01 15:30:00' },
          { id: 3, order_number: 'M202408310001', customer_name: '王五', total_amount: 1598, status: 'completed', created_at: '2024-08-31 09:15:00' }
        ]
      } finally {
        ordersLoading.value = false
      }
    }
    
    // 分类管理
    const showCategoryDialog = (type, data = {}) => {
      categoryDialogType.value = type
      if (type === 'edit') {
        Object.assign(categoryForm, data)
      } else {
        Object.assign(categoryForm, {
          name: '',
          description: '',
          sort_order: 0,
          status: 'active'
        })
      }
      categoryDialogVisible.value = true
    }
    
    const saveCategory = async () => {
      try {
        await categoryFormRef.value.validate()
        if (categoryDialogType.value === 'add') {
          await createMallCategory(categoryForm)
        } else {
          await updateMallCategory(categoryForm.id, categoryForm)
        }
        ElMessage.success('保存成功')
        categoryDialogVisible.value = false
        loadCategories()
      } catch (error) {
        console.error('保存分类失败:', error)
        ElMessage.error('保存失败')
      }
    }
    
    const deleteCategory = async (id) => {
      try {
        await ElMessageBox.confirm('确定要删除这个分类吗？', '提示', {
          type: 'warning'
        })
        await deleteMallCategory(id)
        ElMessage.success('删除成功')
        loadCategories()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除分类失败:', error)
          ElMessage.error('删除失败')
        }
      }
    }
    
    // 产品管理
    const showProductDialog = (type, data = {}) => {
      productDialogType.value = type
      
      // 重置表单
      Object.assign(productForm, {
        title: '',
        category_id: '',
        base_price: 0,
        stock: 0,
        description: '',
        images: [],
        status: 'active',
        specifications: [], // 新增规格组
        specificationCombinations: [] // 新增规格组合
      })
      
      if (type === 'edit') {
        // 编辑模式：确保images是数组格式，并转换为el-upload期望的格式
        const editData = { ...data }
        console.log('编辑产品数据:', editData)
        
        if (editData.images && Array.isArray(editData.images)) {
          // 将字符串URL转换为图片对象格式
          editData.images = editData.images.map((img, index) => {
            if (typeof img === 'string') {
              // 如果是字符串URL，转换为图片对象
              const imageObj = {
                name: `image_${index + 1}.jpg`,
                url: img,
                uid: Date.now() + index,
                status: 'success',
                response: { url: img, filename: `image_${index + 1}.jpg` }
              }
              console.log('转换后的图片对象:', imageObj)
              return imageObj
            }
            // 如果已经是对象，确保有必要的字段
            const imageObj = {
              name: img.name || `image_${index + 1}.jpg`,
              url: img.url || img.response?.url || '',
              uid: img.uid || Date.now() + index,
              status: img.status || 'success',
              response: img.response || { 
                url: img.url || img.response?.url || '',
                filename: img.name || `image_${index + 1}.jpg`
              }
            }
            console.log('处理后的图片对象:', imageObj)
            return imageObj
          })
        } else {
          editData.images = []
        }
        
        // 处理规格数据
        if (editData.specifications && Array.isArray(editData.specifications)) {
          editData.specifications = editData.specifications.map(group => ({
            ...group,
            values: group.values || [],
            inputVisible: false,
            inputValue: ''
          }))
        } else {
          editData.specifications = []
        }

        if (editData.specificationCombinations && Array.isArray(editData.specificationCombinations)) {
          editData.specificationCombinations = editData.specificationCombinations.map(comb => ({
            ...comb,
            price_adjustment: comb.price_adjustment || 0,
            stock_adjustment: comb.stock_adjustment || 0
          }))
        } else {
          editData.specificationCombinations = []
        }
        
        console.log('最终的产品表单数据:', editData)
        Object.assign(productForm, editData)
        
        // 在编辑模式下，加载产品的完整规格数据
        if (editData.id) {
          // 延迟加载规格数据，确保产品基本信息先显示
          setTimeout(() => {
            loadProductSpecifications(editData.id)
          }, 100)
        }
      }
      
      // 调试：检查对话框打开后的图片数据
      nextTick(() => {
        console.log('对话框打开后的productForm.images:', productForm.images)
        console.log('图片预览列表:', getImagePreviewList())
      })
      
      productDialogVisible.value = true
    }
    
    const saveProduct = async () => {
      try {
        await productFormRef.value.validate()
        
        // 处理图片数据，只保留URL字符串
        const productData = { ...productForm }
        if (productData.images && Array.isArray(productData.images)) {
          productData.images = productData.images.map(img => {
            // 如果是字符串，直接返回
            if (typeof img === 'string') return img
            // 如果是文件对象，提取URL
            if (img.response && img.response.url) return img.response.url
            // 如果是其他格式，尝试提取url字段
            if (img.url) return img.url
            // 如果都没有，返回空字符串
            return ''
          }).filter(url => url && url !== '') // 过滤掉空值
          
          console.log('保存时的图片数据:', productData.images)
        }
        
        // 处理规格数据
        if (productData.specifications && Array.isArray(productData.specifications)) {
          productData.specifications = productData.specifications.map(group => ({
            ...group,
            values: group.values || [],
            inputVisible: false,
            inputValue: ''
          }))
        } else {
          productData.specifications = []
        }

        if (productData.specificationCombinations && Array.isArray(productData.specificationCombinations)) {
          productData.specificationCombinations = productData.specificationCombinations.map(comb => ({
            ...comb,
            price_adjustment: comb.price_adjustment || 0,
            stock_adjustment: comb.stock_adjustment || 0
          }))
        } else {
          productData.specificationCombinations = []
        }
        
        let savedProduct
        if (productDialogType.value === 'add') {
          savedProduct = await createMallProduct(productData)
        } else {
          savedProduct = await updateMallProduct(productData.id, productData)
        }
        
        // 保存规格数据
        if (savedProduct && productForm.specifications && productForm.specifications.length > 0) {
          try {
            const productId = (savedProduct.data && typeof savedProduct.data === 'object' && savedProduct.data.id) || productData.id
            
            // 先删除所有旧的SKU数据，因为规格可能已经改变
            try {
              const existingSkus = await getMallProductSkus(productId)
              if (existingSkus.data && existingSkus.data.length > 0) {
                for (const sku of existingSkus.data) {
                  try {
                    await deleteMallProductSku(sku.id)
                    console.log(`删除旧SKU: ${sku.id}`)
                  } catch (deleteSkuError) {
                    console.log(`删除SKU失败: ${deleteSkuError.message}`)
                  }
                }
              }
            } catch (skuError) {
              console.log('获取现有SKU失败:', skuError.message)
            }
            
            // 保存规格组
            for (const spec of productForm.specifications) {
              if (spec.name && spec.values && spec.values.length > 0) {
                const specData = {
                  product_id: productId,
                  name: spec.name,
                  sort_order: 0
                }
                
                let savedSpec
                // 检查规格ID是否有效（数据库ID通常小于1000）
                if (spec.id && typeof spec.id === 'number' && spec.id > 0 && spec.id < 1000) {
                  // 如果是有效的数据库ID，更新现有规格
                  try {
                    savedSpec = await updateMallProductSpecification(spec.id, specData)
                  } catch (updateError) {
                    console.log(`更新规格失败，尝试创建新规格: ${updateError.message}`)
                    // 如果更新失败，创建新规格
                    savedSpec = await createMallProductSpecification(specData)
                  }
                } else {
                  // 如果是临时ID或无效ID，创建新的规格
                  savedSpec = await createMallProductSpecification(specData)
                }
                
                // 保存规格值
                if (savedSpec && savedSpec.data && savedSpec.data.id) {
                  const specId = savedSpec.data.id
                  
                  // 先删除旧的规格值
                  try {
                    // TODO: 实现删除规格值API
                    // await deleteMallProductSpecificationValues(specId)
                    console.log('删除旧规格值功能待实现')
                  } catch (deleteError) {
                    console.log('删除旧规格值失败:', deleteError.message)
                  }
                  
                  // 保存新的规格值
                  for (const value of spec.values) {
                    if (value && typeof value === 'string' && value.trim()) {
                      try {
                        const valueData = {
                          specification_id: specId,
                          value: value.trim(),
                          sort_order: 0
                        }
                        // TODO: 实现创建规格值API
                        // await createMallProductSpecificationValue(valueData)
                        console.log('创建规格值功能待实现:', valueData)
                      } catch (valueError) {
                        console.error('创建规格值失败:', valueError)
                      }
                    }
                  }
                }
              }
            }
            
            // 创建新的SKU数据
            if (productForm.specificationCombinations && productForm.specificationCombinations.length > 0) {
              for (const comb of productForm.specificationCombinations) {
                if (comb.specs && comb.specs.length > 0) {
                  try {
                    // 确保所有必要字段都存在且有效
                    if (!productId || !comb.specs || comb.specs.length === 0) {
                      console.warn('跳过无效的SKU数据:', { productId, specs: comb.specs })
                      continue
                    }
                    
                    const skuData = {
                      product_id: productId,
                      sku_code: `${productData.title}_${comb.specs.map(s => s.value).join('_')}`,
                      price: parseFloat((productForm.base_price + (comb.price_adjustment || 0)).toFixed(2)),
                      stock: parseInt(productForm.stock + (comb.stock_adjustment || 0)),
                      weight: 0.0, // 添加默认重量字段
                      specifications: comb.specs.reduce((acc, spec) => {
                        if (spec.name && spec.value && typeof spec.name === 'string' && typeof spec.value === 'string') {
                          acc[spec.name.trim()] = spec.value.trim()
                        }
                        return acc
                      }, {})
                    }
                    
                    // 验证SKU数据的完整性
                    if (!skuData.sku_code || !skuData.price || skuData.price <= 0) {
                      console.warn('SKU数据验证失败:', skuData)
                      continue
                    }
                    
                    console.log('创建SKU数据:', skuData)
                    const skuResponse = await createMallProductSku(skuData)
                    console.log('SKU创建成功:', skuResponse)
                  } catch (skuError) {
                    console.error('创建SKU失败:', skuError)
                    // 如果SKU创建失败，记录错误但不中断整个保存流程
                    if (skuError.response) {
                      console.error('SKU创建错误响应:', skuError.response.data)
                      ElMessage.warning(`SKU创建失败: ${skuError.response.data?.detail || skuError.message || '未知错误'}`)
                    } else {
                      ElMessage.warning(`SKU创建失败: ${skuError.message || '未知错误'}`)
                    }
                  }
                }
              }
            }
            
            console.log('规格数据和SKU数据保存成功')
          } catch (specError) {
            console.error('保存规格数据失败:', specError)
            ElMessage.warning('产品保存成功，但规格数据保存失败')
          }
        }
        
        ElMessage.success('保存成功')
        productDialogVisible.value = false
        
        // 更新产品列表中的对应产品，保留规格信息
        if (productDialogType.value === 'edit' && savedProduct) {
          const index = products.value.findIndex(p => p.id === productData.id)
          if (index !== -1) {
            // 更新产品信息，保留规格数据
            const updatedProduct = {
              ...products.value[index],
              specifications: productForm.specifications,
              specificationCombinations: productForm.specificationCombinations
            }
            
            // 只有当savedProduct.data是对象时才展开
            if (savedProduct.data && typeof savedProduct.data === 'object' && !Array.isArray(savedProduct.data)) {
              Object.assign(updatedProduct, savedProduct.data)
            }
            
            products.value[index] = updatedProduct
          }
        } else {
          // 新增产品或更新失败，重新加载整个列表
          loadProducts()
        }
      } catch (error) {
        console.error('保存产品失败:', error)
        ElMessage.error('保存失败')
      }
    }
    
    const deleteProduct = async (id) => {
      try {
        await ElMessageBox.confirm('确定要删除这个产品吗？', '提示', {
          type: 'warning'
        })
        await deleteMallProduct(id)
        ElMessage.success('删除成功')
        loadProducts()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除产品失败:', error)
          ElMessage.error('删除失败')
        }
      }
    }
    
    const manageSpecifications = (productId) => {
      // 查找产品并显示规格管理对话框
      const product = products.value.find(p => p.id === productId)
      if (product) {
        // 将产品数据复制到表单中
        Object.assign(productForm, {
          id: product.id, // 添加产品ID
          title: product.title,
          category_id: product.category_id,
          base_price: product.base_price || 0,
          stock: product.stock || 0,
          description: product.description || '',
          images: product.images || [],
          status: product.status || 'active',
          specifications: product.specifications || [],
          specificationCombinations: product.specificationCombinations || []
        })
        
        // 显示产品对话框
        productDialogType.value = 'edit'
        productDialogVisible.value = true
        
        // 加载产品的规格数据
        loadProductSpecifications(productId)
      }
    }
    

    


    // 新增规格组
    const addSpecificationGroup = () => {
      productForm.specifications.push({
        name: '',
        values: [],
        inputVisible: false,
        inputValue: ''
      })
      updateSpecificationCombinations() // 添加新组后更新组合
    }

    // 移除规格组
    const removeSpecificationGroup = (index) => {
      productForm.specifications.splice(index, 1)
      updateSpecificationCombinations() // 移除组后更新组合
    }

    // 显示规格值输入框
    const showSpecificationInput = (groupIndex) => {
      productForm.specifications[groupIndex].inputVisible = true
      nextTick(() => {
        // 注意：这里需要等待DOM更新后再聚焦
        setTimeout(() => {
          const inputs = document.querySelectorAll('.spec-input')
          if (inputs[groupIndex]) {
            inputs[groupIndex].focus()
          }
        }, 100)
      })
    }

    // 添加规格值（产品规格）
    const addProductSpecificationValue = (groupIndex) => {
      const group = productForm.specifications[groupIndex]
      if (group.inputValue.trim()) {
        group.values.push(group.inputValue.trim())
        group.inputValue = ''
        group.inputVisible = false
        updateSpecificationCombinations() // 添加值后更新组合
      }
    }

    // 移除规格值（产品规格）
    const removeProductSpecificationValue = (groupIndex, valueIndex) => {
      productForm.specifications[groupIndex].values.splice(valueIndex, 1)
      updateSpecificationCombinations() // 移除值后更新组合
    }

    // 更新规格组合
    const updateSpecificationCombinations = () => {
      // 过滤掉没有值的规格组
      const validSpecs = productForm.specifications.filter(group => group.name && group.values.length > 0)
      
      if (validSpecs.length === 0) {
        productForm.specificationCombinations = []
        return
      }

      // 生成所有可能的组合
      const combinations = []
      
      const generateCombinations = (currentCombination, currentIndex) => {
        if (currentIndex === validSpecs.length) {
          if (currentCombination.length > 0) {
            // 确保每个规格对象都有有效的name和value
            const validCombination = currentCombination.filter(spec => 
              spec && spec.name && spec.value && 
              typeof spec.name === 'string' && 
              typeof spec.value === 'string' &&
              spec.name.trim() !== '' && 
              spec.value.trim() !== ''
            )
            
            if (validCombination.length > 0) {
              combinations.push({
                specs: validCombination,
                price_adjustment: 0, // 默认价格调整
                stock_adjustment: 0 // 默认库存调整
              })
            }
          }
          return
        }

        const currentSpec = validSpecs[currentIndex]
        if (currentSpec.values && Array.isArray(currentSpec.values)) {
          for (const value of currentSpec.values) {
            if (value && typeof value === 'string' && value.trim() !== '') {
              generateCombinations([...currentCombination, { 
                name: currentSpec.name || '未知规格', 
                value: value.trim() 
              }], currentIndex + 1)
            }
          }
        }
      }
      
      generateCombinations([], 0)

      // 保存现有的价格和库存调整值
      const existingCombinations = productForm.specificationCombinations || []
      const existingValues = {}
      
      existingCombinations.forEach(comb => {
        const key = comb.specs.map(spec => `${spec.name}:${spec.value}`).sort().join('|')
        existingValues[key] = {
          price_adjustment: comb.price_adjustment || 0,
          stock_adjustment: comb.stock_adjustment || 0
        }
      })

      // 根据规格组合生成最终的规格组合列表，保留现有的价格和库存调整值
      productForm.specificationCombinations = combinations.map(comb => {
        const key = comb.specs.map(spec => `${spec.name}:${spec.value}`).sort().join('|')
        const existingValue = existingValues[key] || { price_adjustment: 0, stock_adjustment: 0 }
        
        return {
          ...comb,
          price_adjustment: existingValue.price_adjustment,
          stock_adjustment: existingValue.stock_adjustment
        }
      })
    }
    
    // 订单管理
    const getOrderStatusType = (status) => {
      const statusMap = {
        pending: 'warning',
        paid: 'primary',
        shipped: 'success',
        completed: 'success',
        cancelled: 'info'
      }
      return statusMap[status] || 'info'
    }
    
    const getOrderStatusText = (status) => {
      const statusMap = {
        pending: '待付款',
        paid: '已付款',
        shipped: '已发货',
        completed: '已完成',
        cancelled: '已取消'
      }
      return statusMap[status] || '未知'
    }
    
    const viewOrderDetail = (orderId) => {
      // TODO: 跳转到订单详情页面
      console.log('查看订单详情:', orderId)
    }
    
    const updateOrderStatus = async (orderId, status) => {
      try {
        await updateMallOrderStatus(orderId, status)
        ElMessage.success('状态更新成功')
        loadOrders()
      } catch (error) {
        console.error('更新订单状态失败:', error)
        ElMessage.error('状态更新失败')
      }
    }
    
    // 图片上传前检查
    const beforeImageUpload = (file) => {
      const isImage = file.type.startsWith('image/')
      const isLt2M = file.size / 1024 / 1024 < 2

      if (!isImage) {
        ElMessage.error('只能上传图片文件!')
        return false
      }
      if (!isLt2M) {
        ElMessage.error('图片大小不能超过 2MB!')
        return false
      }
      return true
    }

    // 移除现有图片
    const removeExistingImage = (index) => {
      if (productForm.images && Array.isArray(productForm.images)) {
        productForm.images.splice(index, 1)
        ElMessage.success('图片移除成功')
      }
    }

    // 图片变化处理
    const handleImageChange = (file, fileList) => {
      console.log('图片变化:', file)
      console.log('文件列表:', fileList)
      console.log('当前productForm.images:', productForm.images)
      // 不在这里操作数据，让el-upload组件自己管理
    }

    // 取消产品对话框
    const cancelProductDialog = () => {
      productDialogVisible.value = false
      // 重置表单数据
      Object.assign(productForm, {
        id: null,
        title: '',
        category_id: '',
        base_price: 0,
        stock: 0,
        description: '',
        images: [],
        status: 'active',
        specifications: [],
        specificationCombinations: []
      })
    }
    
    // 图片上传成功处理
    const handleImageSuccess = (response, file) => {
      console.log('图片上传成功:', response)
      console.log('文件对象:', file)
      
      if (response && response.url) {
        // 确保productForm.images是数组
        if (!Array.isArray(productForm.images)) {
          productForm.images = []
        }
        
        // 检查是否已存在相同URL的图片
        const exists = productForm.images.some(img => {
          const imgUrl = typeof img === 'string' ? img : (img.url || img.response?.url)
          return imgUrl === response.url
        })
        
        if (!exists) {
          // 添加新上传的图片
          const newImage = {
            name: response.filename || file.name,
            url: response.url,
            uid: file.uid || Date.now(),
            status: 'success',
            response: { 
              url: response.url,
              filename: response.filename || file.name
            }
          }
          productForm.images.push(newImage)
          console.log('添加新图片:', newImage)
          console.log('更新后的productForm.images:', productForm.images)
        } else {
          console.log('图片已存在，跳过重复添加')
        }
        
        ElMessage.success('图片上传成功')
      } else {
        console.error('图片上传响应格式错误:', response)
        ElMessage.error('图片上传失败：响应格式错误')
      }
    }
    
    // 图片移除处理
    const handleImageRemove = (file) => {
      console.log('图片移除:', file)
      
      // 从productForm.images中移除对应的图片
      const index = productForm.images.findIndex(img => {
        if (typeof img === 'string' && typeof file === 'string') {
          return img === file
        }
        if (typeof img === 'object' && typeof file === 'object') {
          return img.uid === file.uid
        }
        if (typeof img === 'string' && typeof file === 'object') {
          return img === (file.url || file.response?.url)
        }
        if (typeof img === 'object' && typeof file === 'string') {
          return (img.url || img.response?.url) === file
        }
        return false
      })
      
      if (index > -1) {
        productForm.images.splice(index, 1)
        console.log('移除图片，索引:', index)
        console.log('移除后的productForm.images:', productForm.images)
        ElMessage.success('图片移除成功')
      } else {
        console.log('未找到要移除的图片')
      }
    }
    
    // 获取产品图片列表（用于产品列表显示）- 简化逻辑
    const getProductImageList = (images) => {
      if (!images || !Array.isArray(images)) return []
      return images.map(img => {
        const imgUrl = typeof img === 'string' ? img : (img.url || img.response?.url)
        return getImageUrl(imgUrl)
      }).filter(url => url && url !== '')
    }

    // 获取图片预览列表 - 简化逻辑
    const getImagePreviewList = () => {
      if (!productForm.images || !Array.isArray(productForm.images)) return []
      
      return productForm.images.map(img => {
        const imgUrl = typeof img === 'string' ? img : (img.url || img.response?.url)
        return getImageUrl(imgUrl)
      }).filter(url => url && url !== '')
    }

    // 图片加载错误处理（用于img标签的@error事件）
    const handleImageLoadError = (event) => {
      console.log('图片加载失败:', event.target.src)
      // 不显示错误消息，静默处理
    }

    // 图片上传错误处理（用于el-upload的on-error事件）
    const handleImageError = (error, file, fileList) => {
      console.error('图片上传失败:', error)
      console.error('失败的文件:', file)
      console.error('文件列表:', fileList)
      
      // 显示错误消息
      ElMessage.error('图片上传失败，请重试')
      
      // 从文件列表中移除失败的文件
      if (file && fileList) {
        const index = fileList.findIndex(f => f.uid === file.uid)
        if (index > -1) {
          fileList.splice(index, 1)
        }
      }
    }
    
    // 筛选
    const filterProducts = () => {
      // 产品筛选逻辑已在计算属性中处理
    }

    // 获取完整的图片URL - 简化逻辑
    const getImageUrl = (url) => {
      if (!url) return ''
      if (url.startsWith('http')) return url
      
      // 如果是相对路径，添加基础URL
      if (url.startsWith('/uploads/')) {
        if (window.location.hostname === 'localhost' && window.location.port === '3000') {
          return `http://localhost:8000${url}`
        }
        return `${window.location.origin}${url}`
      }
      
      // 如果是文件名，拼接uploads路径
      if (url && !url.startsWith('/') && !url.startsWith('http')) {
        if (window.location.hostname === 'localhost' && window.location.port === '3000') {
          return `http://localhost:8000/uploads/${url}`
        }
        return `${window.location.origin}/uploads/${url}`
      }
      
      return url
    }

    // 图片预览处理
    const handlePictureCardPreview = (file) => {
      console.log('预览图片:', file)
      // 获取图片URL
      let imageUrl = ''
      if (typeof file === 'string') {
        imageUrl = file
      } else if (file.url) {
        imageUrl = file.url
      } else if (file.response && file.response.url) {
        imageUrl = file.response.url
      }
      
      if (imageUrl) {
        previewImageUrl.value = getImageUrl(imageUrl)
        imagePreviewVisible.value = true
      }
    }
    
    const filterOrders = () => {
      // 订单筛选逻辑已在计算属性中处理
    }
    
    onMounted(() => {
      loadCategories()
      loadProducts()
      loadOrders()
    })
    
    return {
      // 状态
      activeTab,
      categoriesLoading,
      productsLoading,
      ordersLoading,
      
      // 数据
      categories,
      products,
      orders,
      
      // 筛选
      selectedCategory,
      orderStatus,
      filteredProducts,
      filteredOrders,
      
      // 对话框
      categoryDialogVisible,
      categoryDialogType,
      productDialogVisible,
      productDialogType,
      imagePreviewVisible,
      previewImageUrl,
      
      // 表单
      categoryForm,
      productForm,
      categoryFormRef,
      productFormRef,
      

      
      // 验证规则
      categoryRules,
      productRules,
      
      // 方法
      loadCategories,
      loadProducts,
      loadOrders,
      showCategoryDialog,
      saveCategory,
      deleteCategory,
      showProductDialog,
      saveProduct,
      deleteProduct,
      cancelProductDialog,
      manageSpecifications,
      addSpecificationGroup,
      removeSpecificationGroup,
      showSpecificationInput,
      addProductSpecificationValue,
      removeProductSpecificationValue,
      updateSpecificationCombinations,
      loadProductSpecifications,

      getOrderStatusType,
      getOrderStatusText,
      viewOrderDetail,
      updateOrderStatus,
      handleImageSuccess,
      handleImageRemove,
      handleImageError,
      handleImageLoadError,
      handleImageChange,
      removeExistingImage,
      filterProducts,
      filterOrders,
      getImageUrl,
      uploadUrl,
      beforeImageUpload,
      getImagePreviewList,
      getProductImageList,
      handlePictureCardPreview,
      uploadHeaders,
      uploadRef
    }
  }
}
</script>

<style scoped>
.mall-manage-page {
  padding: 20px;
}

.no-image {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
  border: 1px dashed #d9d9d9;
  border-radius: 4px;
  background-color: #fafafa;
  color: #999;
  font-size: 12px;
}

.no-image .el-icon {
  font-size: 20px;
  margin-bottom: 4px;
}

.page-header {
  margin-bottom: 30px;
}

.page-header h1 {
  font-size: 2rem;
  color: var(--color-text-primary);
  margin-bottom: 10px;
}

.page-header p {
  color: var(--color-text-secondary);
  font-size: 1rem;
}

.mall-tabs {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.tab-content {
  padding: 20px;
}

.action-bar {
  margin-bottom: 20px;
  display: flex;
  gap: 15px;
  align-items: center;
}

.no-image {
  width: 60px;
  height: 60px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  color: #999;
  font-size: 12px;
}

.input-new-tag {
  width: 90px;
  margin-left: 10px;
  vertical-align: bottom;
}

.button-new-tag {
  margin-left: 10px;
  height: 32px;
  line-height: 30px;
  padding-top: 0;
  padding-bottom: 0;
}
</style>
