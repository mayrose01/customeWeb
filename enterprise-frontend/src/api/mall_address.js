import axios from './axios';

// 获取用户收货地址列表
export function getUserAddresses(userId) {
  return axios.get(`/mall-address/?user_id=${userId}`);
}

// 创建收货地址
export function createAddress(userId, data) {
  return axios.post(`/mall-address/?user_id=${userId}`, data);
}

// 更新收货地址
export function updateAddress(addressId, userId, data) {
  return axios.put(`/mall-address/${addressId}?user_id=${userId}`, data);
}

// 删除收货地址
export function deleteAddress(addressId, userId) {
  return axios.delete(`/mall-address/${addressId}?user_id=${userId}`);
}

// 设置默认收货地址
export function setDefaultAddress(addressId, userId) {
  return axios.put(`/mall-address/${addressId}/set-default?user_id=${userId}`);
}
