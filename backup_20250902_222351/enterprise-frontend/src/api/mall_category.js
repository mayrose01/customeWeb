import axios from './axios';

// 获取商城分类列表
export function getMallCategories() {
  return axios.get('/mall-category/');
}

// 获取商城分类树形结构
export function getMallCategoriesTree() {
  return axios.get('/mall-category/tree');
}

// 获取商城子分类
export function getMallSubcategories(parentId) {
  return axios.get(`/mall-category/${parentId}/subcategories`);
}

// 获取单个商城分类
export function getMallCategory(id) {
  return axios.get(`/mall-category/${id}`);
}

// 创建商城分类
export function createMallCategory(data) {
  return axios.post('/mall-category/', data);
}

// 更新商城分类
export function updateMallCategory(id, data) {
  return axios.put(`/mall-category/${id}`, data);
}

// 删除商城分类
export function deleteMallCategory(id) {
  return axios.delete(`/mall-category/${id}`);
}
