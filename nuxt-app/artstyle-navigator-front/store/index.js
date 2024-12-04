const homePath = 'artStyleMain'

export const state = () => ({
  user: {
    current: null
  },
  authentication: {
    token: null,
    expires: 0,
    payload: {}
  },
  styles: {
    homeAppBarHeight: 56
  },
  loggedIn: {
    homePath: {
      name: homePath
    },
    // ログイン前ユーザーがアクセスしようとしたルートを記憶(記憶ルート)
    rememberPath: {
      name: homePath,
      params: {}
    },
    // ログイン後のアクセス不可ルート一覧(= ログイン前だけアクセスできるルート一覧)
    redirectPaths: [
      'index',  // ('/')
      'signup', // (新規登録画面)
      'login'   // (ログイン画面)
    ]
  },
  project: {
    current: null,
    // Rails から取得するプロジェクトに書き換える。
    list: []
  },
  toast: {
    msg: null,
    color: 'error',
    timeout: 4000
  }
})

export const getters = {

}

export const mutations = {
  // SET_USER(state, payload) {
  //   state.user = payload
  // },
  setCurrentUser (state, payload) {
    state.user.current = payload
  },
  setAuthToken (state, payload) {
    state.authentication.token = payload
  },
  setAuthExpires (state, payload) {
    state.authentication.expires = payload
  },
  setAuthPayload (state, payload) {
    state.authentication.payload = payload
  },
  setProjectList (state, payload) {
    state.project.list = payload
  },
  setCurrentProject (state, payload) {
    state.project.current = payload
  },
  setToast (state, payload) {
    state.toast = payload
  },
  setRemeberPath (state, payload) {
    state.loggedIn.rememberPath = payload
  }
}

export const actions = {
  // async fetchUser({ commit }) {
  //   try {
  //     const response = await this.$axios.$get('/api/v1/auth/validate_token') // ユーザー情報の取得APIエンドポイント
  //     commit('SET_USER', response.data)
  //   } catch(error) {
  //     console.error('Error fetch user', error)
  //     commit('SET_USER', null)
  //   }
  // },
  getCurrentUser({ commit }, user) {
    commit('setCurrentUser', user)
  },
  getAuthToken({ commit }, token) {
    commit('setAuthToken', token)
  },
  getAuthExpires ({ commit }, expires) {
    expires = expires || 0
    commit('setAuthExpires', expires)
  },
  getAuthPayload ({ commit }, jwtPayload) {
    jwtPayload = jwtPayload || {}
    commit('setAuthPayload', jwtPayload)
  },
  getProjectList({ commit }, projects) {
    projects = projects || []
    commit('setProjectList', projects)
  },
  getCurrentProject ({ state, commit }, params) {
    let currentProject = null
    if (params && params.id) {
      const id = Number(params.id)
      currentProject = state.project.list.find(project => project.id === id) || null
    }
    commit('setCurrentProject', currentProject)
  },
  getToast({ commit }, { msg, color, timeout }) {
    color = color || 'error'
    timeout = timeout || 4000
    commit('setToast', { msg, color, timeout })
  },
  // ログイン前ユーザーがアクセスしたルートを記憶する
  getRememberPath({ state, commit }, { name, params }) {
    // ログイン前のパスが渡された場合は loggedIn.homepath に書き換える
    if (state.loggedIn.redirectPaths.includes(name)){
      name = state.loggedIn.homePath.name // artStyleMain
    }
      params = params || {}
      commit('setRemeberPath', { name, params })
  }
}
