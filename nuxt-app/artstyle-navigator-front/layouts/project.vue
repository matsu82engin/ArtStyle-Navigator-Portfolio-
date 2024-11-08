<template>
  <v-app>
    <!-- ツールバー -->
    <logged-in-app-bar
      #navigation-toggle-button
      clipped-left
    >
      <v-app-bar-nav-icon
        @click="drawer = !drawer"
      />
    </logged-in-app-bar> 

    <!-- ナビゲーションドロワー -->
    <project-navigation-drawer 
      :drawer.sync="drawer"
    />

    <!-- メインコンテンツ -->
    <v-main>
      <Nuxt />
    </v-main>
  </v-app>
</template>

<script>
export default {
  middleware: ['get-picture-list', 'get-project-current'],
  data() {
    return {
      drawer: null
    }
  }
}
</script>
