<template>
  <v-container>
    <div v-if="$fetchState.pending" class="text-center mt-8">
      <v-progress-circular indeterminate color="primary" size="64" />
    </div>

    <div v-else-if="$fetchState.error" class="text-center mt-8">
      <p>読み込みに失敗しました</p>
      <v-btn color="primary" @click="$fetch">再試行</v-btn>
    </div>

    <v-row v-else>
      <v-col cols="12" md="8" offset-md="2">
        <!-- ページタイトル -->
        <v-card class="mb-4">
          <v-card-title>
            <v-btn icon :to="`/users/${$route.params.id}/my-page`">
              <v-icon>mdi-arrow-left</v-icon>
            </v-btn>
            {{ title }}（{{ users.length }}人）
          </v-card-title>
        </v-card>

        <!-- ユーザーが0人の場合 -->
        <v-alert v-if="users.length === 0" type="info" outlined>
          {{ emptyMessage }}
        </v-alert>

        <!-- ユーザー一覧 -->
        <v-card
          v-for="user in users"
          :key="user.id"
          class="mb-2"
        >
          <v-list-item>
            <v-list-item-avatar>
              <v-img v-if="user.avatar_url" :src="user.avatar_url" />
              <v-icon v-else size="40">mdi-account-circle</v-icon>
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>{{ user.pen_name || '名前未設定' }}</v-list-item-title>
              <v-list-item-subtitle>{{ user.introduction }}</v-list-item-subtitle>
            </v-list-item-content>

            <!-- 自分以外にはフォローボタンを表示 -->
            <v-list-item-action v-if="$auth.loggedIn && user.id !== currentUserId">
              <follow-form :user-id="user.id" />
            </v-list-item-action>
          </v-list-item>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  name: 'UserListPage',
  props: {
    // 'following' or 'followers'
    listType: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      users: [],
    }
  },
  async fetch() {
    const userId = this.$route.params.id
    const response = await this.$axios.get(`/api/v1/users/${userId}/${this.listType}`)
    this.users = response.data
  },
  computed: {
    title() {
      return this.listType === 'following' ? 'フォロー中' : 'フォロワー'
    },
    emptyMessage() {
      return this.listType === 'following'
        ? 'まだ誰もフォローしていません'
        : 'まだフォロワーがいません'
    },
    currentUserId() {
      return this.$store.state.user.current?.id
    },
  },
}
</script>