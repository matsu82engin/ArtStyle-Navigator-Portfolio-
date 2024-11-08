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
    }
  },
  project: {
    current: null,
    // Rails から取得するプロジェクトに書き換える。
    list: []
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
  }
}
