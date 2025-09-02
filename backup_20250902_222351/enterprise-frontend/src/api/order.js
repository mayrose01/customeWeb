import request from './axios'

// 获取订单列表（管理员）
export function getOrders(params) {
  return request({
    url: '/order/',
    method: 'get',
    params
  })
}

// 获取用户订单列表
export function getUserOrders(userId, params) {
  return request({
    url: `/order/user/${userId}`,
    method: 'get',
    params
  })
}

// 获取订单详情
export function getOrderDetail(orderId) {
  return request({
    url: `/order/${orderId}`,
    method: 'get'
  })
}

// 创建订单
export function createOrder(userId, data) {
  return request({
    url: '/order/create',
    method: 'post',
    params: { user_id: userId },
    data
  })
}

// 更新订单状态
export function updateOrderStatus(orderId, data) {
  return request({
    url: `/order/${orderId}`,
    method: 'put',
    data
  })
}

// 取消订单
export function cancelOrder(orderId) {
  return request({
    url: `/order/${orderId}/cancel`,
    method: 'put'
  })
}

// 支付订单
export function payOrder(orderId, paymentData) {
  // 后端期望 payment_method 作为查询参数，使用 POST 方法
  const payment_method = typeof paymentData === 'string' ? paymentData : paymentData?.payment_method
  return request({
    url: `/order/${orderId}/pay`,
    method: 'post',
    params: payment_method ? { payment_method } : {}
  })
}

// 确认收货
export function confirmDelivery(orderId) {
  return request({
    url: `/order/${orderId}/confirm-delivery`,
    method: 'put'
  })
}

// 检查支付状态
export function checkPaymentStatus(orderId) {
  return request({
    url: `/order/${orderId}/payment-status`,
    method: 'get'
  })
}

// 获取订单统计信息
export function getOrderStats() {
  return request({
    url: '/order/stats',
    method: 'get'
  })
} 