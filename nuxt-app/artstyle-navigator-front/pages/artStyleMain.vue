<template>
  <div>
    <v-img
      :src="homeImg"
      :aspect-ratio="16/9"
      gradient="to top right, rgba(100,115,201,.1), rgba(25,32,72,.3)"
    >
      <v-container fill-height>
        <v-row justify="center" align="center">
          <v-col cols="12" sm="8" md="6" class="text-center">
            <div style="background: rgba(0,0,0,0.25); border-radius: 16px; padding: 32px;">
              <h1
                class="text-h3 font-weight-bold white--text mb-4"
              >
                あなたの好みの<br>絵柄を診断しよう
              </h1>

              <p class="text-body-1 white--text mb-8">
                7つの質問に答えるだけで、あなたの好みがわかります。
              </p>

              <diagnosis-start-button x-large />
            </div>
          </v-col>
        </v-row>
      </v-container>
    </v-img>

    <!-- 自分の投稿画像一覧 -->
    <v-container class="mt-8">
      <v-row justify="center">
        <v-col cols="12" sm="10" md="8">

          <div class="d-flex align-center mb-4">
          <h2 class="text-h5 font-weight-bold">自分の投稿</h2>
          <v-btn
            text
            color="primary"
            class="ml-2"
            :to="{ name: 'users-id-my-page', params: { id: currentUserId } }"
          >
            Mypage
          </v-btn>
        </div>

          <v-divider class="mb-6" />

          <!-- ローディング -->
          <div v-if="loading" class="text-center py-8">
            <v-progress-circular indeterminate color="primary" />
          </div>

          <!-- 投稿なし -->
          <div v-else-if="posts.length === 0" class="text-center grey--text py-8">
            <p>まだ投稿がありません</p>
          </div>

          <!-- 投稿一覧 -->
          <v-row v-else>
            <v-col
              v-for="post in posts"
              :key="post.id"
              cols="6"
              sm="4"
              md="3"
            >
              <v-card hover>
                <v-img
                  v-if="post.post_images && post.post_images.length > 0"
                  :src="post.post_images[0].image_url"
                  :alt="post.title"
                  aspect-ratio="1"
                />
                <v-card-subtitle class="text-truncate">
                  {{ post.title }}
                </v-card-subtitle>
              </v-card>
            </v-col>
          </v-row>

        </v-col>
      </v-row>
    </v-container>

  </div>
</template>

<script>
import homeImg from '~/assets/images/logged-in/home.png'

export default {
  layout: 'logged-in',
  middleware: ['authenticate'],

  data() {
    return {
      homeImg,
      posts: [],
      loading: false
    }
  },

  computed: {
    currentUserId() {
      return this.$store.state.user.current?.id
    }
  },

  async mounted() {
    await this.fetchMyPosts()
  },

  methods: {
    async fetchMyPosts() {
      this.loading = true

      try {
        const response = await this.$axios.get(
          `/api/v1/users/${this.currentUserId}/posts`
        )
        this.posts = response.data
      } catch(e) {
        this.$store.dispatch('getToast', {
          msg: ['投稿の取得に失敗しました'],
        })
      } finally {
        this.loading = false
      }
    }
  }
}
</script>