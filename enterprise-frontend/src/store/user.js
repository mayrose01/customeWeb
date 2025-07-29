import { reactive, ref } from 'vue';

export const userStore = reactive({
  username: '',
  isLoggedIn: false,
  userInfo: null,
  
  setUsername(name) {
    this.username = name;
  },
  
  setUserInfo(user) {
    this.userInfo = user;
    this.username = user.username;
    this.isLoggedIn = true;
  },
  
  clearUserInfo() {
    this.userInfo = null;
    this.username = '';
    this.isLoggedIn = false;
  },
  
  // 检查用户是否已登录
  checkLoginStatus() {
    const token = localStorage.getItem('client_token');
    const userStr = localStorage.getItem('client_user');
    
    if (token && userStr) {
      try {
        const user = JSON.parse(userStr);
        this.setUserInfo(user);
        return true;
      } catch (error) {
        console.error('解析用户信息失败:', error);
        this.clearUserInfo();
        return false;
      }
    } else {
      this.clearUserInfo();
      return false;
    }
  },
  
  // 登录
  login(userData) {
    this.setUserInfo(userData);
  },
  
  // 登出
  logout() {
    localStorage.removeItem('client_token');
    localStorage.removeItem('client_user');
    this.clearUserInfo();
  }
});

// 初始化时检查登录状态
userStore.checkLoginStatus(); 