import axios from './axios';

export function login(username, password) {
  const data = new URLSearchParams();
  data.append('username', username);
  data.append('password', password);
  return axios.post('/user/login', data);
}

// 微信小程序登录
export function wxLogin(wxCode) {
  return axios.post('/user/wx-login', { wx_code: wxCode });
}

// App端登录
export function appLogin(appOpenid) {
  return axios.post('/user/app-login', { app_openid: appOpenid });
}

// Token刷新
export function refreshToken() {
  return axios.post('/user/refresh-token');
}

export function changePassword(username, oldPassword, newPassword) {
  return axios.post('/user/change-password', { username, old_password: oldPassword, new_password: newPassword });
}

export function adminChangePassword(username, newPassword) {
  return axios.post('/user/admin/change-password', { username, new_password: newPassword });
}

export function getUsers(params) {
  return axios.get('/user/', { params });
}

export function createUser(data) {
  return axios.post('/user/register', data);
}

// 客户端用户注册
export function register(data) {
  return axios.post('/user/register', data);
}

// 客户端用户登录
export function clientLogin(username, password) {
  return axios.post('/client-user/login', { username, password });
}

// 客户端用户注册
export function clientRegister(data) {
  return axios.post('/client-user/register', data);
}

// 获取客户端用户信息
export function getClientUserProfile() {
  return axios.get('/client-user/profile');
}

// 更新客户端用户信息
export function updateClientUserProfile(data) {
  return axios.put('/client-user/profile', data);
}

// 获取用户询价列表
export function getUserInquiries(params) {
  return axios.get('/client-user/inquiries', { params });
}

// 获取用户咨询列表
export function getUserConsultations(params) {
  return axios.get('/client-user/consultations', { params });
}

export function updateUser(id, data) {
  return axios.put(`/user/${id}`, data);
}

export function deleteUser(id) {
  return axios.delete(`/user/${id}`);
}

// 获取当前用户信息
export function getCurrentUser() {
  return axios.get('/user/me');
} 