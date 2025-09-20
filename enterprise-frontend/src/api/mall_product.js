import axios from './axios';

// 获取商城产品列表
export function getMallProducts(params) {
  return axios.get('/mall-product/', { params });
}

// 获取商城产品详情
export function getMallProduct(id) {
  return axios.get(`/mall-product/${id}`);
}

// 创建商城产品
export function createMallProduct(data) {
  return axios.post('/mall-product/', data);
}

// 更新商城产品
export function updateMallProduct(id, data) {
  return axios.put(`/mall-product/${id}`, data);
}

// 删除商城产品
export function deleteMallProduct(id) {
  return axios.delete(`/mall-product/${id}`);
}

// 复制商城产品
export function copyMallProduct(id) {
  return axios.post(`/mall-product/${id}/copy`);
}

// 更新商城产品状态
export function updateMallProductStatus(id, status) {
  return axios.put(`/mall-product/${id}/status`, { status });
}

// 获取商城产品规格
export function getMallProductSpecifications(productId) {
  return axios.get(`/mall-specification/product/${productId}`);
}

// 创建商城产品规格
export function createMallProductSpecification(data) {
  return axios.post('/mall-specification/', data);
}

// 更新商城产品规格
export function updateMallProductSpecification(id, data) {
  return axios.put(`/mall-specification/${id}`, data);
}

// 删除商城产品规格
export function deleteMallProductSpecification(id) {
  return axios.delete(`/mall-specification/${id}`);
}

// 创建规格值
export function createMallProductSpecificationValue(data) {
  return axios.post('/mall-specification/values/', data);
}

// 更新规格值
export function updateMallProductSpecificationValue(id, data) {
  return axios.put(`/mall-specification/values/${id}`, data);
}

// 删除规格值
export function deleteMallProductSpecificationValue(id) {
  return axios.delete(`/mall-specification/values/${id}`);
}

// 删除规格的所有值
export function deleteMallProductSpecificationValues(specId) {
  return axios.delete(`/mall-specification/${specId}/values`);
}

// 获取商城产品SKU列表
export function getMallProductSkus(productId) {
  return axios.get(`/mall-specification/sku/product/${productId}`);
}

// 创建商城产品SKU
export function createMallProductSku(data) {
  return axios.post('/mall-specification/sku/', data);
}

// 更新商城产品SKU
export function updateMallProductSku(id, data) {
  return axios.put(`/mall-specification/sku/${id}`, data);
}

// 删除商城产品SKU
export function deleteMallProductSku(id) {
  return axios.delete(`/mall-specification/sku/${id}`);
}

// 获取产品中价格最高且有库存的SKU（用于快速加购）
export function getBestSkuForProduct(productId) {
  return axios.get(`/mall-product/${productId}/best-sku`);
}
