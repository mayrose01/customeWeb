import axios from './axios'

// 获取用户购物车
export function getCart(userId) {
  return axios.get('/cart/', { params: { user_id: userId } })
}

// 添加商品到购物车
export function addToCart(userId, skuId, quantity = 1) {
  return axios.post('/cart/add', {
    user_id: userId,
    sku_id: skuId,
    quantity: quantity
  })
}

// 更新购物车商品数量
export function updateCartItem(userId, itemId, quantity) {
  return axios.put(`/cart/update/${itemId}`, {
    user_id: userId,
    quantity: quantity
  })
}

// 从购物车移除商品
export function removeFromCart(userId, itemId) {
  return axios.delete(`/cart/remove/${itemId}`, {
    params: { user_id: userId }
  })
}

// 清空购物车
export function clearCart(userId) {
  return axios.delete('/cart/clear', {
    params: { user_id: userId }
  })
}

// 获取购物车商品数量
export function getCartItemCount(userId) {
  return axios.get('/cart/count', {
    params: { user_id: userId }
  })
} 