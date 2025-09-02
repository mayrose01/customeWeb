import axios from './axios';

// 获取所有产品（客户端专用）
export function getAllProducts(params) {
  return axios.get('/client-product/', { params });
}

// 获取单个产品详情（客户端专用）
export function getClientProduct(id) {
  return axios.get(`/client-product/${id}`);
} 