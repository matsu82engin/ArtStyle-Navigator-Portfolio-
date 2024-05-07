<template>
  <div>
    <h1>This is the about page</h1>
    <h2>ログイン状態: {{ this.$auth.loggedIn }}</h2>
    <h2>ログインユーザー情報: {{ this.$auth.user }}</h2>
    <h2>state情報: {{ this.$store.state.auth.user }}</h2>
    <p v-if="this.$auth.loggedIn">トークン: {{this.$auth.getToken('local')}}</p>
  </div>
</template>
