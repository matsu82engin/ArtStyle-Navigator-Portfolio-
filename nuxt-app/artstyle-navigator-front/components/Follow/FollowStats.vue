<template>
  <v-row class="ma-0">
    <v-col
      cols="6"
      class="pa-0"
      text-center
    >
      <nuxt-link
        :to="$my.projectLinkTo(userId, 'users-id-following')"
      >
        <strong>
          {{ following }}
          フォロー
        </strong>
      </nuxt-link>
    </v-col>

    <v-col
      cols="6"
      class="pa-0"
      text-center
    >
      <nuxt-link
        :to="$my.projectLinkTo(userId, 'users-id-followers')"
      >
        <strong>
          {{ followers }}
          フォロワー
        </strong>
      </nuxt-link>
    </v-col>
  </v-row>
</template>

<script>
export default {
  props: {
    userId: { type: Number, required: true },
    following: { type: Number, required: true },
    followers: { type: Number, required: true }
  }
}
</script>