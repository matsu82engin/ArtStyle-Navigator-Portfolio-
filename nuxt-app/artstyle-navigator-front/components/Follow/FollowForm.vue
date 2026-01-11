<template>
  <div>
    <!-- 読み込み中 -->
    <v-btn
      v-if="loading"
      block
      :disabled="loading"
    >
      読み込み中 ...
    </v-btn>

    <!-- フォローしてない場合 -->
    <v-btn
      v-else-if="!isFollowing"
      color="primary"
      block
      @click="follow"
    >
      フォローする
    </v-btn>

    <!-- フォローしてる場合 -->
    <v-btn
      v-else
      color="grey"
      block
      @click="unfollow"
    >
      <!-- 最近はフォロー解除、というより他のUIにすることが多いかも -->
      フォロー解除
    </v-btn>
  </div>
</template>

<script>
export default {
  props: {
    userId: { type: Number, required: true }  // 対象ユーザー
  },

  data() {
    return {
      loading: true,
      isFollowing: false
    }
  },

  async mounted() {
    // if (!this.$auth.loggedIn) return
    // await this.fetchFollowState();
    if (!this.$auth.loggedIn) {
      this.loading = false
      return
    }
    await this.fetchFollowState()
  },

  methods: {
    async fetchFollowState() {
      try {
        const response = await this.$axios.$get(`/api/v1/users/${this.userId}/following_state`)
        console.log('レスポンス確認',response);
        this.isFollowing = response.is_following
      } catch (error) {
        this.$my.apiErrorHandler(error.response)
      } finally {
        this.loading = false
      }
    },

    async follow() {
      if (this.loading) return
      this.loading = true

      try {
        await this.$axios.$post(`/api/v1/relationships`, {
          // これは送るパラメータ
          followed_id: this.userId
        })
        this.isFollowing = true
      } catch (error) {
        // this.$my.apiErrorHandler(error.response)
        if (error.response) {
          const msg = ['フォローに失敗しました']
          return this.$store.dispatch('getToast', { msg })
        }
      } finally {
        this.loading = false
      }
    },

    async unfollow() {
      try {
        await this.$axios.$delete(`/api/v1/relationships/${this.userId}`)
        this.isFollowing = false
      } catch (error) {
        // this.$my.apiErrorHandler(error.response)
        if (error.response) {
          const msg = ['フォロー解除に失敗しました']
          return this.$store.dispatch('getToast', { msg })
        }
      }
    },
  }
}
</script>