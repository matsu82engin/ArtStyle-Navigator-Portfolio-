<template>
  <v-app>
    <before-login-app-bar />
    <v-main>
      <Nuxt />
    </v-main>
    <app-footer />
  </v-app>
</template>

<script>
export default {
  name: 'BeforeLoginLayout'
}
</script>
