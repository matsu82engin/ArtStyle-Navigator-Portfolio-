import createPersistedState from 'vuex-persistedstate';

export default ({ store }) => {
  createPersistedState({
    key: 'persisted-key',
    storage: window.localStorage,
    paths: ['user', 'loggedIn', 'project']
  })(store);
};
