// 图片URL处理工具
const API_BASE_URL = 'http://localhost:8000'

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
  const fullUrl = `${API_BASE_URL}${path}`
  
  return fullUrl
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