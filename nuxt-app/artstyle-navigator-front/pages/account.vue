<template>
  <v-container>
    <!-- この nuxt-child コンポーネントの位置に password.vue, settings.vue が表示される -->
    <nuxt-child />
  </v-container>
</template>

<script>
  export default {
    // 共通レイアウト
    layout: 'logged-in',
    // false を返すページのアクセスを制限する
    // (ルート名 === 'account') => バリデーション: false => ページアクセス不可
    validate ({ route }) {
      return route.name !== 'account'
    }
  }
</script>