export default ({ $auth, store, route, redirect }) => {
  // リダイレクトを必要としないパス
  const notRedirectPaths = ['account', 'project']
  if (notRedirectPaths.includes(route.name)) {
    return false
  }

  // ログイン前ユーザー処理
  if (!$auth.loggedIn) {
    const msg = ['まずはログインしてください']
    const color = 'info'
    console.log(msg, color)
    // トースター出力
    store.dispatch('getToast', { msg, color })
    // アクセスルート記憶
    store.dispatch('getRememberPath', route)
    console.log('Authenticate middleware called'); // デバック用
    return redirect('/login')
  }
}