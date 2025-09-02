<template>
  <div class="orders-page">
    <ClientHeader />

    <main class="main-content">
      <div class="container">
        <div class="page-header">
          <h1>我的订单</h1>
        </div>

        <div v-if="loading" class="loading">
          加载中...
        </div>

        <div v-else>
          <div v-if="orders.length === 0" class="empty">
            暂无订单
          </div>
          <div v-else class="order-list">
            <div class="order-item" v-for="order in orders" :key="order.id" @click="viewDetail(order)">
              <div class="row">
                <div class="col">
                  <div class="label">订单号</div>
                  <div class="value">{{ order.order_no }}</div>
                </div>
                <div class="col">
                  <div class="label">状态</div>
                  <div class="value">{{ statusText(order) }}</div>
                </div>
                <div class="col">
                  <div class="label">金额</div>
                  <div class="value price">¥{{ order.total_amount }}</div>
                </div>
                <div class="col">
                  <div class="label">创建时间</div>
                  <div class="value">{{ formatTime(order.created_at) }}</div>
                </div>
              </div>
              <div class="items" v-if="order.items && order.items.length">
                <div class="item" v-for="it in order.items" :key="it.id">
                  <span>{{ it.product_title }}</span>
                  <span class="muted">x{{ it.quantity }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <ClientFooter />
  </div>
  
</template>

<script>
import { ref, onMounted } from 'vue'
import ClientHeader from '@/components/client/Header.vue'
import ClientFooter from '@/components/client/Footer.vue'
import { userStore } from '@/store/user'
import { getUserOrders } from '@/api/order'
import { ElMessage } from 'element-plus'

export default {
  name: 'ClientOrders',
  components: { ClientHeader, ClientFooter },
  setup() {
    const loading = ref(false)
    const orders = ref([])

    const loadOrders = async () => {
      if (!userStore.isLoggedIn) {
        ElMessage.warning('请先登录')
        window.location.href = '/login'
        return
      }
      try {
        loading.value = true
        const res = await getUserOrders(userStore.userInfo.id, { page: 1, page_size: 20 })
        orders.value = res.data.items || []
      } catch (e) {
        console.error('加载订单失败', e)
      } finally {
        loading.value = false
      }
    }

    const statusText = (order) => {
      if (order.payment_status === 'paid') return '已支付/待发货'
      return '待付款'
    }

    const formatTime = (t) => {
      if (!t) return '-'
      try { return new Date(t).toLocaleString() } catch { return t }
    }

    const viewDetail = (order) => {
      // 可跳转到订单详情页，暂留
    }

    onMounted(loadOrders)

    return { loading, orders, statusText, formatTime, viewDetail }
  }
}
</script>

<style scoped>
.main-content { padding: 120px 0 60px; }
.container { max-width: 900px; margin: 0 auto; padding: 0 20px; }
.page-header { margin-bottom: 20px; }
.order-list { display: flex; flex-direction: column; gap: 12px; }
.order-item { background: #fff; border: 1px solid #eee; border-radius: 8px; padding: 16px; cursor: pointer; }
.row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
.label { color: #888; font-size: 12px; }
.value { font-weight: 600; }
.value.price { color: #d43; }
.items { margin-top: 10px; display: flex; gap: 10px; flex-wrap: wrap; }
.item { background: #f7f7f7; border-radius: 4px; padding: 4px 8px; font-size: 12px; }
.muted { color: #888; margin-left: 4px; }
.empty { color: #999; text-align: center; padding: 40px 0; }
.loading { text-align: center; padding: 40px; }
</style>


