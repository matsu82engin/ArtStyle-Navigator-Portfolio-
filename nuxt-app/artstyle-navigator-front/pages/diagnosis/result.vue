<!-- pages/diagnosis/result.vue -->
<template>
  <v-container class="fill-height" fluid>
    <v-row align="center" justify="center">
      <v-col cols="12" sm="8" md="6" class="text-center">

        <!-- 通常結果 -->
        <template v-if="!isTied">
          <p class="text-h6 grey--text mb-2">あなたの好みの絵柄は...</p>
          <h1 class="text-h3 font-weight-bold primary--text mb-4">
            {{ result }}
          </h1>
          <p class="text-body-1 grey--text mb-8">
            あなたは{{ result }}の絵柄に強く惹かれているようです！
          </p>
        </template>

        <!-- 同点結果 -->
        <template v-else>
          <p class="text-h6 grey--text mb-2">あなたの好みの絵柄は...</p>
          <h1 class="text-h4 font-weight-bold primary--text mb-4">
            {{ tiedStyles.join(' と ') }}
          </h1>
          <p class="text-body-1 grey--text mb-8">
            複数の絵柄の魅力に惹かれている、個性的なセンスの持ち主です！
          </p>
        </template>

        <!-- ボタン -->
        <div class="d-flex justify-center gap-4">
          <v-btn
            outlined
            color="primary"
            rounded
            class="mr-4"
            @click="retryDiagnosis"
          >
            もう一度診断する
          </v-btn>
          <v-btn
            color="primary"
            rounded
            :to="{ name: 'artStyleMain' }"
          >
            ホームへ戻る
          </v-btn>
        </div>

      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  layout: 'logged-in',

  computed: {
    result() {
      return this.$store.state.quiz.result
    },
    tiedStyles() {
      return this.$store.state.quiz.tiedStyles
    },
    isTied() {
      return this.tiedStyles.length > 0
    }
  },

  created() {
    // 結果がない場合（直接URLアクセスなど）はトップに戻す
    if (!this.result) {
      this.$router.push('/diagnosis')
    }
  },

  methods: {
    retryDiagnosis() {
      this.$store.dispatch('quiz/resetQuiz')
      this.$router.push('/diagnosis')
    }
  }
}
</script>
