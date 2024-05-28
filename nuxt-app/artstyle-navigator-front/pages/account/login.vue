<template>
  <v-container>
    <!-- エラーメッセージを表示するためのコンポーネント -->
    <ErrorMessage :error-message="errorMessage" />

    <v-card width="400px" class="mx-auto mt-5">
      <v-card-title>
        <h1 class="display-1">
          ログイン
        </h1>
      </v-card-title>
      <v-card-text>
        <v-form
          ref="form"
          v-model="isValid"
          lazy-validation
        >
          <v-text-field
            v-model="email"
            :rules="loginEmailRules"
            prepend-icon="mdi-email"
            label="メールアドレス"
          />
          <v-text-field
            v-model="password"
            :rules="loginPasswordRules"
            prepend-icon="mdi-lock"
            append-icon="mdi-eye-off"
            label="パスワード"
          />
          <v-card-actions>
            <v-btn
              color="light-green darken-1"
              class="white--text"
              :disabled="!isValid"
              block
              @click="loginWithAuthModule"
            >
              ログイン
            </v-btn>
          </v-card-actions>
        </v-form>
      </v-card-text>
    </v-card>

    <v-card width="400px" class="mx-auto mt-5">
      <v-card-title>
        <h1 class="display-1">
          ゲストログイン
        </h1>
      </v-card-title>
      <v-card-text>
        <v-form ref="form" lazy-validation>
          <v-card-actions>
            <v-btn
              color="light-green darken-1"
              class="white--text"
              @click="loginWithAuthModule"
            >
              ログイン
            </v-btn>
          </v-card-actions>
        </v-form>
      </v-card-text>
    </v-card>

  </v-container>
</template>

<script>
import ErrorMessage from '~/components/ErrorMessage.vue';

export default {
  name: 'LoginForm',
  components: {
    ErrorMessage
  },
  layout: 'before-login',
  auth: false,
  data() {
    return {
      password: '',
      email: '',
      errorMessage: '',
      isValid: false,
      loginEmailRules: [
        v => !!v || '',
        v => /.+@.+\..+/.test(v) || ''
      ],
      loginPasswordRules: [
        v => !!v || '',
      ],
    }
  },
  methods: {
    // loginメソッドの呼び出し
    async loginWithAuthModule() {
      await this.$auth
        .loginWith('local', {
         // emailとpasswordの情報を送信
          data: {
            email: this.email,
            password: this.password,
          },
        })
        .then(
          (response) => {
            this.$router.push(`/users/${this.$auth.user.id}`)
            return response
          },
          (error) => {
          // エラーが発生した場合の処理
          this.errorMessage = 'ログインに失敗しました。正しいメールアドレスとパスワードを入力してください。';
          if(process.env.NODE_ENV === 'development'){
            console.error('Login failed:', error);
            return error;
          }
          }
        )
    },
  },
}
</script>
