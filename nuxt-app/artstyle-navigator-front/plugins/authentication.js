class Authentication {
  constructor (ctx) {
    this.store = ctx.store
    this.$axios = ctx.$axios
  }

  get user () {
    return this.store.state.user.current || {}
  }

  loginAdd(response) {
    const user = response.data && response.data.user
    this.store.dispatch('getCurrentUser', user)
    if (this.$auth && user) {
      this.$auth.setUser(user)
    }
  }

  resetVuex () {
    this.store.dispatch('getCurrentProject', null)
    this.store.dispatch('getProjectList', [])
    this.store.dispatch('getCurrentUser', null)
    this.store.dispatch('getProfileUser', null)
  }

  logoutAdd() {
    this.resetVuex()
  }
}

export default ({ store, $axios }, inject) => {
  inject('authentication', new Authentication({ store, $axios }))
}
