let isRedirecting = false // グローバルな防止フラグ

export default async ({ $auth, $authentication, $axios, store, route, redirect, isDev, $cookies }) => {
  if (isRedirecting || route.path === '/login') return

  // トークンが "期限切れ寸前" のときのみリフレッシュ実行
  if ($authentication.loggedIn()) {
    try {
      if (isDev) {
        console.log('アクセストークンリフレッシュ開始')
      }
      const response = await $axios.$post('/api/v1/sessions/refresh')
      $authentication.updateTokens(response)
    } catch (err) {
      console.warn('アクセストークンのリフレッシュに失敗しました')

      isRedirecting = true
      const msg = 'セッションの有効期限が切れました。もう一度ログインしてください'
      store.dispatch('getToast', { msg })
      store.dispatch('getRememberPath', route)

      // 強制ログアウト処理（Vuex, Cookie, localStorage 全初期化）
      await $auth.logout()
      $authentication.resetVuex()
      // localStorage.clear() 個別に消すほうがベストプラクティスとのこと。
      window.localStorage.removeItem('persisted-key');
      // $cookies.removeAll() 個別に消すほうがベストプラクティスとのこと。
      $cookies.remove('access-token');
      $cookies.remove('uid');
      $cookies.remove('client');
      $cookies.remove('token-type');
      $cookies.remove('refresh_token');
      // 再度リダイレクトさせないための回避策
      if (route.path !== '/login') {
        return redirect('/login')
      }
    }
  }
}
