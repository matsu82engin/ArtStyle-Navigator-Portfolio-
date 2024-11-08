import createPersistedState from 'vuex-persistedstate';

export default ({ store }) => {
  window.onNuxtReady(() => {
    createPersistedState({
      key: 'persisted-key', 
      storage: window.localStorage, 
    })(store);
  });
};
