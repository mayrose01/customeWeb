/**
 * 路径工具函数
 * 用于根据当前环境生成正确的路由路径
 */

// 检测当前环境
export const isTestEnvironment = () => {
  return window.location.pathname.startsWith('/test')
}

/**
 * 根据环境生成路径
 * @param {string} path - 基础路径，如 '/about', '/login'
 * @returns {string} 根据环境生成的完整路径
 */
export const getPath = (path) => {
  if (isTestEnvironment()) {
    // 确保路径以 / 开头
    const cleanPath = path.startsWith('/') ? path : `/${path}`
    return `/test${cleanPath}`
  }
  return path
}

/**
 * 获取客户端路径
 * @param {string} path - 基础路径
 * @returns {string} 客户端路径
 */
export const getClientPath = (path) => {
  return getPath(path)
}

/**
 * 获取管理后台路径
 * @param {string} path - 基础路径
 * @returns {string} 管理后台路径
 */
export const getAdminPath = (path) => {
  const basePath = path.startsWith('/admin') ? path : `/admin${path}`
  return getPath(basePath)
}

/**
 * 获取当前环境的根路径
 * @returns {string} 根路径
 */
export const getRootPath = () => {
  return isTestEnvironment() ? '/test' : '/'
} 