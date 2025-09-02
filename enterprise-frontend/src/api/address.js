import axios from './axios'

// 获取用户收货地址列表
export function getAddresses(userId) {
  return axios.get(`/address/user/${userId}`)
}

// 获取单个地址详情
export function getAddress(addressId) {
  return axios.get(`/address/${addressId}`)
}

// 新增收货地址
export function createAddress(data) {
  return axios.post('/address/', data)
}

// 更新收货地址
export function updateAddress(addressId, data) {
  return axios.put(`/address/${addressId}`, data)
}

// 删除收货地址
export function deleteAddress(addressId) {
  return axios.delete(`/address/${addressId}`)
}

// 设置默认地址
export function setDefaultAddress(addressId) {
  return axios.put(`/address/${addressId}/default`)
}