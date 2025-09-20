import { fileURLToPath, URL } from 'node:url'

import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig(({ command, mode }) => {
  // 加载环境变量
  const env = loadEnv(mode, process.cwd(), '')
  
  // 根据环境确定端口和主机
  let port = parseInt(env.VITE_APP_PORT) || 80
  if (mode === 'test') {
    port = 3001  // 测试环境固定使用3001端口
  } else if (mode === 'development') {
    port = 3000  // 开发环境使用3000端口
  }
  // 总是绑定到0.0.0.0以确保外部访问
  const host = '0.0.0.0'
  
  // 根据环境确定默认API地址
  const getDefaultApiUrl = () => {
    if (mode === 'production') {
      return 'https://catusfoto.top/api'
    } else if (mode === 'test') {
      return 'http://localhost:8001/api'
    } else {
      return 'http://localhost:8000/api'
    }
  }
  
  return {
    plugins: [
      vue(),
      // 只在开发环境启用devtools
      ...(mode === 'development' ? [vueDevTools()] : []),
    ],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url))
      },
    },
    // 定义环境变量
    define: {
      __APP_ENV__: JSON.stringify(env.VITE_APP_ENV || 'development'),
      __API_BASE_URL__: JSON.stringify(env.VITE_API_BASE_URL || getDefaultApiUrl()),
    },
    // 开发服务器配置
    server: {
      host: '0.0.0.0',
      port: port,
      cors: true,
      strictPort: false,
      allowedHosts: 'all',
      proxy: {
        '/api': {
          target: env.VITE_API_BASE_URL || getDefaultApiUrl(),
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, '')
        }
      }
    },
    // 构建配置
    build: {
      base: '/',
      outDir: 'dist',
      assetsDir: 'assets',
      sourcemap: mode === 'development',
      rollupOptions: {
        output: {
          manualChunks: {
            vendor: ['vue', 'vue-router'],
            elementPlus: ['element-plus']
          }
        }
      }
    }
  }
})
