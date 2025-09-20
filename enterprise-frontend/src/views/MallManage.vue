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
              <el-table-column label="分类图片" width="120">
                <template #default="{ row }">
                  <el-image
                    v-if="row.image && getImageUrl(row.image)"
                    :src="getImageUrl(row.image)"
                    :preview-src-list="[getImageUrl(row.image)]"
                    fit="cover"
                    style="width: 80px; height: 60px; border-radius: 4px;"
                    @error="handleImageLoadError"
                  />
                  <div v-else class="no-image">
                    <el-icon><Picture /></el-icon>
                    <span>无图片</span>
                  </div>
                </template>
              </el-table-column>
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
              <el-table-column prop="title" label="产品名称" min-width="200">
                <template #default="{ row }">
                  <el-button 
                    type="primary" 
                    link 
                    @click="viewProductDetail(row.id)"
                    style="padding: 0; text-align: left;"
                  >
                    {{ row.title }}
                  </el-button>
                </template>
              </el-table-column>
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
              <el-table-column label="操作" width="350">
                <template #default="{ row }">
                  <el-button size="small" @click="showProductDialog('edit', row)">编辑</el-button>
                  <el-button size="small" type="success" @click="copyProduct(row.id)">复制</el-button>
                  <el-button 
                    size="small" 
                    :type="row.status === 'active' ? 'warning' : 'success'"
                    @click="toggleProductStatus(row.id, row.status)"
                  >
                    {{ row.status === 'active' ? '下架' : '上架' }}
                  </el-button>
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
              <el-table-column prop="user_name" label="用户名" width="120" />
              <el-table-column label="商品图片" width="100">
                <template #default="{ row }">
                  <el-image
                    v-if="getOrderFirstProductImage(row)"
                    :src="getOrderFirstProductImage(row)"
                    :preview-src-list="getOrderProductImages(row)"
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
              <el-table-column label="商品名称" min-width="200">
                <template #default="{ row }">
                  <div v-if="getOrderFirstProductName(row)">
                    <el-button 
                      type="primary" 
                      link 
                      @click="viewProductDetail(getOrderFirstProductId(row))"
                      style="padding: 0; text-align: left;"
                    >
                      {{ getOrderFirstProductName(row) }}
                    </el-button>
                    <div v-if="getOrderProductCount(row) > 1" class="more-products">
                      等{{ getOrderProductCount(row) }}件商品
                    </div>
                  </div>
                  <span v-else>无商品信息</span>
                </template>
              </el-table-column>
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
        <el-form-item label="分类图片" prop="image">
          <div style="margin-bottom: 10px; color: #909399; font-size: 12px;">
            建议上传 16:9 比例的图片，最佳尺寸为 400x225 像素
          </div>
          <el-upload
            ref="categoryUploadRef"
            :action="uploadUrl"
            :on-success="handleCategoryImageSuccess"
            :on-remove="handleCategoryImageRemove"
            :on-error="handleImageError"
            :before-upload="beforeImageUpload"
            :show-file-list="false"
            :limit="1"
            accept="image/*"
            :headers="uploadHeaders"
            :auto-upload="true"
            class="category-upload"
          >
            <div v-if="categoryForm.image" class="category-image-preview">
              <img :src="getImageUrl(categoryForm.image)" alt="分类图片预览" />
              <div class="image-overlay">
                <el-button type="primary" size="small" icon="Edit">更换图片</el-button>
              </div>
            </div>
            <div v-else class="category-upload-placeholder">
              <el-icon><Plus /></el-icon>
              <div>上传分类图片</div>
            </div>
          </el-upload>
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
                <el-table-column label="SKU价格" width="150">
                  <template #default="{ row }">
                    <el-input-number 
                      v-model="row.price" 
                      :min="0" 
                      :max="99999" 
                      :precision="2"
                      size="small"
                    />
                  </template>
                </el-table-column>
                <el-table-column label="SKU库存" width="150">
                  <template #default="{ row }">
                    <el-input-number 
                      v-model="row.stock" 
                      :min="0" 
                      :max="99999"
                      size="small"
                    />
                  </template>
                </el-table-column>
                <el-table-column label="SKU编码" width="200">
                  <template #default="{ row }">
                    <el-input 
                      v-model="row.sku_code" 
                      size="small"
                      placeholder="自动生成"
                    />
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
        
        <!-- 产品描述 - 富文本编辑器 -->
        <el-form-item label="产品描述" prop="description">
          <div style="border: 1px solid #dcdfe6; border-radius: 4px; min-height: 400px; background: white; width: 100%;">
            <Toolbar
              v-if="editorRef"
              style="border-bottom: 1px solid #ccc"
              :editor="editorRef"
              :defaultConfig="toolbarConfig"
              mode="default"
            />
            <Editor
              v-model="productForm.description"
              :defaultConfig="editorConfig"
              style="height: 400px; overflow-y: hidden; width: 100%;"
              @onCreated="handleEditorCreated"
              @onChange="handleEditorChange"
              mode="default"
            />
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

    <!-- 订单详情对话框 -->
    <el-dialog 
      v-model="orderDetailVisible" 
      title="订单详情" 
      width="1000px"
      :close-on-click-modal="false"
    >
      <div v-if="currentOrderDetail" class="order-detail">
        <!-- 订单基本信息 -->
        <div class="order-info-section">
          <h3>订单信息</h3>
          <el-row :gutter="20">
            <el-col :span="12">
              <div class="info-item">
                <label>订单号：</label>
                <span>{{ currentOrderDetail.order_no }}</span>
              </div>
              <div class="info-item">
                <label>订单状态：</label>
                <el-tag :type="getOrderStatusType(currentOrderDetail.status)">
                  {{ getOrderStatusText(currentOrderDetail.status) }}
                </el-tag>
              </div>
              <div class="info-item">
                <label>支付状态：</label>
                <el-tag :type="currentOrderDetail.payment_status === 'paid' ? 'success' : 'warning'">
                  {{ currentOrderDetail.payment_status === 'paid' ? '已支付' : '未支付' }}
                </el-tag>
              </div>
            </el-col>
            <el-col :span="12">
              <div class="info-item">
                <label>下单时间：</label>
                <span>{{ formatDateTime(currentOrderDetail.created_at) }}</span>
              </div>
              <div class="info-item">
                <label>支付时间：</label>
                <span>{{ currentOrderDetail.payment_time ? formatDateTime(currentOrderDetail.payment_time) : '未支付' }}</span>
              </div>
              <div class="info-item">
                <label>订单总金额：</label>
                <span class="total-amount">¥{{ parseFloat(currentOrderDetail.total_amount || 0).toFixed(2) }}</span>
              </div>
            </el-col>
          </el-row>
        </div>

        <!-- 收货信息 -->
        <div class="order-info-section" v-if="currentOrderDetail.shipping_address">
          <h3>收货信息</h3>
          <div class="shipping-info">
            <div class="info-item" v-if="parsedShippingInfo.name">
              <label>收货人：</label>
              <span>{{ parsedShippingInfo.name }}</span>
            </div>
            <div class="info-item" v-if="parsedShippingInfo.phone">
              <label>手机号：</label>
              <span>{{ parsedShippingInfo.phone }}</span>
            </div>
            <div class="info-item" v-if="parsedShippingInfo.address">
              <label>收货地址：</label>
              <span>{{ parsedShippingInfo.address }}</span>
            </div>
            <div class="info-item" v-if="currentOrderDetail.shipping_company">
              <label>快递公司：</label>
              <span>{{ currentOrderDetail.shipping_company }}</span>
            </div>
            <div class="info-item" v-if="currentOrderDetail.tracking_number">
              <label>快递单号：</label>
              <span>{{ currentOrderDetail.tracking_number }}</span>
            </div>
            <div class="info-item" v-if="currentOrderDetail.shipping_time">
              <label>发货时间：</label>
              <span>{{ formatDateTime(currentOrderDetail.shipping_time) }}</span>
            </div>
          </div>
        </div>

        <!-- 商品信息 -->
        <div class="order-info-section">
          <h3>商品信息</h3>
          <el-table :data="currentOrderDetail.items" border>
            <el-table-column label="商品图片" width="100">
              <template #default="{ row }">
                <el-image
                  v-if="row.product && row.product.images && row.product.images.length > 0"
                  :src="getImageUrl(row.product.images[0])"
                  :preview-src-list="getProductImageList(row.product.images)"
                  fit="cover"
                  style="width: 60px; height: 60px; border-radius: 4px;"
                />
                <div v-else class="no-image">
                  <el-icon><Picture /></el-icon>
                  <span>无图片</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="product_name" label="商品名称" />
            <el-table-column label="规格信息" width="200">
              <template #default="{ row }">
                <div v-if="row.sku_specifications && Object.keys(row.sku_specifications).length > 0">
                  <el-tag 
                    v-for="(value, key) in row.sku_specifications" 
                    :key="key" 
                    size="small" 
                    style="margin-right: 5px; margin-bottom: 5px;"
                  >
                    {{ key }}: {{ value }}
                  </el-tag>
                </div>
                <span v-else>无规格</span>
              </template>
            </el-table-column>
            <el-table-column prop="price" label="单价" width="100">
              <template #default="{ row }">
                ¥{{ parseFloat(row.price || 0).toFixed(2) }}
              </template>
            </el-table-column>
            <el-table-column prop="quantity" label="数量" width="80" />
            <el-table-column prop="subtotal" label="小计" width="100">
              <template #default="{ row }">
                ¥{{ parseFloat(row.subtotal || 0).toFixed(2) }}
              </template>
            </el-table-column>
          </el-table>
        </div>

        <!-- 订单备注 -->
        <div class="order-info-section" v-if="currentOrderDetail.remark">
          <h3>订单备注</h3>
          <div class="remark-content">
            {{ currentOrderDetail.remark }}
          </div>
        </div>
      </div>
      
      <template #footer>
        <el-button @click="orderDetailVisible = false">关闭</el-button>
        <el-button 
          v-if="currentOrderDetail && currentOrderDetail.status === 'paid'" 
          type="success"
          @click="updateOrderStatus(currentOrderDetail.id, 'shipped')"
        >
          发货
        </el-button>
      </template>
    </el-dialog>

    <!-- 商品详情对话框 -->
    <el-dialog 
      v-model="productDetailVisible" 
      title="商品详情" 
      width="1200px"
      :close-on-click-modal="false"
    >
      <div v-if="currentProductDetail" class="product-detail">
        <div class="product-detail-content">
          <!-- 商品图片区域 -->
          <div class="product-gallery">
            <div class="main-image">
              <img 
                v-if="currentProductDetail.images && currentProductDetail.images.length > 0" 
                :src="getImageUrl(currentProductDetail.images[currentProductImageIndex])" 
                :alt="currentProductDetail.title"
                @error="handleImageLoadError"
              />
              <div v-else class="image-placeholder">
                <span>📦</span>
                <p>暂无图片</p>
              </div>
            </div>
            <div class="image-thumbnails" v-if="currentProductDetail.images && currentProductDetail.images.length > 1">
              <div 
                v-for="(image, index) in currentProductDetail.images" 
                :key="index"
                class="thumbnail"
                :class="{ active: currentProductImageIndex === index }"
                @click="setCurrentProductImage(index)"
              >
                <img 
                  v-if="image && image.trim()"
                  :src="getImageUrl(image)" 
                  :alt="`${currentProductDetail.title} - 图片 ${index + 1}`"
                  @error="handleImageLoadError"
                />
                <div v-else class="thumbnail-placeholder">
                  <span>📦</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 商品信息区域 -->
          <div class="product-info">
            <div class="product-header">
              <h1 class="product-title">{{ currentProductDetail.title }}</h1>
              <p class="product-model" v-if="currentProductDetail.model">型号: {{ currentProductDetail.model }}</p>
            </div>

            <div class="product-price-section">
              <div class="current-price">¥{{ parseFloat(currentProductDetail.base_price || 0).toFixed(2) }}</div>
            </div>

            <!-- 商品规格 -->
            <div class="product-specs" v-if="currentProductDetail.specifications && currentProductDetail.specifications.length > 0">
              <h3>商品规格</h3>
              <div class="specs-list">
                <div 
                  v-for="spec in currentProductDetail.specifications" 
                  :key="spec.id"
                  class="spec-item"
                  v-if="spec && spec.values && spec.values.length > 0"
                >
                  <div class="spec-label">{{ spec.name }}:</div>
                  <div class="spec-values">
                    <el-tag 
                      v-for="value in spec.values" 
                      :key="value.id || value"
                      size="small"
                      style="margin-right: 8px; margin-bottom: 8px;"
                    >
                      {{ typeof value === 'string' ? value : value.value }}
                    </el-tag>
                  </div>
                </div>
              </div>
            </div>

            <!-- 商品描述 -->
            <div class="product-description" v-if="currentProductDetail.description">
              <h3>商品描述</h3>
              <div class="description-content" v-html="currentProductDetail.description"></div>
            </div>

            <!-- 商品基本信息 -->
            <div class="product-basic-info">
              <h3>基本信息</h3>
              <div class="info-grid">
                <div class="info-item">
                  <label>商品ID：</label>
                  <span>{{ currentProductDetail.id }}</span>
                </div>
                <div class="info-item">
                  <label>分类：</label>
                  <span>{{ currentProductDetail.category?.name || '未分类' }}</span>
                </div>
                <div class="info-item">
                  <label>基础价格：</label>
                  <span>¥{{ parseFloat(currentProductDetail.base_price || 0).toFixed(2) }}</span>
                </div>
                <div class="info-item">
                  <label>库存：</label>
                  <span>{{ currentProductDetail.stock || 0 }}</span>
                </div>
                <div class="info-item">
                  <label>状态：</label>
                  <el-tag :type="currentProductDetail.status === 'active' ? 'success' : 'info'">
                    {{ currentProductDetail.status === 'active' ? '上架' : '下架' }}
                  </el-tag>
                </div>
                <div class="info-item">
                  <label>创建时间：</label>
                  <span>{{ formatDateTime(currentProductDetail.created_at) }}</span>
                </div>
                <div class="info-item">
                  <label>更新时间：</label>
                  <span>{{ formatDateTime(currentProductDetail.updated_at) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <template #footer>
        <el-button @click="productDetailVisible = false">关闭</el-button>
        <el-button type="primary" @click="editProduct(currentProductDetail)">编辑商品</el-button>
      </template>
    </el-dialog>

  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Close, Delete, Picture } from '@element-plus/icons-vue'
import { getImageUrl } from '@/utils/imageUtils'
import { getUploadUrl } from '@/utils/config'
import { Editor, Toolbar } from '@wangeditor/editor-for-vue'
import '@wangeditor/editor/dist/css/style.css'
import { 
  getMallCategories, 
  createMallCategory, 
  updateMallCategory, 
  deleteMallCategory 
} from '@/api/mall_category'
import { 
  getMallProducts, 
  getMallProduct,
  createMallProduct, 
  updateMallProduct, 
  deleteMallProduct,
  copyMallProduct,
  updateMallProductStatus,
  getMallProductSpecifications,
  createMallProductSpecification,
  updateMallProductSpecification,
  deleteMallProductSpecification,
  createMallProductSpecificationValue,
  updateMallProductSpecificationValue,
  deleteMallProductSpecificationValue,
  deleteMallProductSpecificationValues,
  getMallProductSkus,
  createMallProductSku,
  updateMallProductSku,
  deleteMallProductSku
} from '@/api/mall_product'
import { 
  getMallOrders, 
  updateMallOrderStatus, 
  updateMallOrderShipping,
  getOrderDetail
} from '@/api/mall_order'

export default {
  name: 'MallManage',
  components: {
    Plus,
    Close,
    Delete,
    Picture,
    Editor,
    Toolbar
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
    const orderDetailVisible = ref(false)
    const currentOrderDetail = ref(null)
    const productDetailVisible = ref(false)
    const currentProductDetail = ref(null)
    const currentProductImageIndex = ref(0)
    
    // 表单数据
    const categoryForm = reactive({
      name: '',
      description: '',
      image: '',
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
    
    // 富文本编辑器相关
    const editorRef = ref()
    const mode = 'default'
    
    // 工具栏配置（包含图片上传）
    const toolbarConfig = {
      excludeKeys: [
        'uploadVideo',
        'codeBlock',
        'fullScreen'
      ]
    }
    
    const editorConfig = ref({
      placeholder: '请输入产品描述...',
      readOnly: false,
      autoFocus: false,
      scroll: true,
      MENU_CONF: {
        // 配置上传图片
        uploadImage: {
          server: uploadUrl.value,
          fieldName: 'file',
          headers: uploadHeaders.value,
          // 处理后端返回的图片URL
          customInsert(res, insertFn) {
            const fullUrl = getImageUrl(res.url)
            insertFn(fullUrl, '', '')
          },
          // 允许上传多张图片
          maxFileSize: 2 * 1024 * 1024, // 2MB
          maxNumberOfFiles: 10, // 最多10张图片
          allowedFileTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'],
          // 允许重复文件上传
          checkDuplicate: false,
          onBeforeUpload(file) {
            return true
          },
          onSuccess(file, res) {
            return res.url
          },
          onError(file, err, res) {
            ElMessage.error('图片上传失败')
          }
        },
        // 配置上传视频
        uploadVideo: {
          server: uploadUrl.value,
          fieldName: 'file',
          headers: uploadHeaders.value,
          maxFileSize: 10 * 1024 * 1024, // 10M
          allowedFileTypes: ['video/*'],
          onBeforeUpload(file) {
            return true
          },
          onSuccess(file, res) {
            return res.url
          },
          onError(file, err, res) {
            ElMessage.error('视频上传失败')
          }
        }
      }
    })
    
    // 富文本编辑器是否可用
    const isEditorAvailable = ref(false)
    
    // 表单引用
    const categoryFormRef = ref()
    const productFormRef = ref()
    const uploadRef = ref()
    const categoryUploadRef = ref()
    
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
    
    // 解析收货地址信息
    const parsedShippingInfo = computed(() => {
      if (!currentOrderDetail.value || !currentOrderDetail.value.shipping_address) {
        return { name: '', phone: '', address: '' }
      }
      
      const addressStr = currentOrderDetail.value.shipping_address
      // 收货地址格式：姓名 手机号 省份 城市 区县 详细地址
      // 使用正则表达式匹配手机号来分割
      const phoneRegex = /(\d{11})/
      const match = addressStr.match(phoneRegex)
      
      if (match) {
        const phoneIndex = match.index
        const name = addressStr.substring(0, phoneIndex).trim()
        const phone = match[1]
        const address = addressStr.substring(phoneIndex + 11).trim()
        
        return {
          name: name || '',
          phone: phone || '',
          address: address || ''
        }
      }
      
      // 如果无法解析，返回原始地址
      return {
        name: '',
        phone: '',
        address: addressStr
      }
    })
    
    // 加载产品规格数据
    const loadProductSpecifications = async (productId) => {
      try {
        console.log('开始加载产品规格数据，产品ID:', productId)
        console.log('当前产品列表:', products.value)
        
        // 首先尝试从产品列表中获取规格数据
        const productFromList = products.value.find(p => p.id === productId)
        console.log('找到的产品:', productFromList)
        console.log('产品的规格数据:', productFromList?.specifications)
        
        if (productFromList && productFromList.specifications && productFromList.specifications.length > 0) {
          console.log('从产品列表获取规格数据:', productFromList.specifications)
          
          // 将规格数据转换为前端需要的格式
          const specs = productFromList.specifications
            .filter(spec => spec && spec.name && typeof spec.name === 'string' && spec.name.trim() !== '')
            .map(spec => {
              console.log('处理规格:', spec)
              console.log('规格的values:', spec.values)
              console.log('规格的values类型:', typeof spec.values, Array.isArray(spec.values))
              
              let processedValues = []
              if (Array.isArray(spec.values)) {
                processedValues = spec.values
                  .filter(v => v && (typeof v === 'string' ? v.trim() !== '' : (v.value && v.value.trim() !== '')))
                  .map(v => {
                    if (typeof v === 'string') {
                      return v.trim()
                    } else if (v && v.value) {
                      return v.value.trim()
                    }
                    return ''
                  })
                  .filter(v => v !== '')
              }
              
              const processedSpec = {
                id: spec.id || (Date.now() + Math.random() + 10000), // 临时ID从10000开始，避免与数据库ID冲突
                name: spec.name.trim(),
                values: processedValues,
                inputVisible: false,
                inputValue: ''
              }
              
              console.log('处理后的规格:', processedSpec)
              return processedSpec
            })
            .filter(spec => spec.values.length > 0) // 只保留有值的规格
          
          console.log('最终规格数据:', specs)
          productForm.specifications = specs
          
          // 如果有规格组合数据，也加载进来
          if (productFromList.specificationCombinations && productFromList.specificationCombinations.length > 0) {
            productForm.specificationCombinations = productFromList.specificationCombinations.map(comb => ({
              ...comb,
              price: comb.price || productForm.base_price,
              stock: comb.stock || productForm.stock,
              sku_code: comb.sku_code || ''
            }))
          } else {
            // 生成默认的规格组合
            updateSpecificationCombinations()
          }
          
          return // 如果从列表获取到数据，就不需要调用API了
        }
        
        // 如果产品列表中没有规格数据，则调用API获取
        console.log('从API获取产品详情数据')
        try {
          const productResponse = await getMallProduct(productId)
          console.log('产品详情API响应:', productResponse)
          
          if (productResponse.data && productResponse.data.specifications) {
            console.log('从产品详情API获取规格数据:', productResponse.data.specifications)
            
            // 将规格数据转换为前端需要的格式
            const specs = productResponse.data.specifications
              .filter(spec => spec && spec.name && typeof spec.name === 'string' && spec.name.trim() !== '')
              .map(spec => {
                console.log('处理规格:', spec)
                console.log('规格的values:', spec.values)
                console.log('规格的values类型:', typeof spec.values, Array.isArray(spec.values))
                
                let processedValues = []
                if (Array.isArray(spec.values)) {
                  processedValues = spec.values
                    .filter(v => v && (typeof v === 'string' ? v.trim() !== '' : (v.value && v.value.trim() !== '')))
                    .map(v => {
                      if (typeof v === 'string') {
                        return v.trim()
                      } else if (v && v.value) {
                        return v.value.trim()
                      }
                      return ''
                    })
                    .filter(v => v !== '')
                }
                
                const processedSpec = {
                  id: spec.id || (Date.now() + Math.random() + 10000),
                  name: spec.name.trim(),
                  values: processedValues,
                  inputVisible: false,
                  inputValue: ''
                }
                
                console.log('处理后的规格:', processedSpec)
                return processedSpec
              })
              .filter(spec => spec.values.length > 0) // 只保留有值的规格
            
            console.log('最终规格数据:', specs)
            productForm.specifications = specs
            
            // 如果有规格组合数据，也加载进来
            if (productResponse.data.specificationCombinations && productResponse.data.specificationCombinations.length > 0) {
              productForm.specificationCombinations = productResponse.data.specificationCombinations.map(comb => ({
                ...comb,
                price: comb.price || productForm.base_price,
                stock: comb.stock || productForm.stock,
                sku_code: comb.sku_code || ''
              }))
            } else {
              // 生成默认的规格组合
              updateSpecificationCombinations()
            }
            
            return // 如果从产品详情API获取到数据，就不需要继续了
          }
        } catch (error) {
          console.error('获取产品详情失败:', error)
        }
        
        console.log('从规格API获取产品规格数据')
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
                  price: sku.price || productForm.base_price,
                  stock: sku.stock || productForm.stock,
                  sku_code: sku.sku_code || ''
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
      
      // 确保规格数据已设置（即使为空）
      console.log('最终设置的规格数据:', productForm.specifications)
      console.log('最终设置的规格组合数据:', productForm.specificationCombinations)
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
            images: item.images || [],
            specifications: item.specifications || [],
            specificationCombinations: item.specificationCombinations || []
          }))
        } else if (Array.isArray(response.data)) {
          // 处理数组响应
          products.value = response.data.map(item => ({
            ...item,
            category_name: item.category?.name || '未分类',
            price: item.base_price, // 兼容旧字段
            images: item.images || [],
            specifications: item.specifications || [],
            specificationCombinations: item.specificationCombinations || []
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
            user_name: item.user?.username || item.user?.name || item.customer_name || '未知用户',
            total_amount: item.total_amount || 0
          }))
        } else if (Array.isArray(response.data)) {
          // 处理数组响应
          orders.value = response.data.map(item => ({
            ...item,
            order_number: item.order_no || item.order_number,
            user_name: item.user?.username || item.user?.name || item.customer_name || '未知用户',
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
          image: '',
          sort_order: 0,
          status: 'active'
        })
      }
      
      // 重置上传组件
      nextTick(() => {
        if (categoryUploadRef.value) {
          categoryUploadRef.value.clearFiles()
        }
      })
      
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
    
    // 重新获取产品数据用于编辑
    const loadProductForEdit = async (productId) => {
      try {
        console.log('重新获取产品数据用于编辑:', productId)
        const response = await getMallProduct(productId)
        console.log('重新获取的产品数据:', response)
        
        if (response.data) {
          const editData = { ...response.data }
          console.log('编辑产品数据:', editData)
          
          // 处理图片数据
          if (editData.images && Array.isArray(editData.images)) {
            editData.images = editData.images.map((img, index) => {
              if (typeof img === 'string') {
                return {
                  name: `image_${index + 1}.jpg`,
                  url: img,
                  uid: Date.now() + index,
                  status: 'success',
                  response: { url: img, filename: `image_${index + 1}.jpg` }
                }
              }
              return img
            })
          } else {
            editData.images = []
          }
          
          // 处理描述字段
          if (editData.description && typeof editData.description === 'string') {
            if (!editData.description.startsWith('<')) {
              editData.description = `<p>${editData.description}</p>`
            }
          } else {
            editData.description = '<p></p>'
          }
          
          // 设置表单数据
          Object.assign(productForm, editData)
          
          // 加载规格数据
          if (editData.specifications && Array.isArray(editData.specifications)) {
            const specs = editData.specifications
              .filter(spec => spec && spec.name && typeof spec.name === 'string' && spec.name.trim() !== '')
              .map(spec => {
                let processedValues = []
                if (Array.isArray(spec.values)) {
                  processedValues = spec.values
                    .filter(v => v && (typeof v === 'string' ? v.trim() !== '' : (v.value && v.value.trim() !== '')))
                    .map(v => {
                      if (typeof v === 'string') {
                        return v.trim()
                      } else if (v && v.value) {
                        return v.value.trim()
                      }
                      return ''
                    })
                    .filter(v => v !== '')
                }
                
                return {
                  id: spec.id || (Date.now() + Math.random() + 10000),
                  name: spec.name.trim(),
                  values: processedValues,
                  inputVisible: false,
                  inputValue: ''
                }
              })
              .filter(spec => spec.values.length > 0)
            
            productForm.specifications = specs
            
            // 从SKU数据重建规格组合
            if (editData.skus && Array.isArray(editData.skus) && editData.skus.length > 0) {
              console.log('从SKU数据重建规格组合:', editData.skus)
              
              const combinations = editData.skus
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
                    price: sku.price || editData.base_price,
                    stock: sku.stock || editData.stock,
                    sku_code: sku.sku_code || ''
                  }
                })
                .filter(comb => comb.specs.length > 0)
              
              productForm.specificationCombinations = combinations
              console.log('重建的规格组合:', combinations)
            } else {
              // 如果没有SKU数据，生成默认的规格组合
              setTimeout(() => {
                updateSpecificationCombinations()
              }, 100)
            }
          } else {
            productForm.specifications = []
            productForm.specificationCombinations = []
          }
          
          // 显示对话框
          productDialogVisible.value = true
          
          // 确保富文本编辑器正确设置内容
          nextTick(() => {
            setTimeout(() => {
              if (editorRef.value && editData.description) {
                console.log('设置编辑器内容:', editData.description)
                editorRef.value.setHtml(editData.description)
              }
            }, 200) // 延迟一点确保编辑器完全初始化
          })
        }
      } catch (error) {
        console.error('获取产品数据失败:', error)
        ElMessage.error('获取产品数据失败')
      }
    }

    // 产品管理
    const showProductDialog = (type, data = {}) => {
      productDialogType.value = type
      
      if (type === 'edit') {
        // 编辑模式：重新从API获取最新数据
        console.log('编辑模式，重新获取最新产品数据:', data.id)
        
        // 先重置表单数据，避免数据污染
        Object.assign(productForm, {
          title: '',
          category_id: '',
          base_price: 0,
          stock: 0,
          description: '<p></p>',
          images: [],
          status: 'active',
          specifications: [],
          specificationCombinations: []
        })
        
        loadProductForEdit(data.id)
        return
      } else {
        // 新增模式：重置表单
        Object.assign(productForm, {
          title: '',
          category_id: '',
          base_price: 0,
          stock: 0,
          description: '<p></p>',
          images: [],
          status: 'active',
          specifications: [],
          specificationCombinations: []
        })
        productDialogVisible.value = true
        return
      }
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
            price: comb.price || productForm.base_price,
            stock: comb.stock || productForm.stock,
            sku_code: comb.sku_code || ''
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
            
            // 获取现有的规格列表，用于同步
            let existingSpecs = []
            try {
              const specsResponse = await getMallProductSpecifications(productId)
              if (specsResponse.data && specsResponse.data.length > 0) {
                existingSpecs = specsResponse.data
              }
            } catch (error) {
              console.log('获取现有规格失败:', error.message)
            }
            
            // 收集当前要保存的规格ID
            const currentSpecIds = new Set()
            
            // 保存规格组
            for (const spec of productForm.specifications) {
              if (spec.name && spec.values && spec.values.length > 0) {
                const specData = {
                  product_id: productId,
                  name: spec.name,
                  sort_order: 0
                }
                
                let savedSpec
                // 检查规格ID是否有效（数据库ID）
                if (spec.id && typeof spec.id === 'number' && spec.id > 0) {
                  // 如果是有效的数据库ID，更新现有规格
                  try {
                    savedSpec = await updateMallProductSpecification(spec.id, specData)
                    currentSpecIds.add(spec.id)
                  } catch (updateError) {
                    console.log(`更新规格失败，尝试创建新规格: ${updateError.message}`)
                    // 如果更新失败，创建新规格
                    savedSpec = await createMallProductSpecification(specData)
                    if (savedSpec && savedSpec.data && savedSpec.data.id) {
                      currentSpecIds.add(savedSpec.data.id)
                    }
                  }
                } else {
                  // 如果是临时ID或无效ID，创建新的规格
                  savedSpec = await createMallProductSpecification(specData)
                  if (savedSpec && savedSpec.data && savedSpec.data.id) {
                    currentSpecIds.add(savedSpec.data.id)
                  }
                }
                
                // 保存规格值
                if (savedSpec && savedSpec.data && savedSpec.data.id) {
                  const specId = savedSpec.data.id
                  
                  // 先删除旧的规格值
                  try {
                    await deleteMallProductSpecificationValues(specId)
                    console.log(`删除规格 ${specId} 的旧规格值成功`)
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
                        await createMallProductSpecificationValue(valueData)
                        console.log('创建规格值成功:', valueData)
                      } catch (valueError) {
                        console.error('创建规格值失败:', valueError)
                      }
                    }
                  }
                }
              }
            }
            
            // 删除不再需要的规格
            for (const existingSpec of existingSpecs) {
              if (!currentSpecIds.has(existingSpec.id)) {
                try {
                  await deleteMallProductSpecification(existingSpec.id)
                  console.log(`删除不再需要的规格: ${existingSpec.id}`)
                } catch (deleteError) {
                  console.log('删除规格失败:', deleteError.message)
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
                      sku_code: comb.sku_code || `${productData.title}_${comb.specs.map(s => s.value).join('_')}`,
                      price: parseFloat((comb.price || productForm.base_price).toFixed(2)),
                      stock: parseInt(comb.stock || productForm.stock),
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
        
        // 保存成功后重新加载产品列表，确保数据同步
        loadProducts()
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
    
    // 复制产品
    const copyProduct = async (id) => {
      try {
        await ElMessageBox.confirm('确定要复制这个产品吗？', '提示', {
          type: 'info'
        })
        const response = await copyMallProduct(id)
        ElMessage.success('复制成功')
        loadProducts()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('复制产品失败:', error)
          ElMessage.error('复制失败')
        }
      }
    }
    
    // 切换产品状态
    const toggleProductStatus = async (id, currentStatus) => {
      try {
        const newStatus = currentStatus === 'active' ? 'inactive' : 'active'
        const action = newStatus === 'active' ? '上架' : '下架'
        
        await ElMessageBox.confirm(`确定要${action}这个产品吗？`, '提示', {
          type: 'warning'
        })
        
        await updateMallProductStatus(id, newStatus)
        ElMessage.success(`${action}成功`)
        loadProducts()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('更新产品状态失败:', error)
          ElMessage.error('操作失败')
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
      try {
        // 过滤掉没有值的规格组
        const validSpecs = productForm.specifications.filter(group => group.name && group.values.length > 0)
        
        if (validSpecs.length === 0) {
          productForm.specificationCombinations = []
          return
        }

        // 限制规格组合数量，避免性能问题
        const maxCombinations = 1000
        let combinationCount = 0
        
        // 生成所有可能的组合
        const combinations = []
        
        const generateCombinations = (currentCombination, currentIndex) => {
          // 防止组合过多导致性能问题
          if (combinationCount >= maxCombinations) {
            return
          }
          
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
                  price: productForm.base_price, // 默认价格
                  stock: productForm.stock, // 默认库存
                  sku_code: '' // 默认SKU编码
                })
                combinationCount++
              }
            }
            return
          }

          const currentSpec = validSpecs[currentIndex]
          if (currentSpec.values && Array.isArray(currentSpec.values)) {
            for (const value of currentSpec.values) {
              if (value && typeof value === 'string' && value.trim() !== '' && combinationCount < maxCombinations) {
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
            price: comb.price || productForm.base_price,
            stock: comb.stock || productForm.stock,
            sku_code: comb.sku_code || ''
          }
        })

        // 根据规格组合生成最终的规格组合列表，保留现有的价格和库存值
        productForm.specificationCombinations = combinations.map(comb => {
          const key = comb.specs.map(spec => `${spec.name}:${spec.value}`).sort().join('|')
          const existingValue = existingValues[key] || { price: productForm.base_price, stock: productForm.stock, sku_code: '' }
          
          return {
            ...comb,
            price: existingValue.price || productForm.base_price,
            stock: existingValue.stock || productForm.stock,
            sku_code: existingValue.sku_code || ''
          }
        })
        
        console.log('生成的规格组合数量:', productForm.specificationCombinations.length)
      } catch (error) {
        console.error('更新规格组合失败:', error)
        productForm.specificationCombinations = []
      }
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
    
    const viewOrderDetail = async (orderId) => {
      try {
        const response = await getOrderDetail(orderId)
        console.log('订单详情API响应:', response)
        
        if (response.data) {
          currentOrderDetail.value = response.data
          orderDetailVisible.value = true
        } else {
          ElMessage.error('获取订单详情失败')
        }
      } catch (error) {
        console.error('获取订单详情失败:', error)
        ElMessage.error('获取订单详情失败')
      }
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
        description: '<p></p>', // 富文本编辑器需要HTML格式
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
    
    // 分类图片上传成功处理
    const handleCategoryImageSuccess = (response, file, fileList) => {
      console.log('分类图片上传成功:', response)
      
      if (response && response.url) {
        categoryForm.image = response.url
        ElMessage.success('分类图片上传成功')
        
        // 清空文件列表，允许重新上传
        if (categoryUploadRef.value) {
          categoryUploadRef.value.clearFiles()
        }
      } else {
        console.error('分类图片上传响应格式错误:', response)
        ElMessage.error('分类图片上传失败：响应格式错误')
      }
    }
    
    // 分类图片移除处理
    const handleCategoryImageRemove = () => {
      categoryForm.image = ''
      ElMessage.success('分类图片移除成功')
    }
    
    // 筛选
    const filterProducts = () => {
      // 产品筛选逻辑已在计算属性中处理
    }

    // 注意：getImageUrl函数已从@/utils/imageUtils导入，这里不需要重复定义

    // 富文本编辑器创建处理
    const handleEditorCreated = (editor) => {
      editorRef.value = editor
      isEditorAvailable.value = true
      
      // 确保编辑器正确初始化
      nextTick(() => {
        if (editorRef.value && productForm.description) {
          console.log('编辑器创建后设置内容:', productForm.description)
          editorRef.value.setHtml(productForm.description)
        }
      })
    }
    
    // 富文本编辑器内容变化处理
    const handleEditorChange = (editor) => {
      // 内容变化时的处理逻辑
    }
    
    // 图片预览处理
    const handlePictureCardPreview = (file) => {
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
    
    // 格式化日期时间
    const formatDateTime = (dateTime) => {
      if (!dateTime) return ''
      const date = new Date(dateTime)
      return date.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      })
    }
    
    // 获取订单第一个商品的图片
    const getOrderFirstProductImage = (order) => {
      if (!order.items || !Array.isArray(order.items) || order.items.length === 0) {
        return null
      }
      const firstItem = order.items[0]
      if (firstItem.product && firstItem.product.images && firstItem.product.images.length > 0) {
        return getImageUrl(firstItem.product.images[0])
      }
      return null
    }
    
    // 获取订单所有商品的图片
    const getOrderProductImages = (order) => {
      if (!order.items || !Array.isArray(order.items)) {
        return []
      }
      const images = []
      order.items.forEach(item => {
        if (item.product && item.product.images && Array.isArray(item.product.images)) {
          item.product.images.forEach(img => {
            if (img) {
              images.push(getImageUrl(img))
            }
          })
        }
      })
      return images
    }
    
    // 获取订单第一个商品的名称
    const getOrderFirstProductName = (order) => {
      if (!order.items || !Array.isArray(order.items) || order.items.length === 0) {
        return null
      }
      return order.items[0].product_name || (order.items[0].product && order.items[0].product.title)
    }
    
    // 获取订单第一个商品的ID
    const getOrderFirstProductId = (order) => {
      if (!order.items || !Array.isArray(order.items) || order.items.length === 0) {
        return null
      }
      return order.items[0].product_id || (order.items[0].product && order.items[0].product.id)
    }
    
    // 获取订单商品数量
    const getOrderProductCount = (order) => {
      if (!order.items || !Array.isArray(order.items)) {
        return 0
      }
      return order.items.length
    }
    
    // 查看商品详情
    const viewProductDetail = async (productId) => {
      try {
        const response = await getMallProduct(productId)
        console.log('商品详情API响应:', response)
        
        if (response.data) {
          currentProductDetail.value = response.data
          currentProductImageIndex.value = 0
          productDetailVisible.value = true
        } else {
          ElMessage.error('获取商品详情失败')
        }
      } catch (error) {
        console.error('获取商品详情失败:', error)
        ElMessage.error('获取商品详情失败')
      }
    }
    
    // 设置当前商品图片
    const setCurrentProductImage = (index) => {
      currentProductImageIndex.value = index
    }
    
    // 编辑商品
    const editProduct = (product) => {
      productDetailVisible.value = false
      showProductDialog('edit', product)
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
      parsedShippingInfo,
      
      // 对话框
      categoryDialogVisible,
      categoryDialogType,
      productDialogVisible,
      productDialogType,
      imagePreviewVisible,
      previewImageUrl,
      orderDetailVisible,
      currentOrderDetail,
      productDetailVisible,
      currentProductDetail,
      currentProductImageIndex,
      
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
      copyProduct,
      toggleProductStatus,
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
      formatDateTime,
      getOrderFirstProductImage,
      getOrderProductImages,
      getOrderFirstProductName,
      getOrderFirstProductId,
      getOrderProductCount,
      viewProductDetail,
      setCurrentProductImage,
      editProduct,
      handleImageSuccess,
      handleImageRemove,
      handleImageError,
      handleImageLoadError,
      handleImageChange,
      removeExistingImage,
      handleCategoryImageSuccess,
      handleCategoryImageRemove,
      filterProducts,
      filterOrders,
      getImageUrl,
      uploadUrl,
      beforeImageUpload,
      getImagePreviewList,
      getProductImageList,
      handlePictureCardPreview,
      uploadHeaders,
      uploadRef,
      categoryUploadRef,
      editorRef,
      editorConfig,
      toolbarConfig,
      mode,
      handleEditorCreated,
      handleEditorChange,
      isEditorAvailable
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

/* 富文本编辑器样式覆盖 */
.w-e-text-container {
  background-color: white !important;
}

.w-e-toolbar {
  background-color: #fafafa !important;
  border-bottom: 1px solid #e5e7eb !important;
}

.w-e-text-placeholder {
  color: #9ca3af !important;
}

/* 确保编辑器在对话框内正确显示 */
.el-dialog .w-e-text-container {
  z-index: 1 !important;
}

.el-dialog .w-e-toolbar {
  z-index: 2 !important;
}

/* 分类图片上传样式 */
.category-upload {
  width: 100%;
}

.category-upload-placeholder {
  width: 100%;
  height: 150px;
  border: 2px dashed #d9d9d9;
  border-radius: 6px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: #fafafa;
  color: #999;
  cursor: pointer;
  transition: border-color 0.3s;
}

.category-upload-placeholder:hover {
  border-color: var(--color-primary);
}

.category-upload-placeholder .el-icon {
  font-size: 28px;
  margin-bottom: 8px;
}

.category-image-preview {
  position: relative;
  width: 100%;
  height: 150px;
  border-radius: 6px;
  overflow: hidden;
  cursor: pointer;
}

.category-image-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
}

