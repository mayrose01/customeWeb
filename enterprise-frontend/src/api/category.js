import axios from './axios';

export function getCategories() {
  return axios.get('/category/');
}

export function getCategoriesTree() {
  return axios.get('/category/tree');
}

export function getSubcategories(parentId) {
  return axios.get(`/category/${parentId}/subcategories`);
}

export function createCategory(data) {
  return axios.post('/category/', data);
}

export function updateCategory(id, data) {
  return axios.put(`/category/${id}`, data);
}

export function deleteCategory(id) {
  return axios.delete(`/category/${id}`);
} 