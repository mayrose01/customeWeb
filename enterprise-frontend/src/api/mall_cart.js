import axios from './axios';

// 获取用户购物车
export function getCart(userId) {
  return axios.get(`/mall-cart/?user_id=${userId}`);
}

// 添加商品到购物车
export function addToCart(userId, data) {
  return axios.post(`/mall-cart/items?user_id=${userId}`, data);
}

// 更新购物车商品数量
export function updateCartItem(itemId, data) {
  return axios.put(`/mall-cart/items/${itemId}`, data);
}

// 从购物车删除商品
export function removeFromCart(itemId) {
  return axios.delete(`/mall-cart/items/${itemId}`);
}

// 清空购物车
export function clearCart(userId) {
  return axios.delete(`/mall-cart/?user_id=${userId}`);
}
