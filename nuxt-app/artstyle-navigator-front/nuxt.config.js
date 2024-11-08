import colors from 'vuetify/es5/util/colors'

export default {
  server: {
    port: 8000,
  },
  env: {
    development: process.env.NODE_ENV === 'development',
  },
  ssr: false,

  router: {
    prefetchLinks: false
  },

  // Global page headers: https://go.nuxtjs.dev/config-head
  head: {
    titleTemplate: '%s - artstyle-navigator-front',
    title: 'artstyle-navigator-front',
    htmlAttrs: {
      lang: 'en',
    },
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: '' },
      { name: 'format-detection', content: 'telephone=no' },
    ],
    link: [{ rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }],
  },

  // Global CSS: https://go.nuxtjs.dev/config-css
  css: [
    '~/assets/sass/main.scss' 
  ],

  // Plugins to run before rendering page: https://go.nuxtjs.dev/config-plugins
  plugins: [
    { src: '~/plugins/vuex-persisted-state.js', ssr: false},
    { src: '~/plugins/authentication.js', ssr: false},
    { src: '~/plugins/my-inject.js', ssr: true},
    { src: '~/plugins/axios.js', ssr: false },
  ],

  // Auto import components: https://go.nuxtjs.dev/config-components
  components: true,

  // Modules for dev and build (recommended): https://go.nuxtjs.dev/config-modules
  buildModules: [
    // https://go.nuxtjs.dev/eslint
    '@nuxtjs/eslint-module',
    // https://go.nuxtjs.dev/vuetify
    '@nuxtjs/vuetify',
  ],

  // Modules: https://go.nuxtjs.dev/config-modules
  modules: [
    // https://go.nuxtjs.dev/axios
    '@nuxtjs/axios',
    '@nuxtjs/auth',
    'cookie-universal-nuxt',
    // 'nuxt-client-init-module',
  ],

  // Axios module configuration: https://go.nuxtjs.dev/config-axios
  axios: {
    // Workaround to avoid enforcing hard-coded localhost:3000: https://github.com/nuxt-community/axios-module/issues/308
    // baseURL: '/', を変更
    baseURL: 'http://localhost:3000',
    credentials: true,
  },

  // Vuetify module configuration: https://go.nuxtjs.dev/config-vuetify
  vuetify: {
    customVariables: ['~/assets/sass/variables.scss'],
    treeShake: true,
    theme: {
      dark: false,
      themes: {
        dark: {
          primary: colors.blue.darken2,
          accent: colors.grey.darken3,
          secondary: colors.amber.darken3,
          info: colors.teal.lighten1,
          warning: colors.amber.base,
          error: colors.deepOrange.accent4,
          success: colors.green.accent3,
        },
      },
    },
  },

  // Build Configuration: https://go.nuxtjs.dev/config-build
  build: {},

  // auth オプションを記載
  auth: {
    // plugins: [ { src: '~/plugins/axios', ssr: false } ],
    localStorage: false,
    redirect: {
      login: '/',
      logout: '/',
      callback: false,
      home: '/'
    },
    strategies: {
      local: {
        token: {
          property: 'access-token',
        },
        user: {
          property: 'user',
          autoFetch: false
        },
        endpoints: {
          login: { url: '/api/v1/auth/sign_in', method: 'post' },
          logout: { url: '/api/v1/auth/sign_out', method: 'delete' },
          refresh: { url: '/api/v1/sessions/refresh', method: 'post' },
          // user エンドポイントを設定する
          // user: {url: '/api/v1/auth/validate_token', method: 'get', propertyName: false}
          user: false
        },
      }
    },
  }
}
