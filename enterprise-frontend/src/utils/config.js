// 环境配置工具
export const getApiBaseUrl = () => {
  // 如果在浏览器环境中
  if (typeof window !== 'undefined') {
    const hostname = window.location.hostname
    const port = window.location.port
    
    if (hostname === 'localhost' && port === '3001') {
      return 'http://localhost:8001/api'
    } else if (hostname === 'localhost' && (port === '3000' || port === '3002' || port === '3003' || port === '3004' || port === '3005')) {
      return 'http://localhost:8000/api'
    } else if (hostname === 'test.catusfoto.top') {
      return 'http://localhost:8001/api'
    } else if (hostname === 'catusfoto.top') {
      return 'https://catusfoto.top/api'
    } else {
      // 默认使用开发环境
      return 'http://localhost:8000/api'
    }
  }
  
  // 如果不在浏览器环境中，返回默认值
  return 'http://localhost:8000/api'
}

export const getUploadUrl = () => {
  return `${getApiBaseUrl()}/upload`
}

export const getImageUrl = (imagePath) => {
  if (!imagePath) return ''
  
  // 如果已经是完整URL，直接返回
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath
  }
  
  // 如果是相对路径，拼接完整URL
  if (imagePath.startsWith('/')) {
    return `${getApiBaseUrl().replace('/api', '')}${imagePath}`
  }
  
  // 如果是文件名，拼接uploads路径
  return `${getApiBaseUrl().replace('/api', '')}/uploads/${imagePath}`
}
