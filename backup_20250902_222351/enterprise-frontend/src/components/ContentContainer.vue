<template>
  <div class="content-container">
    <slot />
  </div>
</template>

<script setup>
// 这是一个通用的内容容器组件
</script>

<style scoped>
.content-container {
  min-height: 100%;
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: none;
  overflow: visible;
  box-sizing: border-box;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .content-container {
    padding: 15px;
  }
}

@media (max-width: 768px) {
  .content-container {
    padding: 10px;
  }
}
</style> 