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
        <v-icon size="40">
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
          nuxt
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
import { clearAuthCookies } from '@/utils/authCookies.js'

export default {
  computed: {
    menus() {
      const userId = this.$store.state.user.current?.id || null;
      return [
        { name: 'マイページ', icon: 'mdi-account', link: userId ? { name: 'users-id-my-page', params: { id: userId } } : {} },
        { name: 'プロフィール', icon: 'mdi-card-account-details', link: userId ? { name: 'users-id-my-profile', params: { id: userId } } : {} },
        { name: 'アカウント設定', icon: 'mdi-account-cog', link: '/account/settings' },
        { name: 'ログアウト', icon: 'mdi-logout-variant', divider: true }
      ];
    }
  },

  methods: {
    // logoutUser(){
    //   this.$auth.logout()
    //     .then(() => {
    //       this.$authentication.logoutAdd();
    //       console.log('ログアウト成功');

    //       const isProd = process.env.NODE_ENV === 'production';
    //       const options = {
    //         secure: isProd,
    //         sameSite: isProd ? 'None' : 'Lax'
    //       };
          
    //       // ログアウト成功時の処理
    //       // Cookie からトークンなどを削除
    //       this.$cookies.remove('access-token', options);
    //       this.$cookies.remove('uid', options);
    //       this.$cookies.remove('client', options);
    //       this.$cookies.remove('token-type', options);
    //       window.localStorage.removeItem('persisted-key');
    //       this.$router.push('/');
    //     })
    //     .catch((error) => {
    //       // ネットワークによるログアウト失敗時の処理
    //       console.error('ログアウトエラー:', error);
    //     })
    // },
    async logoutUser() {
      try {
        await this.$auth.logout();
        console.log('ログアウト成功！');
      } catch (error) {
        console.error('ログアウトエラー：', error);
      } finally {
        this.$auth.reset(); // logoutが途中で失敗してauthモジュールの状態が「ログイン済み」のまま残るのを防ぐための、念のための呼び出し
        this.$authentication.logoutAdd(); // Vuex の認証情報削除
        window.localStorage.removeItem('persisted-key'); // localStorage の認証情報削除
        clearAuthCookies(); // Cookies の認証情報削除
        this.$router.push('/');
      }
    },
  }
}
</script>