.category-image-preview:hover .image-overlay {
  opacity: 1;
}

/* 订单详情样式 */
.order-detail {
  max-height: 70vh;
  overflow-y: auto;
}

.order-info-section {
  margin-bottom: 30px;
  padding: 20px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  background-color: #fafafa;
}

.order-info-section h3 {
  margin: 0 0 15px 0;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
  border-bottom: 2px solid #409eff;
  padding-bottom: 8px;
}

.info-item {
  margin-bottom: 12px;
  display: flex;
  align-items: center;
}

.info-item label {
  font-weight: 600;
  color: #606266;
  min-width: 100px;
  margin-right: 10px;
}

.info-item span {
  color: #303133;
}

.total-amount {
  font-size: 18px;
  font-weight: bold;
  color: #e6a23c;
}

.shipping-info {
  background-color: white;
  padding: 15px;
  border-radius: 6px;
  border: 1px solid #e4e7ed;
}

.remark-content {
  background-color: white;
  padding: 15px;
  border-radius: 6px;
  border: 1px solid #e4e7ed;
  color: #606266;
  line-height: 1.6;
}

/* 商品详情样式 */
.product-detail {
  max-height: 80vh;
  overflow-y: auto;
}

.product-detail-content {
  display: flex;
  gap: 30px;
}

