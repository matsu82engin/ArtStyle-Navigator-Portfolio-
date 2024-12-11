import Cookies from 'js-cookie'

export default function({ $axios, isDev }) {
  $axios.onRequest(config => {
    config.timeout = 5000;
    config.headers.common['X-Requested-With'] = 'XMLHttpRequest'
    config.headers.client = Cookies.get('client');
    config.headers['access-token'] = Cookies.get('access-token');
    config.headers.uid = Cookies.get('uid');
    config.headers['token-type'] = Cookies.get('token-type');

    // 開発環境の場合のみログを出力
    if (isDev) {
      console.log(config);
    }

    return config;
  })

  $axios.onResponse(response => {
    if (response.headers.client) {
      Cookies.set('access-token', response.headers['access-token'], { secure: true, sameSite: 'None' });
      Cookies.set('client', response.headers.client, { secure: true, sameSite: 'None' });
      Cookies.set('uid', response.headers.uid, { secure: true, sameSite: 'None' });
      Cookies.set('token-type', response.headers['token-type'], { secure: true, sameSite: 'None' });
    }
    if (isDev) {
      console.log(response);
    }
  })

  $axios.onError((error) => {
    if (error.response && error.response.status === 401) {
      console.error('認証エラー:', error.response);
    }
  });
}