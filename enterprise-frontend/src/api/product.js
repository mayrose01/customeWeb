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