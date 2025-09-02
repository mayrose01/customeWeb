<template>
  <div class="baidu-map-container">
    <div class="map-container">
      <!-- 地图背景 -->
      <div class="map-background">
        <!-- 地图网格 -->
        <div class="map-grid">
          <div class="grid-line horizontal"></div>
          <div class="grid-line horizontal"></div>
          <div class="grid-line horizontal"></div>
          <div class="grid-line vertical"></div>
          <div class="grid-line vertical"></div>
          <div class="grid-line vertical"></div>
        </div>
        
        <!-- 地图标记 -->
        <div class="map-marker">
          <div class="marker-pin"></div>
          <div class="marker-pulse"></div>
        </div>
        
        <!-- 地图信息 -->
        <div class="map-info">
          <h3>{{ companyName }}</h3>
          <p>{{ address }}</p>
          <div class="map-actions">
            <button class="directions-btn" @click="openBaiduMap">
              <span>📍</span>
              在百度地图中查看
            </button>
            <button class="directions-btn secondary" @click="openGaodeMap">
              <span>🗺️</span>
              在高德地图中查看
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BaiduMap',
  props: {
    address: {
      type: String,
      required: true
    },
    companyName: {
      type: String,
      default: '公司位置'
    }
  },
  methods: {
    openBaiduMap() {
      // 打开百度地图导航
      const encodedAddress = encodeURIComponent(this.address)
      window.open(`https://maps.baidu.com/search/${encodedAddress}`, '_blank')
    },
    
    openGaodeMap() {
      // 打开高德地图导航
      const encodedAddress = encodeURIComponent(this.address)
      window.open(`https://uri.amap.com/search?name=${encodedAddress}`, '_blank')
    }
  }
}
</script>

<style scoped>
.baidu-map-container {
  position: relative;
  width: 100%;
  height: 400px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  background: white;
}

.map-container {
  position: relative;
  width: 100%;
  height: 100%;
}

.map-background {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #f8fafc, #e2e8f0);
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.map-grid {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0.3;
}

.grid-line {
  position: absolute;
  background: #cbd5e1;
}

.grid-line.horizontal {
  width: 100%;
  height: 1px;
}

.grid-line.horizontal:nth-child(1) {
  top: 25%;
}

.grid-line.horizontal:nth-child(2) {
  top: 50%;
}

.grid-line.horizontal:nth-child(3) {
  top: 75%;
}

.grid-line.vertical {
  width: 1px;
  height: 100%;
}

.grid-line.vertical:nth-child(4) {
  left: 25%;
}

.grid-line.vertical:nth-child(5) {
  left: 50%;
}

.grid-line.vertical:nth-child(6) {
  left: 75%;
}

.map-marker {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  pointer-events: none;
}

.marker-pin {
  width: 20px;
  height: 20px;
  background: #ef4444;
  border-radius: 50%;
  position: relative;
  border: 3px solid white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.marker-pin::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 8px;
  height: 8px;
  background: white;
  border-radius: 50%;
}

.marker-pulse {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 40px;
  height: 40px;
  background: rgba(239, 68, 68, 0.3);
  border-radius: 50%;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% {
    transform: translate(-50%, -50%) scale(1);
    opacity: 1;
  }
  100% {
    transform: translate(-50%, -50%) scale(2);
    opacity: 0;
  }
}

.map-info {
  position: absolute;
  bottom: 20px;
  left: 20px;
  right: 20px;
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  z-index: 1000;
}

.map-info h3 {
  margin: 0 0 8px 0;
  color: #1e293b;
  font-size: 1.2rem;
  font-weight: 600;
}

.map-info p {
  margin: 0 0 15px 0;
  color: #64748b;
  font-size: 0.95rem;
  line-height: 1.4;
}

.map-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.directions-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 10px 16px;
  border-radius: 8px;
  font-size: 0.9rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.3s;
  font-weight: 500;
}

.directions-btn:hover {
  background: #2563eb;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.directions-btn.secondary {
  background: #10b981;
}

.directions-btn.secondary:hover {
  background: #059669;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .baidu-map-container {
    height: 350px;
  }
  
  .map-info {
    padding: 15px;
  }
  
  .map-info h3 {
    font-size: 1.1rem;
  }
  
  .map-info p {
    font-size: 0.9rem;
  }
  
  .map-actions {
    flex-direction: column;
  }
  
  .directions-btn {
    font-size: 0.85rem;
    padding: 8px 12px;
  }
}

@media (max-width: 480px) {
  .baidu-map-container {
    height: 300px;
  }
  
  .map-info {
    padding: 12px;
  }
  
  .map-info h3 {
    font-size: 1rem;
  }
  
  .map-info p {
    font-size: 0.85rem;
  }
}
</style> 