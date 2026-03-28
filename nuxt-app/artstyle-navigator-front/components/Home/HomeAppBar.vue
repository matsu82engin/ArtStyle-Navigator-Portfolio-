<template>
  <div>
    <v-app-bar
      :dark="!isScrollPoint"
      :height="homeAppBarHeight"
      :color="navigationbarStyle.color"
      :elevation="navigationbarStyle.elevation"
      app
    >
      <app-logo
        @click.native="handleLogoClick" 
      />
      <app-title class="hidden-mobile-and-down" />
      <v-spacer></v-spacer>

      <!-- ナビゲーションメニューボタン -->
      <v-toolbar-items class="ml-2 hidden-ipad-and-down">
        <template v-if="$route.path === '/'">
          <v-btn
            v-for="(menu, i) in menus"
            :key="`menu-btn-${i}`"
            text
            :class="{ 'hidden-sm-and-down': (menu.label === 'About') }"
            :style="{ color: '#000000' }"
            @click="handleMenuClick(menu)"
          >
            {{ menu.label }}
          </v-btn>
        </template>
      </v-toolbar-items>

      <before-login-app-bar-user-buttons />

      <!-- ハンバーガーメニュー -->
      <v-menu bottom nudge-left="110" nudge-width="100">
        <template #activator="{ on }">
          <v-app-bar-nav-icon class="hidden-ipad-and-up" v-on="on" />
        </template>
        <v-list dense class="hidden-ipad-and-up">
          <template v-if="$route.path === '/'">
            <v-list-item
              v-for="(menu, i) in menus"
              :key="`menu-list-${i}`"
              exact
              @click="handleMenuClick(menu)"
            >
              <v-list-item-title>{{ menu.label }}</v-list-item-title>
            </v-list-item>
          </template>
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
    }
  },

  data({ $store }) {
    return {
      scrollY: 0,
      homeAppBarHeight: $store.state.styles.homeAppBarHeight,
      menus: [
        { label: 'About', scrollTo: '#about' },
        { label: 'Diagnosis', scrollTo: '#diagnosis' },
      ]
    }
  },

  head() {
    return {
      title: 'ArtStyle_Navigator',
      titleTemplate: '%s - Home'
    }
  },

  computed: {
    isScrollPoint() {
      return this.scrollY > 500
    },

    navigationbarStyle() {
      let color
      if (this.scrollY >= this.homeAppBarHeight && this.scrollY <= 500) {
        color = 'transparent'
      } else {
        color = 'white'
      }
      const elevation = this.isScrollPoint ? 4 : 0
      return { color, elevation }
    }
  },

  mounted() {
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
    onScroll() {
      this.scrollY = window.scrollY
    },

    handleMenuClick(menu) {
      this.$vuetify.goTo(menu.scrollTo)
    },

    handleLogoClick() {
      if (this.$route.path === '/') {
        this.$vuetify.goTo(0)
      } else {
        this.$router.push('/')
      }
    }

  }
}
</script>
