<template>
  <v-container class="fill-height" fluid>
    <v-row align="center" justify="center">
      <v-col cols="12" sm="8" md="6">

        <!-- currentQuestionがある時だけ表示 -->
        <template v-if="currentQuestion">

          <!-- プログレスバー -->
          <div class="mb-6">
            <div class="d-flex justify-space-between mb-1">
              <span class="text-body-2 grey--text">
                第 {{ progress.current }} 問 / 全 {{ progress.total }} 問
              </span>
            </div>
            <v-progress-linear
              :value="progressPercent"
              color="primary"
              rounded
              height="8"
            />
          </div>

          <!-- 質問文 -->
          <h2 class="text-h5 font-weight-bold mb-6">
            {{ currentQuestion.text }}
          </h2>

          <!-- 選択肢 -->
          <v-card
            v-for="choice in currentQuestion.choices"
            :key="choice.id"
            class="mb-3 pa-1"
            outlined
            hover
            @click="selectAnswer(choice.id)"
          >
            <v-card-text class="text-body-1">
              <span class="font-weight-bold mr-2">{{ choice.label }}.</span>
              {{ choice.text }}
            </v-card-text>
          </v-card>

        </template>

        <!-- 送信中のローディング表示 -->
        <template v-else>
          <div class="text-center">
            <v-progress-circular indeterminate color="primary" />
            <p class="mt-4 grey--text">診断中...</p>
          </div>
        </template>

      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  layout: 'logged-in',

  computed: {
    currentQuestion() {
      return this.$store.getters['quiz/currentQuestion']
    },
    progress() {
      return this.$store.getters['quiz/progress']
    },
    isFinished() {
      return this.$store.getters['quiz/isFinished']
    },
    progressPercent() {
      return (this.progress.current / this.progress.total) * 100
    }
  },

  // questionsが空の場合（直接URLアクセスなど）はトップに戻す
  created() {
    if (!this.currentQuestion) {
      this.$router.push('/diagnosis')
    }
  },

  methods: {
    async selectAnswer(choiceId) {
      const isLastQuestion = this.$store.state.quiz.currentIndex === this.$store.state.quiz.questions.length - 1

      // 全問回答したら結果を送信
      if (isLastQuestion) {
        try {
          // throw new Error('Debug Error');
          await this.$store.dispatch('quiz/submitAndFinish', choiceId)
          this.$router.push('/diagnosis/result')
        } catch (error) {
          this.$store.dispatch('getToast', {
            msg: ['送信に失敗しました。もう一度お試しください'],
          })
        }
      } else {
        // 回答を記録して次の問題へ
        await this.$store.dispatch('quiz/selectAnswer', choiceId)
      }
    }
  }
}
</script>
