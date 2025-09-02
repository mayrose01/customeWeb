// 图片URL处理工具
import { API_BASE_URL } from '../../env.config.js'

/**
 * 将相对路径转换为完整的图片URL
 * @param {string} imagePath - 相对路径，如 "/uploads/xxx.jpg"
 * @returns {string} 完整的图片URL
 */
export function getImageUrl(imagePath) {
  if (!imagePath) {
    return ''
  }
  
  // 如果已经是完整URL，直接返回
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath
  }
  
  // 确保路径以 / 开头
  const path = imagePath.startsWith('/') ? imagePath : `/${imagePath}`
  
  // 根据环境构建完整URL
  if (API_BASE_URL.startsWith('/')) {
    // 生产环境：使用相对路径
    return path
  } else {
    // 开发/测试环境：使用完整URL
    const baseUrl = API_BASE_URL.replace('/api', '')
    return `${baseUrl}${path}`
  }
}

/**
 * 获取产品图片列表的完整URL
 * @param {Array} images - 图片路径数组
 * @returns {Array} 完整URL数组
 */
export function getProductImages(images) {
  if (!images || !Array.isArray(images)) return []
  
  return images.map(imagePath => getImageUrl(imagePath))
} 