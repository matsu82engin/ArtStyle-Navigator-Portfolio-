<template>
  <v-container class="fill-height" fluid>
    <v-row align="center" justify="center">
      <v-col cols="12" sm="8" md="6" class="text-center">

        <h1 class="text-h4 font-weight-bold mb-4">
          自分の絵柄を診断しよう！
        </h1>
        <p class="text-body-1 grey--text mb-8">
          7つの質問に答えるだけで、あなたの好みの絵柄がわかります。
        </p>

        <v-btn
          x-large
          color="primary"
          rounded
          @click="startDiagnosis"
        >
          診断スタート
        </v-btn>

      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  layout: 'logged-in',
  methods: {
    async startDiagnosis() {
      // 再診断の場合に備えてリセット
      this.$store.dispatch('quiz/resetQuiz')
      try {
        // 質問データを取得
        await this.$store.dispatch('quiz/fetchQuestions')
        // 質問ページへ遷移
        this.$router.push('/diagnosis/quiz')
      } catch (error) {
        this.$store.dispatch('getToast', {
          msg: ['質問の読み込みに失敗しました。もう一度お試しください']
        })
      }
    }
  }
}
</script>
