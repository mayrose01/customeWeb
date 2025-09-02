import axios from './axios';

// 获取商城订单列表
export function getMallOrders(params) {
  return axios.get('/mall-order/', { params });
}

// 获取商城订单详情
export function getMallOrder(id) {
  return axios.get(`/mall-order/${id}`);
}

// 根据订单号获取商城订单
export function getMallOrderByNo(orderNo) {
  return axios.get(`/mall-order/no/${orderNo}`);
}

// 更新商城订单
export function updateMallOrder(id, data) {
  return axios.put(`/mall-order/${id}`, data);
}

// 更新商城订单状态
export function updateMallOrderStatus(id, status) {
  return axios.put(`/mall-order/${id}/status`, { status });
}

// 更新商城订单物流信息（发货）
export function updateMallOrderShipping(id, trackingNumber, shippingCompany) {
  return axios.put(`/mall-order/${id}/shipping`, {
    tracking_number: trackingNumber,
    shipping_company: shippingCompany
  });
}

// 更新商城订单支付状态
export function updateMallOrderPaymentStatus(id, paymentStatus) {
  return axios.put(`/mall-order/${id}/payment-status`, {
    payment_status: paymentStatus
  });
}

// 删除商城订单
export function deleteMallOrder(id) {
  return axios.delete(`/mall-order/${id}`);
}

// 获取商城订单统计概览
export function getMallOrderStats() {
  return axios.get('/mall-order/stats/overview');
}

// 获取商城订单每日统计
export function getMallOrderDailyStats(startDate, endDate) {
  return axios.get('/mall-order/stats/daily', {
    params: { start_date: startDate, end_date: endDate }
  });
}
