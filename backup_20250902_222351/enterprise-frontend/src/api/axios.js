import axios from 'axios';
import { ElMessage } from 'element-plus';
import { getCurrentConfig } from '../../env.config.js';

// 动态获取配置
const getConfig = () => {
  const config = getCurrentConfig();
  console.log('=== API配置信息 ===');
  console.log('当前API_BASE_URL:', config.API_BASE_URL);
  console.log('当前环境:', config.APP_ENV);
  return config;
};

// 创建axios实例
const createAxiosInstance = () => {
  const config = getConfig();
  
  const instance = axios.create({
    baseURL: config.API_BASE_URL,
    timeout: 10000,
  });

  // 请求拦截器
  instance.interceptors.request.use(config => {
    // 优先使用客户端token，如果没有则使用管理后台token
    const clientToken = localStorage.getItem('client_token');
    const adminToken = localStorage.getItem('token');
    const token = clientToken || adminToken;
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
  });

  // 响应拦截器
  instance.interceptors.response.use(
    response => {
      return response;
    },
    async error => {
      const originalRequest = error.config;
      
      // 如果是401错误且没有重试过，且不是刷新token的请求本身
      if (error.response?.status === 401 && !originalRequest._retry && !originalRequest.url.includes('/refresh-token')) {
        originalRequest._retry = true;
        
        try {
          // 尝试刷新token
          const refreshResponse = await instance.post('/user/refresh-token');
          const newToken = refreshResponse.data.access_token;
          
          // 更新本地存储的token（根据当前使用的token类型）
          const clientToken = localStorage.getItem('client_token');
          if (clientToken) {
            localStorage.setItem('client_token', newToken);
          } else {
            localStorage.setItem('token', newToken);
          }
          
          // 更新原始请求的token
          originalRequest.headers.Authorization = `Bearer ${newToken}`;
          
          // 重试原始请求
          return instance(originalRequest);
        } catch (refreshError) {
          // 刷新token失败，清除本地token并跳转到登录页
          localStorage.removeItem('client_token');
          localStorage.removeItem('token');
          
          // 避免在登录页面显示错误消息
          if (!window.location.pathname.includes('/login')) {
            ElMessage.error('登录已过期，请重新登录');
            
            // 根据当前环境跳转到对应的登录页
            const isTestEnvironment = window.location.pathname.startsWith('/test');
            if (isTestEnvironment) {
              window.location.href = '/test/login';
            } else {
              window.location.href = '/login';
            }
          }
          
          return Promise.reject(error);
        }
      }
      
      // 其他错误处理 - 只在非登录页面显示错误提示
      if (error.response?.data?.detail && !window.location.pathname.includes('/login')) {
        ElMessage.error(error.response.data.detail);
      } else if (!window.location.pathname.includes('/login')) {
        ElMessage.error('请求失败，请稍后重试');
      }
      
      return Promise.reject(error);
    }
  );

  return instance;
};

// 导出动态创建的axios实例
export default createAxiosInstance(); 