<template>
  <div>
    <!-- ログイン前のボタン -->
    <template v-if="!$auth.loggedIn" >
      <v-btn
        v-for="nav_menu in nav_menus"
        :key="nav_menu.id"
        :to="nav_menu.path"
        class="elevation-0"
        :style="{ color: '#0800FF' }" 
        outlined
        >
        {{ nav_menu.menu }}
      </v-btn>
    </template>

    <v-menu v-if="$auth.loggedIn" offset-y> <!-- ログインしてたらプロフィール表示 -->
      <template #activator="{ on }">
        <v-btn text v-on="on">プロフィール<v-icon>mdi-menu-down</v-icon></v-btn>
      </template>
        <v-list>
          <v-subheader>Setting</v-subheader>
          <v-list-item 
          v-for="profile in profiles" 
          :key="profile.name"
          :to="profile.link">
            <v-list-item-icon>
              <v-icon>{{ profile.icon }}</v-icon>
            </v-list-item-icon>
            <v-list-item-content>
              <v-list-item-title>
                {{ profile.name }}
              </v-list-item-title>
            </v-list-item-content>
          </v-list-item>
           <!-- ログアウト追加 -->
            <v-list-item :key="'logout'" @click="logoutUser">
              <v-list-item-icon>
                <v-icon>mdi-logout</v-icon>
              </v-list-item-icon>
              <v-list-item-content>
                <v-list-item-title>
                  ログアウト
                </v-list-item-title>
              </v-list-item-content>
            </v-list-item>
         </v-list>
    </v-menu>

  </div>
</template>

<script>
  export default {
    data(){
      return {
        profiles:[
        {id: 1, name: '名前',icon: 'mdi-vuetify'},
        {id: 2, name: '自分の作品',icon: 'mdi-account-circle'},
        {id: 3, name: 'サンプル1',icon: 'mdi-bug'},
        {id: 4, name: 'アカウントの設定',icon: 'mdi-account-cog-outline', link: '/account/deleteAccount'},
        ],
        nav_menus: [
          { id: 1, menu: 'Sign up', path: '/account/signup' },
          { id: 2, menu: 'Login', path: '/account/login' },
        ],
      };
    },
    methods: {
      menu_close(){
        this.nav_lists.forEach(function(navList) {
          navList.active = false;
        });
      },
      logoutUser(){
        // ログアウト
        this.$auth.logout()
          .then(() => {
            // ログアウト成功時の処理
            localStorage.removeItem('access-token');
            localStorage.removeItem('uid');
            localStorage.removeItem('client');
          })
          .catch((error) => {
            // ログアウト失敗時の処理
            console.error('ログアウトエラー:', error);
          })
      },
    }
  }
</script>
