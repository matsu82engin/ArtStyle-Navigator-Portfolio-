<template>
  <v-container>
    <!-- エラーメッセージを表示するためのコンポーネント -->
    <ErrorMessage
      :error-message="errorMessage"
    />

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
          @submit.prevent="loginForm"
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
            :append-icon="toggle.icon"
            :type="toggle.type"
            label="パスワード"
            @click:append="show = !show"
          />
          <v-card-actions>
            <nuxt-link
	            to="#"
              class="body-2 text-decoration-none"
            >
            パスワードを忘れた方はこちら
            </nuxt-link>
          </v-card-actions>
          <v-card-text class="px-0">
            <v-btn
              type="submit"
              color="light-green darken-1"
              class="white--text"
              :disabled="!isValid || loading"
              :loading="loading"
              block
            >
              ログイン
            </v-btn>
          </v-card-text>
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
  data({ $store }) {
    return {
      // 実装時は中身は削除する
      password: 'password',
      email: '1@example.com',
      errorMessage: '',
      isValid: false,
      loading: false,
      show: false,
      redirectPath: $store.state.loggedIn.rememberPath,
      loggedInHomePath: $store.state.loggedIn.homePath,
      loginEmailRules: [
        v => !!v || '',
        v => /.+@.+\..+/.test(v) || ''
      ],
      loginPasswordRules: [
        v => !!v || '',
      ],
    }
  },
  computed: {
    toggle() {
        const icon = this.show ? 'mdi-eye' : 'mdi-eye-off'
        const type = this.show ? 'text' : 'password'
        return { icon, type }
      }
  },
  methods: {
    loginForm() {
      if (this.isValid) {
        this.loading = true;
        this.loginWithAuthModule();
      } else {
        this.errorMessage = 'フォームの入力内容にエラーがあります。';
      }
    },
    formReset(){
      this.$refs.form.reset();
      this.user = {
        email: '',
        password: '',
      };
    },
    async loginWithAuthModule() {
      try {
        const response = await this.$auth.loginWith('local', {
          data: {
            email: this.email,
            password: this.password,
          },
        });
        this.formReset();
        this.$router.push(this.redirectPath);
        // 記憶ルートを初期値に戻す
        this.$store.dispatch('getRememberPath', this.loggedInHomePath) // loggedInHomePath = artStyleMain
        console.log('Login response:', response);  // レスポンスデータの確認
        console.log(response.data);
        this.$authentication.loginAdd(response)
        this.loading = false;      
        return response;
      } catch (error) {
        if (error.response) {
          // バックエンドからのエラーレスポンスがある場合
          this.errorMessage = 'ログインに失敗しました。正しいメールアドレスとパスワードを入力してください。';
          // トースターで出力する場合
          // const msg = 'ログインに失敗しました。正しいメールアドレスとパスワードを入力してください。'
          // this.loading = false;
          // return this.$store.dispatch('getToast', { msg })
        } else {
          // ネットワークエラーやその他のエラーの場合
          this.errorMessage = 'ネットワークエラーが発生しました。後でもう一度お試しください。';
        }
        if (process.env.NODE_ENV === 'development') {
          console.error('Login failed (ログイン失敗):', error);
        }
      }
      this.loading = false;
    },
  },
}
</script>
