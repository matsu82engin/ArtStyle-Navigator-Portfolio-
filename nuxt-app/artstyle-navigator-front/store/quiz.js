export const state = () => ({
  questions: [],
  currentIndex: 0,
  answers: [],
  result: null,
  tiedStyles: []
})

export const getters = {
  // 現在の質問を返す
  currentQuestion: (state) => {
    return state.questions[state.currentIndex] || null
  },
  // 全問回答済みかどうか
  isFinished: (state) => {
    return state.answers.length === state.questions.length
      && state.questions.length > 0
  },
  // 進捗（例：3/7）
  progress: (state) => {
    return {
      current: state.currentIndex + 1,
      total: state.questions.length
    }
  }
}

export const mutations = {
  setQuestions(state, payload) {
    state.questions = payload
  },
  setCurrentIndex(state, payload) {
    state.currentIndex = payload
  },
  addAnswer(state, choiceId) {
    state.answers.push(choiceId)
  },
  setResult(state, payload) {
    state.result = payload
  },
  setTiedStyles(state, payload) {
    state.tiedStyles = payload
  },
  // 診断リセット用
  resetQuiz(state) {
    state.questions = []
    state.currentIndex = 0
    state.answers = []
    state.result = null
    state.tiedStyles = []
  }
}

export const actions = {
  // 質問一覧をAPIから取得
  async fetchQuestions({ commit }) {
      const response = await this.$axios.get('/api/v1/questions')
      commit('setQuestions', response.data)
  },
  // 回答を選択して次の問題へ
  selectAnswer({ commit, state }, choiceId) {
    commit('addAnswer', choiceId)
    commit('setCurrentIndex', state.currentIndex + 1)
  },
  // 全回答をAPIに送信して結果を取得
  // async submitAnswers({ commit, state }) {
  //     const response = await this.$axios.post('/api/v1/user_answers', {
  //       user_answer: {
  //         choice_ids: state.answers
  //       }
  //     })
  //     commit('setResult', response.data.art_style)
  //     commit('setTiedStyles', response.data.tied_styles)
  // },

  async submitAndFinish({ commit, state }, choiceId) {
    const response = await this.$axios.post('/api/v1/user_answers', {
      user_answer: {
        choice_ids: [...state.answers, choiceId]
      }
    })
    commit('addAnswer', choiceId)
    commit('setCurrentIndex', state.currentIndex + 1)
    commit('setResult', response.data.art_style)
    commit('setTiedStyles', response.data.tied_styles)
  },
  // 再診断時のリセット
  resetQuiz({ commit }) {
    commit('resetQuiz')
  }
}