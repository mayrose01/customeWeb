import axios from './axios';

// 公司信息
export function getCompanyInfo() {
  return axios.get('/company/');
}

// 轮播图（只获取启用的）
export function getCarouselImages() {
  return axios.get('/carousel/client');
}

// 主营业务（只获取启用的）
export function getServices() {
  return axios.get('/service/client');
}

// 分类
export function getCategories() {
  return axios.get('/category/');
}

// 产品
export function getProducts(params) {
  return axios.get('/product/', { params });
}

export function getProduct(id) {
  return axios.get(`/product/${id}`);
}

// 询价
export function createInquiry(data) {
  return axios.post('/inquiry/', data);
}

// 联系我们消息
export function createContactMessage(data) {
  return axios.post('/contact-message/', data);
} 