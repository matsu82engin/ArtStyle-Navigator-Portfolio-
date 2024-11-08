import Cookies from 'js-cookie'

export default function({ $axios }) {
  $axios.onRequest(config => {
    config.timeout = 8000;
    config.headers.common['X-Requested-With'] = 'XMLHttpRequest'
    // クッキーからトークンを取得してリクエストヘッダーにセット
    config.headers.client = Cookies.get('client');
    config.headers['access-token'] = Cookies.get('access-token');
    config.headers.uid = Cookies.get('uid');
    config.headers['token-type'] = Cookies.get('token-type');

    return config;
  })

  $axios.onResponse(response => {
    if (response.headers.client) {
      Cookies.set('access-token', response.headers['access-token'], { secure: true, sameSite: 'None' });
      Cookies.set('client', response.headers.client, { secure: true, sameSite: 'None' });
      Cookies.set('uid', response.headers.uid, { secure: true, sameSite: 'None' });
      Cookies.set('token-type', response.headers['token-type'], { secure: true, sameSite: 'None' });
    }
  })

  $axios.onError((error) => {
    if (error.response && error.response.status === 401) {
      console.error('認証エラー:', error.response);
    }
  });
}