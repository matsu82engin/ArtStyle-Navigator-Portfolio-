<template>
  <v-menu
    app
    offset-x
    offset-y
    max-width="200"
  >
    <template #activator="{ on }">
      <v-btn
        icon
        v-on="on"
      >
        <v-icon>
          mdi-account-circle
        </v-icon>
      </v-btn>
    </template>

    <v-list dense>
      <v-subheader>
        ログイン中のユーザー
      </v-subheader>

      <v-list-item>
        <v-list-item-content>
          <v-list-item-subtitle>
            {{ $authentication.user.name }}
          </v-list-item-subtitle>
        </v-list-item-content>
      </v-list-item>

      <v-divider />

      <v-subheader>
        アカウント
      </v-subheader>

      <template
        v-for="(menu, i) in menus"
      >
        <v-divider
          v-if="menu.divider"
          :key="`menu-divider-${i}`"
        />

        <v-list-item
          v-if="menu.name !== 'ログアウト'"
          :key="`menu-list-${i}`"
          :to="menu.link"
        >
          <v-list-item-icon class="mr-2">
            <v-icon
              size="22"
            >
              {{ menu.icon }}
            </v-icon>
          </v-list-item-icon>
          <v-list-item-title>
            {{ menu.name }}
          </v-list-item-title>
        </v-list-item>

        <!-- ログアウトボタン -->
        <v-list-item
          v-else
          :key="`menu-list-else-${i}`"
          @click="logoutUser"
        >
          <v-list-item-icon class="mr-2">
            <v-icon size="22">
              {{ menu.icon }}
            </v-icon>
          </v-list-item-icon>
          <v-list-item-title>
            {{ menu.name }}
          </v-list-item-title>
        </v-list-item>

      </template>
    </v-list>
  </v-menu>
</template>

<script>
export default {
  data () {
    return {
      menus: [
        { name: 'アカウント設定', icon: 'mdi-account-cog', link: '/account/settings' },
        { name: 'パスワード変更', icon: 'mdi-lock-outline', link: '/account/password'},
        { name: 'ログアウト', icon: 'mdi-logout-variant', divider: true }
      ]
    }
  },
  methods: {
    logoutUser(){
      this.$auth.logout()
        .then(() => {
          this.$authentication.logoutAdd();
          console.log('ログアウト成功');
          // ログアウト成功時の処理
          // Cookie からトークンなどを削除
          this.$cookies.remove('access-token');
          this.$cookies.remove('uid');
          this.$cookies.remove('client');
          this.$cookies.remove('token-type');
          this.$cookies.remove('refresh_token');
          window.localStorage.removeItem('persisted-key');
          this.$router.push('/');
        })
        .catch((error) => {
          // ネットワークによるログアウト失敗時の処理
          console.error('ログアウトエラー:', error);
        })
    },
  }
}
</script>
