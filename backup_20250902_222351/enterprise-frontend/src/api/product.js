import axios from './axios';

export function getProducts(params) {
  return axios.get('/product/', { params });
}

export function getProductsWithPagination(params) {
  return axios.get('/product/', { params });
}

export function getProduct(id) {
  return axios.get(`/product/${id}`);
}

export function createProduct(data) {
  return axios.post('/product/', data);
}

export function updateProduct(id, data) {
  return axios.put(`/product/${id}`, data);
}

export function deleteProduct(id) {
  return axios.delete(`/product/${id}`);
}

export function copyProduct(id) {
  return axios.post(`/product/${id}/copy`);
}

// 获取SKU信息
export function getSkuInfo(skuId) {
  return axios.get(`/product/sku/${skuId}`);
}

// 获取商品SKU列表
export function getProductSkus(productId) {
  return axios.get(`/product/${productId}/skus`);
}

// 创建商品SKU
export function createSku(data) {
  return axios.post('/product/sku/', data);
}

// 更新商品SKU
export function updateSku(skuId, data) {
  return axios.put(`/product/sku/${skuId}`, data);
}

// 删除商品SKU
export function deleteSku(skuId) {
  return axios.delete(`/product/sku/${skuId}`);
} 