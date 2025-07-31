import { fileURLToPath, URL } from 'node:url'

import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig(({ command, mode }) => {
  // 加载环境变量
  const env = loadEnv(mode, process.cwd(), '')
  
  // 根据环境确定端口和主机
  const port = parseInt(env.VITE_APP_PORT) || 80
  // 总是绑定到0.0.0.0以确保外部访问
  const host = '0.0.0.0'
  
  return {
    plugins: [
      vue(),
      vueDevTools(),
    ],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url))
      },
    },
    // 定义环境变量
    define: {
      __APP_ENV__: JSON.stringify(env.VITE_APP_ENV || 'development'),
      __API_BASE_URL__: JSON.stringify(env.VITE_API_BASE_URL || 'http://localhost:8000/api'),
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
          target: env.VITE_API_BASE_URL || 'http://localhost:8000',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, '/api')
        }
      }
    },
    // 构建配置
    build: {
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
