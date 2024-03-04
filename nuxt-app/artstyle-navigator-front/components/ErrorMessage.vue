<template>
  <v-alert v-if="errorMessage" type="error" class="error-message">
    {{ errorMessage }}
  </v-alert>
</template>

<script>
  export default {
    props: {
      errorMessage: {
        type: String,
        required: true
      }
    },
  }
</script>

<style>
  .error-message {
    margin-bottom: 16px; /* エラーメッセージとフォームの間の余白を設定 */
  }
</style>