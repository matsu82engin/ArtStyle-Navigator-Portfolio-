export default async ({ $auth, $authentication, $axios, store, route, redirect, isDev, $cookies }) => {
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
        // トースター出力
        const msg = 'セッションの有効期限が切れました。' +
        'もう一度ログインしてください'
        store.dispatch('getToast', { msg })

        // アクセスルート記憶
        store.dispatch('getRememberPath', route)

        // ログアウト + Vuexの初期化(セッションはサーバで削除済み)
        $auth.logout();
        $cookies.removeAll(); // クッキー完全削除
        window.localStorage.removeItem('persisted-key');
        // localStorage.clear(); // 全てのローカルストレージをクリア
        $authentication.resetVuex();
        return redirect('/login');
      })
  }
}
