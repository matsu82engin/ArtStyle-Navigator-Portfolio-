<template>
 <v-app>
  <v-navigation-drawer v-model="drawer" app clipped>
  <!-- <v-navigation-drawer v-model="drawer" app clipped style="background-color: white;"> -->


    <v-container>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title class="title grey--text text--darken-2">
            Navigation List
          </v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <v-divider></v-divider>

      <!-- <v-list dense nav>  エクスパンションリストなしの設定。
        <v-list-item v-for="nav_list in nav_lists" :key="nav_list.name" class="title grey--text text--darken-2">
          <v-list-item-icon>
            <v-icon class="title grey--text text--darken-2">{{ nav_list.icon }}</v-icon>
          </v-list-item-icon>
          <v-list-item-content>
            <v-list-item-title>{{ nav_list.name }}</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-list> -->

      <!-- ナビゲーションメニュー -->
      <v-list dense nav >
        <template v-for="nav_list in nav_lists">
          <!-- nav_list.lists がなければ(下の階層がなければ) そのまま配列のリンクを使う -->
          <v-list-item
            v-if="!nav_list.lists"
            :key="nav_list.id"         
            :to="nav_list.link"
            @click="menu_close"
          >
           <v-list-item-icon>
            <v-icon> {{ nav_list.icon }} </v-icon>
           </v-list-item-icon>
            <v-list-item-content>
            <v-list-item-title>
              {{ nav_list.name }}
            </v-list-item-title>
          </v-list-item-content>
          </v-list-item>        

         <v-list-group 
         v-else
         :key="nav_list.id"
         v-model="nav_list.active"
         no-action 
         :prepend-icon="nav_list.icon"
         >
         <template #activator>
          <v-list-item-content class="title grey--text text--darken-2"> <!-- もし下の階層があるなら -->
            <v-list-item-title>{{ nav_list.name }}</v-list-item-title>
          </v-list-item-content>
        </template>
         <!-- メニュー --> <!--下の階層のリンク -->
         <v-list-item 
          v-for="list in nav_list.lists" 
          :key="list.id" 
          :to="list.link"
          >  
          <v-list-item-title>
            {{ list.name }}
          </v-list-item-title>         
         </v-list-item>
        </v-list-group>
        </template>
      </v-list>

    </v-container>
  </v-navigation-drawer>

  <!-- メインコンテンツ -->
    <v-main>
      <v-container>
        <Nuxt />
      </v-container>
    </v-main>

  <!-- ナビゲーションバー -->
  <v-app-bar color="primary" dark app clipped-left> 
    <v-app-bar-nav-icon @click="drawer =! drawer"></v-app-bar-nav-icon>
    <v-toolbar-title>ArtStyle_Navigator</v-toolbar-title>
    <v-spacer></v-spacer>
    <v-toolbar-items>

      <!-- ボタンは ログインした後はv-ifで消して、プロフィールのみ v-else で表示する -->
      <v-btn
       v-for="nav_menu in nav_menus"
       :key="nav_menu.id"
       :to="nav_menu.path"
       color="primary"
       class="elevation-0"
       >
       {{ nav_menu.menu }}
      </v-btn>
      
      <v-menu offset-y>
        <template #activator="{ on }"> <!--  v-slot:activator から修正-->
        <v-btn text v-on="on" >プロフィール<v-icon>mdi-menu-down</v-icon></v-btn>  <!-- 本当はここはログインしないと表示しない -->
        </template>
        <v-list>
          <v-subheader>Setting</v-subheader>
          <v-list-item v-for="profile in profiles" :key="profile.name">
            <v-list-item-icon>
            <v-icon>{{ profile.icon }}</v-icon>
            </v-list-item-icon>
            <v-list-item-content>
              <v-list-item-title>
                {{ profile.name }}
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
 </v-app>
</template>





<script>
export default{
  data(){
    return{
      drawer: null,
      profiles:[
      {id: 1, name: '名前',icon: 'mdi-vuetify'},
      {id: 2, name: '自分の作品',icon: 'mdi-account-circle'},
      {id: 3, name: 'サンプル1',icon: 'mdi-bug'},
      {id: 4, name: 'サンプル2',icon: 'mdi-github'},
      {id: 5,name: 'サンプル3',icon: 'mdi-stack-overflow'},
        ],
      nav_lists:[
        {
          // エクスパンションリストに Link を追加
          id: 1,
          name: 'Home', 
          icon: 'mdi-home-account',
          active: false,
          link: '',
          lists:[{
            id: 1, name: 'サンプル4', link:'/'
          },
          {
            // とりあえず設定
            id: 2, name:'サンプル5', link:'/about'
          }
        ] 
        },
        {id: 2, name: 'About', icon: 'mdi-information', link: '/about'}, 
        {id: 3, name: 'Help', icon: 'mdi-help', link: '/help'},
        {id: 4, name: 'サンプル6', icon: 'mdi-bird', link: ''},
        {id: 5, name: 'サンプル7', icon: 'mdi-bird', link: ''},
        {id: 6, name: 'サンプル8', icon: 'mdi-bird', link: ''},
      ],
      nav_menus: [
        { id: 1, menu: 'Sign up', path: '/signup' },
        { id: 2, menu: 'Login', path: '' },
        { id: 3, menu: 'ゲストログイン', path: '' },
        { id: 4, menu: '簡単ログイン', path: '' },
      ],
    };
  },
  head() {
    return {
      title: 'ArtStyle_Navigator', // title タグ
      titleTemplate: '%s - Home'
    }
  },
  methods: {
    menu_close(){
      this.nav_lists.forEach(function(navList) {
        navList.active = false;
      });
    }
  }
}
</script>

