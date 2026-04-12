<template>
  <div>
    <v-container class="mt-8">
      <v-row justify="center">
        <v-col cols="12" sm="10" md="8">

          <h1 class="text-h5 font-weight-bold mb-4">みんなの投稿</h1>
          <v-divider class="mb-6" />

          <!-- 絵柄フィルター -->
          <v-select
            v-model="selectedArtStyleId"
            :items="artStyles"
            item-text="name"
            item-value="id"
            label="絵柄で絞り込む"
            clearable
            outlined
            dense
            class="mb-6"
            @change="fetchPosts"
            @click:clear="onClear"
          />

          <!-- ローディング -->
          <div v-if="loading" class="text-center py-8">
            <v-progress-circular indeterminate color="primary" />
          </div>

          <!-- 投稿なし -->
          <div v-else-if="posts.length === 0" class="text-center grey--text py-8">
            <p>投稿がありません</p>
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
              <v-card
                hover
                :to="{ name: 'users-id-my-page', params: { id: post.user_id } }"
              >
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
export default {
  layout: 'logged-in',
  middleware: ['authenticate'],

  data() {
    return {
      posts: [],
      artStyles: [],
      selectedArtStyleId: null,
      loading: false
    }
  },

  async mounted() {
    await Promise.all([
      this.fetchArtStyles(),
      this.fetchPosts()
    ])
  },

  methods: {
    async fetchArtStyles() {
      try {
        const response = await this.$axios.get('/api/v1/art_styles')
        this.artStyles = response.data
      } catch (e) {
        this.$store.dispatch('getToast', {
          msg: ['絵柄の取得に失敗しました']
        })
      }
    },

    async fetchPosts() {
      this.loading = true
      try {
        const params = {}
        if (this.selectedArtStyleId) {
          params.art_style_id = this.selectedArtStyleId
        }

        const response = await this.$axios.get('/api/v1/all_posts/', { params })
        this.posts = response.data
      } catch (e) {
        this.$store.dispatch('getToast', {
          msg: ['投稿の取得に失敗しました']
        })
      } finally {
        this.loading = false
      }
    },

    onClear() {
      this.selectedArtStyleId = null
      this.fetchPosts()
    }
  }
}
</script>
