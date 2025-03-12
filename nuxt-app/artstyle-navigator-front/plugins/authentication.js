import jwtDecode from 'jwt-decode'

class Authentication {
  constructor (ctx) {
    this.store = ctx.store
    this.$axios = ctx.$axios
  }

  get token () {
    return this.store.state.authentication.token
  }

  get expires () {
    return this.store.state.authentication.expires
  }

  get payload () {
    return this.store.state.authentication.payload
  }

  get user () {
    return this.store.state.user.current || {}
  }

  // 認証情報をVuexに保存する
  setAuth ({ token, expires, user }) {
    const exp = new Date(expires).getTime();
    const jwtPayload = (token) ? jwtDecode(token) : {}

    this.store.dispatch('getAuthToken', token)
    this.store.dispatch('getAuthExpires', exp)
    this.store.dispatch('getCurrentUser', user)
    this.store.dispatch('getAuthPayload', jwtPayload)
  }

  loginAdd(response) {
    // response.data から token, expires, user を取得
    const { token, expires, user } = response.data;  
    this.setAuth({ token, expires, user });
  }

  updateTokens(response) {
    const { token, expires, user } = response;  
    this.setAuth({ token, expires, user });
  }

  // auth モジュールの $auth.logout で対応しない Vuex 部分を初期値に戻す
  resetVuex () {
    // デバッグ用
    // console.log('resetVuex called');
    this.store.dispatch('getCurrentProject', null)
    this.store.dispatch('getProjectList', [])
    this.store.dispatch('getAuthToken', null)
    this.store.dispatch('getAuthExpires', null)
    this.store.dispatch('getCurrentUser', null)
    this.store.dispatch('getAuthPayload', null)
    this.store.dispatch('getProfileUser', null)
  }

  // axios のレスポンス 401 を許容する
  // resolveUnauthorized(status) {
  //   return (status >= 200 && status < 300) || (status === 401)
  // }

  // ログアウト業務
  logoutAdd() {
    // デバッグ用
    console.log('logoutAdd called');
    this.resetVuex()
  }

  // 有効期限が一定の時間以内(1週間)なら true を返す
  // plugins ファイルだと Vuex の値が取得できないため、vuex-persiistedstate で localStorage から取得
  checkRefreshTokenExpiry() {
    // セッションストレージから特定のキー(persisted-key)で保存されたデータを取得する。ない場合は空の配列
    const data = JSON.parse(localStorage.getItem('persisted-key')) || [];
    const currentTime = new Date().getTime()  // 現在の時刻をミリ秒で取得
    console.log(currentTime); // デバッグ用
    const remainingTime = data.authentication.expires - currentTime; // 有効期限までの残り時間（ミリ秒)
    console.log(remainingTime); // デバッグ用
    // return remainingTime <= 50 * 1000;  // 動作確認用。50秒未満ならtrue
    return remainingTime <= 7 * 24 * 60 * 60 * 1000;  // 1週間未満ならtrue
  }

  isExistUser() {
    const data = JSON.parse(localStorage.getItem('persisted-key')) || [];
    // console.log(data); // デバッグ用
    if (data.user && data.user.current) {
      // console.log(data.user.current); // デバッグ用
      return true;
    }
    console.log('None');
    return false;
  }

  loggedIn () {
    return this.isExistUser() && this.checkRefreshTokenExpiry()
  }
}

export default ({ store, $axios }, inject) => {
  inject('authentication', new Authentication({ store, $axios }))
}
