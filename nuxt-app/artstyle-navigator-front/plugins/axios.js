export default function({ $axios }) {
  $axios.onRequest(config => {
    config.timeout = 5000;
    config.headers.client = window.localStorage.getItem("client")
    config.headers["access-token"] = window.localStorage.getItem("access-token")
    config.headers.uid = window.localStorage.getItem("uid")
    config.headers["token-type"] = window.localStorage.getItem("token-type")
    return config;
  })

  $axios.onResponse(response => {
    if (response.headers.client) {
      localStorage.setItem("access-token", response.headers["access-token"])
      localStorage.setItem("client", response.headers.client)
      localStorage.setItem("uid", response.headers.uid)
      localStorage.setItem("token-type", response.headers["token-type"])
    }
  })

  $axios.onError((error) => {
    if (error.response && error.response.status === 401) {
      console.error('認証エラー:', error.response);
    }
  });
}
