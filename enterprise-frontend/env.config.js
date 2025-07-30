// 环境配置
const envConfig = {
  // 本地开发环境
  development: {
    API_BASE_URL: 'http://localhost:8000/api',
    APP_ENV: 'development'
  },
  
  // 测试环境
  test: {
    API_BASE_URL: 'http://localhost:8001/api',
    APP_ENV: 'test'
  },
  
  // 生产环境
  production: {
    API_BASE_URL: 'https://catusfoto.top/api',
    APP_ENV: 'production'
  }
};

// 获取当前环境
const getCurrentEnv = () => {
  // 优先使用环境变量
  if (import.meta.env.VITE_APP_ENV) {
    return import.meta.env.VITE_APP_ENV;
  }
  
  // 根据域名和端口判断环境
  const hostname = window.location.hostname;
  const port = window.location.port;
  
  if (hostname === 'localhost' || hostname === '127.0.0.1') {
    // 如果是端口3001，则认为是测试环境
    if (port === '3001') {
      return 'test';
    }
    return 'development';
  } else if (hostname.includes('test.')) {
    return 'test';
  } else {
    return 'production';
  }
};

// 获取当前环境的配置
const getConfig = () => {
  const currentEnv = getCurrentEnv();
  return envConfig[currentEnv] || envConfig.development;
};

// 导出配置
export const config = getConfig();
export const API_BASE_URL = config.API_BASE_URL;
export const APP_ENV = config.APP_ENV;

// 导出环境配置对象
export default envConfig; 