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
        <v-list-group 
        v-for="nav_list in nav_lists"
        :key="nav_list.name"
        :prepend-icon="nav_list.icon"
        no-action
        :append-icon="nav_list.lists ? undefined:''">
         <template #activator>
          <v-list-item-content class="title grey--text text--darken-2">
            <v-list-item-title>{{ nav_list.name }}</v-list-item-title>
          </v-list-item-content>
         </template>
         <!-- メニュー -->
         <v-list-item v-for="list in nav_list.lists" :key="list.name" :to="list.link">
          <v-list-item-content>
            <v-list-item-title>{{ list.name }}</v-list-item-title>
          </v-list-item-content>
         </v-list-item>
        </v-list-group>
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
        <v-btn text href="../pages/signup.vue">Sign up</v-btn>

        <v-btn text>Login</v-btn>
        <v-btn text>ゲストログイン</v-btn>
        <v-btn text>簡単ログイン</v-btn>
      
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
      {name: '名前',icon: 'mdi-vuetify'},
      {name: '自分の作品',icon: 'mdi-account-circle'},
      {name: 'サンプル1',icon: 'mdi-bug'},
      {name: 'サンプル2',icon: 'mdi-github'},
      {name: 'サンプル3',icon: 'mdi-stack-overflow'},
        ],
      nav_lists:[
        {
          // エクスパンションリストに Link を追加
          name: 'Home', 
          icon: 'mdi-home-account',
          lists:[{
            name: 'サンプル', link:'/'
          },
          {
            // とりあえず設定
           name:'サンプル２', link:'/about'
          }
        ] 
        },
        {name: 'About', icon: 'mdi-information'},
        {name: 'Help', icon: 'mdi-help'},
        {name: 'サンプル', icon: 'mdi-bird'},
        {name: 'サンプル', icon: 'mdi-bird'},
        {name: 'サンプル', icon: 'mdi-bird'},
      ],
    };
  },
  head() {
    return {
      title: 'ArtStyle_Navigator', // title タグ
      titleTemplate: '%s - Home'
    }
  }
}
</script>

