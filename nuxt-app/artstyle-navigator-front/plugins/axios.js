import Cookies from 'js-cookie'

export default function({ $axios, isDev }) {
  $axios.onRequest(config => {
    config.timeout = 30000;
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
    if (response.headers.client && response.headers['access-token'] && response.headers.uid && response.headers['token-type']) {
      const isDev = process.env.NODE_ENV !== 'production';

      Cookies.set('access-token', response.headers['access-token'], { 
        secure: !isDev, // 本番では secure: true
        sameSite: isDev ? 'Lax' : 'None' // 開発ではLax、本番ではNone
      });
      Cookies.set('client', response.headers.client, { 
        secure: !isDev, 
        sameSite: isDev ? 'Lax' : 'None' 
      });
      Cookies.set('uid', response.headers.uid, { 
        secure: !isDev, 
        sameSite: isDev ? 'Lax' : 'None' 
      });
      Cookies.set('token-type', response.headers['token-type'], { 
        secure: !isDev, 
        sameSite: isDev ? 'Lax' : 'None' 
      });
    }
    if (isDev) {
      console.log(response);
    }
  })

  $axios.onError((error) => {
    if (isDev) {
      console.error('エラーが発生しました:', error);
      console.error('エラーレスポンス:', error.response);
    }
  });
}