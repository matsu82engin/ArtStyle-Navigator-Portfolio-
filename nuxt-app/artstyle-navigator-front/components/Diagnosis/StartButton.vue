<template>
  <v-btn
    :x-large="xLarge"
    :large="!xLarge"
    color="primary"
    rounded
    @click="startDiagnosis"
  >
    絵柄診断をする
  </v-btn>
</template>

<script>
export default {
  props: {
    xLarge: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    startDiagnosis() {
      this.$router.push('/diagnosis')
    }
  }
}
</script>