.product-gallery {
  flex: 0 0 400px;
}

.main-image {
  width: 100%;
  height: 300px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  overflow: hidden;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #fafafa;
}

.main-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-placeholder {
  text-align: center;
  color: #999;
}

.image-placeholder span {
  font-size: 48px;
  display: block;
  margin-bottom: 10px;
}

.image-thumbnails {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.thumbnail {
  width: 60px;
  height: 60px;
  border: 2px solid #e4e7ed;
  border-radius: 6px;
  overflow: hidden;
  cursor: pointer;
  transition: border-color 0.3s;
}

.thumbnail:hover {
  border-color: #409eff;
}

.thumbnail.active {
  border-color: #409eff;
  border-width: 3px;
}

.thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.thumbnail-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f5f5f5;
  color: #999;
}

.product-info {
  flex: 1;
}

.product-header {
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #e4e7ed;
}

.product-title {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 10px 0;
}

.product-model {
  color: #606266;
  margin: 0;
  font-size: 14px;
}

.product-price-section {
  margin-bottom: 25px;
}

.current-price {
  font-size: 28px;
  font-weight: bold;
  color: #e6a23c;
}

.product-specs,
.product-description,
.product-basic-info {
  margin-bottom: 25px;
  padding: 20px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  background-color: #fafafa;
}

.product-specs h3,
.product-description h3,
.product-basic-info h3 {
  margin: 0 0 15px 0;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
  border-bottom: 2px solid #409eff;
  padding-bottom: 8px;
}

.spec-item {
  margin-bottom: 15px;
}

.spec-label {
  font-weight: 600;
  color: #606266;
  margin-bottom: 8px;
}

.spec-values {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.description-content {
  background-color: white;
  padding: 15px;
  border-radius: 6px;
  border: 1px solid #e4e7ed;
  color: #606266;
  line-height: 1.6;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 15px;
}

.more-products {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}
</style>
