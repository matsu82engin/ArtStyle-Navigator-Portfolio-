<template>
  <div>
    <h1>This is the about page</h1>
    <h2>ログイン状態: {{ this.$auth.loggedIn }}</h2>
    <h2>ログインユーザー情報: {{ this.$auth.user }}</h2>
  </div>
</template>
