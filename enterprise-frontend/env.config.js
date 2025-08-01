// 环境配置
const envConfig = {
  // 本地开发环境
  development: {
    API_BASE_URL: 'http://localhost:8000/api',
    APP_ENV: 'development',
    UPLOAD_PATH: '/uploads',
    PUBLIC_PATH: '/'
  },
  
  // 测试环境
  test: {
    API_BASE_URL: 'http://localhost:8001/api',
    APP_ENV: 'test',
    UPLOAD_PATH: '/uploads',
    PUBLIC_PATH: '/'
  },
  
  // 生产环境
  production: {
    API_BASE_URL: 'https://catusfoto.top/api',
    APP_ENV: 'production',
    UPLOAD_PATH: '/uploads',
    PUBLIC_PATH: '/'
  }
};

// 获取当前环境 - 基于域名和端口的可靠判断
const getCurrentEnv = () => {
  // 1. 使用环境变量（最高优先级）
  if (import.meta.env.VITE_APP_ENV) {
    console.log('使用环境变量 VITE_APP_ENV:', import.meta.env.VITE_APP_ENV);
    return import.meta.env.VITE_APP_ENV;
  }
  
  // 2. 检查是否在构建环境中（SSR或构建时）
  if (typeof window === 'undefined') {
    // 构建时环境，使用默认环境变量
    console.log('构建时环境，使用默认配置');
    return 'production'; // 构建时默认为生产环境
  }
  
  // 3. 基于域名和端口判断环境（仅在浏览器中）
  const hostname = window.location.hostname;
  const port = window.location.port;
  console.log('环境判断 - hostname:', hostname, 'port:', port);
  
  if (hostname === 'localhost' || hostname === '127.0.0.1') {
    if (port === '3000') {
      console.log('检测到开发环境 (localhost:3000)');
      return 'development';
    } else if (port === '3001') {
      console.log('检测到测试环境 (localhost:3001)');
      return 'test';
    } else {
      console.log('检测到开发环境 (localhost)');
      return 'development';
    }
  } else if (hostname === 'test.catusfoto.top') {
    console.log('检测到测试环境 (test.catusfoto.top)');
    return 'test';
  } else if (hostname === 'catusfoto.top') {
    console.log('检测到生产环境 (catusfoto.top)');
    return 'production';
  } else {
    // 其他域名默认为生产环境
    console.log('检测到生产环境 (其他域名)');
    return 'production';
  }
};

// 获取当前环境的配置 - 动态获取，每次调用都重新检测
const getConfig = () => {
  const currentEnv = getCurrentEnv();
  console.log('当前环境:', currentEnv);
  
  // 优先使用环境变量，如果没有则使用默认配置
  const config = {
    API_BASE_URL: import.meta.env.VITE_API_BASE_URL || envConfig[currentEnv]?.API_BASE_URL || envConfig.development.API_BASE_URL,
    APP_ENV: import.meta.env.VITE_APP_ENV || envConfig[currentEnv]?.APP_ENV || envConfig.development.APP_ENV,
    UPLOAD_PATH: import.meta.env.VITE_UPLOAD_PATH || envConfig[currentEnv]?.UPLOAD_PATH || envConfig.development.UPLOAD_PATH,
    PUBLIC_PATH: import.meta.env.VITE_PUBLIC_PATH || envConfig[currentEnv]?.PUBLIC_PATH || envConfig.development.PUBLIC_PATH
  };
  
  console.log('当前配置:', config);
  return config;
};

// 导出动态配置函数
export const getCurrentConfig = getConfig;

// 导出当前配置（兼容性）
export const config = getConfig();
export const API_BASE_URL = config.API_BASE_URL;
export const APP_ENV = config.APP_ENV;
export const UPLOAD_PATH = config.UPLOAD_PATH;
export const PUBLIC_PATH = config.PUBLIC_PATH;

// 导出环境配置对象
export default envConfig; 