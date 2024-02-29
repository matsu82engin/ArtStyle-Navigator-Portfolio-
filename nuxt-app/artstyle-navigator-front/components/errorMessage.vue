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
    methods: {
      setErrorMessage(error) {
        // エラーレスポンスがある場合、エラーメッセージを変数に設定
        if (error.response && error.response.data && error.response.data.errors) {
            const errorMessages = error.response.data.errors.full_messages;
            this.errorMessage = errorMessages.join(', '); // エラーメッセージをカンマで連結して表示
        }
        else {
          this.errorMessage = 'Registration failed. Please try again later.'; // 予期しないエラーの場合のメッセージ
        }
        console.error('Registration failed:', error.response.data);
      }
    }
  }
</script>

<style>
  .error-message {
    margin-bottom: 16px; /* エラーメッセージとフォームの間の余白を設定 */
  }
</style>