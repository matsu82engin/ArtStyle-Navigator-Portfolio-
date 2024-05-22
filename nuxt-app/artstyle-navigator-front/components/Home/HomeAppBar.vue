<template>
  <div>
 
   <!-- ナビゲーションバー -->
    <v-app-bar 
      :dark="!isScrollPoint"
	    :height="homeAppBarHeight"
	    :color="navigationbarStyle.color"
	    :elevation="navigationbarStyle.elevation"
      app
      clipped-left
      > 
      <app-logo
        @click.native="$vuetify.goTo(0)"
      />
      <v-toolbar-title>ArtStyle_Navigator</v-toolbar-title>
      <v-spacer></v-spacer>
      <!-- ナビゲーションメニューボタン -->
      <v-toolbar-items class="ml-2">
        <v-btn
        v-for="(menu, i) in menus"
        :key="`menu-btn-${i}`"
        text
        @click="$vuetify.goTo(`#${menu.title}`)"
        >
        {{ (`${menu.value}`) }}
      </v-btn>

       <!-- ボタンは ログインした後はv-ifで消して、プロフィールのみ v-else で表示する -->
        <template v-if="!$auth.loggedIn" >
          <v-btn
            v-for="nav_menu in nav_menus"
            :key="nav_menu.id"
            :to="nav_menu.path"
            class="elevation-0"
            :elevation="navigationbarStyle.elevation"
            :style="{ backgroundColor: navigationbarStyle.color }"
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
 
     </v-toolbar-items>
    </v-app-bar>
    <v-footer color="primary" dark app>
      ArtStyle_Navigator
    </v-footer>
  </div>
</template>
 
<script>
  export default {
    props: {
      imgHeight: {
        type: Number,
        default: 0
      },
      menus: {
        type: Array,
        default: () => []
      },
    },
    data({ $store }){
      return {
        scrollY: 0, // スクロールのデフォルト値
        homeAppBarHeight: $store.state.styles.homeAppBarHeight,
        profiles:[
        {id: 1, name: '名前',icon: 'mdi-vuetify'},
        {id: 2, name: '自分の作品',icon: 'mdi-account-circle'},
        {id: 3, name: 'サンプル1',icon: 'mdi-bug'},
        {id: 4, name: 'アカウントの設定',icon: 'mdi-account-cog-outline', link: '/account/deleteAccount'},
        ],
        nav_menus: [
          { id: 1, menu: 'Sign up', path: '/account/signup' },
          { id: 2, menu: 'Login', path: '/account/login' },
          { id: 3, menu: 'ゲストログイン', path: '' },
        ],
      };
    },
    head() {
      return {
        title: 'ArtStyle_Navigator', // title タグ
        titleTemplate: '%s - Home'
      }
    },
    computed: {
      isScrollPoint() {
        return this.scrollY > 500
      },
      navigationbarStyle () {
        let color;
        if (this.scrollY < this.homeAppBarHeight) {
          color = 'primary';
        } else if (this.scrollY >= this.homeAppBarHeight && this.scrollY <= 500) {
          color = 'transparent';
        } else {
          color = 'white'
        }
        const elevation = this.isScrollPoint ? 4 : 0
        return { color, elevation }
      }
    },
    mounted(){
      if (typeof window !== 'undefined') {
        window.addEventListener('scroll', this.onScroll)
      }
    },
    beforeDestroy() {
      if (typeof window !== 'undefined') {
        window.removeEventListener('scroll', this.onScroll)
      }
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
      onScroll () {
        this.scrollY = window.scrollY
      },
    }
  }
</script>
