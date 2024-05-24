<template>
  <div>
 
   <!-- ナビゲーションバー -->
    <v-app-bar
      :dark="!isScrollPoint"
	    :height="homeAppBarHeight"
	    :color="navigationbarStyle.color"
	    :elevation="navigationbarStyle.elevation"
      app
      > 
      <app-logo
        @click.native="$vuetify.goTo(0)"
      />
      <v-toolbar-title
        class="hidden-mobile-and-down"
      >
        ArtStyle_Navigator
      </v-toolbar-title>
      <v-spacer></v-spacer>

      <!-- ナビゲーションメニューボタン -->
      <v-toolbar-items class="ml-2 hidden-ipad-and-down">
        <v-btn
        v-for="(menu, i) in menus"
        :key="`menu-btn-${i}`"
        text
        :class="{ 'hidden-sm-and-down': (menu.title === 'about') }"
        @click="$vuetify.goTo(`#${menu.title}`)"
        >
        {{ (`${menu.value}`) }}
        </v-btn>

      </v-toolbar-items>
      <app-user-buttons />

      <!-- 見えなくなったナビゲーションメニューをハンバーガーメニューにして対応 -->
      <v-menu
      bottom
      nudge-left="110"
      nudge-width="100"
    >
      <template #activator="{ on }">
        <v-app-bar-nav-icon
          class="hidden-ipad-and-up"
          v-on="on"
        />
      </template>
      <v-list
        dense
        class="hidden-ipad-and-up"
      >
        <v-list-item
          v-for="(menu, i) in menus"
          :key="`menu-list-${i}`"
          exact
          @click="$vuetify.goTo(`#${menu.title}`)"
        >
          <v-list-item-title>
            {{ (`${menu.value}`) }}
          </v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>

    </v-app-bar>
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
      onScroll () {
        this.scrollY = window.scrollY
      },
    }
  }
</script>
