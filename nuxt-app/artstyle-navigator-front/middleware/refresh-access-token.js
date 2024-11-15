export default async ({ $authentication, $axios, store, route, redirect, isDev }) => {
  console.log('リフレッシュミドルウェアが呼ばれました');  // デバッグログ

  if ($authentication.loggedIn()) {
    console.log('アクセストークンリフレッシュファイル起動！')
    if (isDev) {
      console.log('Execute silent refresh!!')
    }
    await $axios.$post('/api/v1/sessions/refresh')
      .then(response => {
        $authentication.updateTokens(response)
      })
      .catch(() => {
        const msg = 'セッションの有効期限が切れました。' +
                    'もう一度ログインしてください'
        // TODO test
        console.log(msg)
        // TODO トースター出力
        // store.dispatch('getToast', { msg })
        // TODO アクセスルート記憶
        // store.dispatch('getRememberPath', route)
        // Vuexの初期化(セッションはサーバで削除済み)
        $authentication.resetVuex()
        window.localStorage.removeItem('persisted-key');
        return redirect('/login')
      })
  }
}