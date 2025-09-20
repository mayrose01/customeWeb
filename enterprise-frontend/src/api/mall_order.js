import axios from './axios';

// 创建订单
export function createOrder(userId, data) {
  return axios.post(`/mall-order/?user_id=${userId}`, data);
}

// 获取用户订单列表
export function getUserOrders(userId, params = {}) {
  return axios.get(`/mall-order/?user_id=${userId}`, { params });
}

// 获取订单详情
export function getOrder(orderId, userId) {
  return axios.get(`/mall-order/${orderId}?user_id=${userId}`);
}

// 取消订单
export function cancelOrder(orderId, userId) {
  return axios.put(`/mall-order/${orderId}/cancel?user_id=${userId}`);
}

// 确认收货
export function confirmOrder(orderId, userId) {
  return axios.put(`/mall-order/${orderId}/confirm?user_id=${userId}`);
}

// 管理员获取所有订单列表
export function getAllOrders(params = {}) {
  return axios.get('/mall-order/admin/all', { params });
}

// 管理员获取订单详情
export function getOrderDetail(orderId) {
  return axios.get(`/mall-order/admin/${orderId}`);
}

// 兼容性：为MallManage.vue提供getMallOrders函数
export function getMallOrders(params = {}) {
  return getAllOrders(params);
}

// 管理员更新订单状态
export function updateOrderStatus(orderId, data) {
  return axios.put(`/mall-order/admin/${orderId}/status`, data);
}

// 兼容性：为MallManage.vue提供updateMallOrderStatus函数
export function updateMallOrderStatus(orderId, status) {
  return updateOrderStatus(orderId, { status });
}

// 管理员更新订单支付状态
export function updatePaymentStatus(orderId, paymentStatus) {
  return axios.put(`/mall-order/admin/${orderId}/payment-status?payment_status=${paymentStatus}`);
}

// 管理员更新物流信息
export function updateShippingInfo(orderId, shippingCompany, trackingNumber) {
  return axios.put(`/mall-order/admin/${orderId}/shipping?shipping_company=${shippingCompany}&tracking_number=${trackingNumber}`);
}

// 兼容性：为MallManage.vue提供updateMallOrderShipping函数
export function updateMallOrderShipping(orderId, trackingNumber, shippingCompany) {
  return updateShippingInfo(orderId, shippingCompany, trackingNumber);
}