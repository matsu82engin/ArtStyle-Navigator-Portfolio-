class Authentication {
  constructor (ctx) {
    this.store = ctx.store
    this.$axios = ctx.$axios
  }

  // auth モジュールの $auth.logout で対応しない Vuex 部分を初期値に戻す
  resetVuex () {
    // デバッグ用
    // console.log('resetVuex called');
    this.store.dispatch('getCurrentProject', null)
    this.store.dispatch('getProjectList', [])
  }

  // axios のレスポンス 401 を許容する
  // resolveUnauthorized(status) {
  //   return (status >= 200 && status < 300) || (status === 401)
  // }

  // ログアウト業務
  logoutAdd() {
    // デバッグ用
    // console.log('logoutAdd called');
    this.resetVuex()
  }
}

export default ({ store, $axios }, inject) => {
  inject('authentication', new Authentication({ store, $axios }))
}
