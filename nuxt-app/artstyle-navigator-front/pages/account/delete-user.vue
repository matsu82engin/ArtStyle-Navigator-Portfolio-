<template>
  <div>
  <v-row>
      <v-spacer />

      <v-col cols="12" lg="4">
        <v-row>
          <v-col
            cols="12"
            lg="7"
            class="grey--text text--darken-3 font-weight-bold pa-2 text-h6"
          >
            <p>
              アカウント設定
            </p>
          </v-col>
        </v-row>

        <v-divider />
        <v-row class="my-5">
          <v-col cols="12" lg="7" class="pa-2">
            <a
              href="#"
              class="red--text text--darken-3 mb-1"
              @click="deleteUser"
            >
              退会
            </a>
          </v-col>
          <v-col cols="12" lg="5" class="pa-2 text-right">
            <!-- <font-awesome-icon icon="angle-right" /> -->
          </v-col>
        </v-row>
      </v-col>
      <v-spacer />
    </v-row>
  </div>
</template>

<script>
export default {
  layout: 'logged-in',
  name: 'deleteUser',
  data: () => ({}),
  methods: {
    deleteUser() {
      this.$axios.delete('api/v1/auth', {
      })
      .then(() => {
        // TODO 退会時にクッキーとVuex($auth)の状態をクリアする必要がある。
        this.$router.push('/') // ルーターを使ってリダイレクト
      })
      .catch((error) => {
        console.error('ログアウトエラー:', error)
        // エラーメッセージの表示や適切なエラー処理を実装
      })
    },
  },
}
</script>