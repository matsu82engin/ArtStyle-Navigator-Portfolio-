<template>
  <v-app>
    <logged-in-app-bar />
    <v-main>
      <app-toaster />
      <Nuxt />
    </v-main>
    <app-footer />
  </v-app>
</template>

<script>
export default {
  name: 'LoggedIn',
  middleware: ['authenticate']
}
</script>
