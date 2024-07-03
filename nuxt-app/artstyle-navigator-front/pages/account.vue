<template>
  <v-container>
    <v-btn
      v-if="!!currentProject"
      small
      plain
      color="primary"
      :to="$my.projectLinkTo(currentProject.id, 'project-id-dashboard')"
    >
      <v-icon
        left
      >
        mdi-chevron-double-left
      </v-icon>
      ダッシュボードに戻る
    </v-btn>
    <nuxt-child />
  </v-container>
</template>

<script>
  export default {
    layout: 'logged-in',
    validate ({ route }) {
      return route.name !== 'account'
    },
    computed: {
      currentProject (){
        return this.$store.state.project.current
      }
    }
  }
</script>