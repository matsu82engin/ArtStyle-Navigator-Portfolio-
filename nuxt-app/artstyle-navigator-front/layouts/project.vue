<template>
  <v-app>
    <logged-in-app-bar />
    <v-main>
      layouts/project.vue
      <Nuxt />
    </v-main>
    <!-- 削除: <app-footer /> -->
  </v-app>
</template>

<script>
export default {
}
</script>
