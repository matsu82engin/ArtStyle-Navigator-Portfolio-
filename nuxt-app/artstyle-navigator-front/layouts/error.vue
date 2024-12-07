<template>
  <v-container
    fill-height
  >
    <v-row>
      <v-col
        cols="12"
      >
        <v-card-title
          class="justify-center"
        >
        {{ error.statusCode }}
        </v-card-title>
        <v-card-text
          class="text-center"
        >
        {{ responsedMessage }}
        </v-card-text>
        <v-card-actions
          class="justify-center"
        >
          <v-icon>
            mdi-emoticon-sick-outline
          </v-icon>
        </v-card-actions>
        <v-card-actions
          class="justify-center"
        >
          <v-btn
            icon
            x-large
            color="appblue"
            @click="redirect"
          >
            <v-icon>
              mdi-home
            </v-icon>
          </v-btn>
        </v-card-actions>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  props: {
    error: {
      type: Object,
      default: null
    }
  },
  computed: {
    // ログイン前後でリダイレクトパスを切り替える算出プロパティ
    redirectPath () {
      const loggedInHomePath = this.$store.state.loggedIn.homePath
      const beforeLoginHomePath = { name: 'index' }
      return this.$auth.loggedIn
        ? loggedInHomePath : beforeLoginHomePath
    },
    // axiosエラーの場合とNuxtのエラーでメッセージを変換
    responsedMessage() {
      if (this.error.response && this.error.response.statusText) {
        const {status} = this.error.response;

        // ステータスコードに応じた日本語メッセージ
        const statusMessages = {
          401: '続行する前にサインインまたはサインアップする必要があります',
          403: '認可エラーです。アクセス権限がありません。',
          404: 'お探しのページが見つかりません。',
          500: 'サーバーエラーが発生しました。時間をおいて再度お試しください。'
        };

        // 特定のメッセージがあればそれを表示、なければデフォルトメッセージ
        return statusMessages[status] || '不明なエラーが発生しました。';
      }
      // responseがない場合はerror.messageを返す
      return this.error ? this.error.message : 'エラーが発生しました。';
    }
  },
  async created () {
    console.log('Error object:', this.error)
    // 認証エラーの場合はVuexを初期化する(セッションはサーバで削除済み)
    if (this.error.statusCode === 401) {
      await this.$auth.logout();
      await this.$authentication.resetVuex();
      this.$cookies.removeAll();
      localStorage.clear();
    }
  },
  methods: {
    // リダイレクトパスが現在のルートと一致している場合はリロードを行う
    redirect () {
      this.redirectPath.name === this.$route.name
        ? this.$router.go() : this.$router.push(this.redirectPath)
    }
  }
}
</script>
