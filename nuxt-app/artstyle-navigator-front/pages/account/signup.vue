<template>
  <v-container>
    <!-- エラーメッセージを表示するためのコンポーネント -->
    <ErrorMessage :errorMessage="errorMessage" />

    <v-card width="400px" class="mx-auto mt-5">
      <v-card-title>
        <h1 class="display-1">
          新規登録
        </h1>
      </v-card-title>
      <v-card-text>
        <v-form ref="form" lazy-validation>
          <v-text-field
            v-model="user.name"
            prepend-icon="mdi-account"
            label="名前"
          />
          <v-text-field
            v-model="user.email"
            prepend-icon="mdi-email"
            label="メールアドレス"
          />
          <v-text-field
            v-model="user.password"
            prepend-icon="mdi-lock"
            append-icon="mdi-eye-off"
            label="パスワード"
          />
          <v-text-field
            v-model="user.password_confirmation"
            prepend-icon="mdi-lock"
            append-icon="mdi-eye-off"
            label="パスワード確認"
          />
          <v-card-actions>
            <v-btn
              color="light-green darken-1"
              class="white--text"
              @click="userRegister"
            >
              新規登録
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
    name: 'SignupForm',
    auth: false,
    components: {
      ErrorMessage
    },
    data() {
        return {
            user: {
                name: '',
                password: '',
                email: '',
                password_confirmation: '',
            },
            errorMessage: '',
        };
    },
    methods: {
      userRegister() {
      // thenメソッドを使ってレスポンスを処理する
        this.$axios.post('/api/v1/auth', this.user)
          .then(response => {
        // ログイン処理
        this.$auth.loginWith('local', {
          data: {
            email: this.user.email,
            password: this.user.password
          }
        }).then(() => {
          // ログイン後の処理
          this.$router.push(`/users/${response.data.data.id}`);
        }).catch(error => {
          this.setErrorMessage(error);
        });
      })
      .catch(error => {
        this.setErrorMessage(error);
      });
      },

      setErrorMessage(error){
        // エラーレスポンスがある場合、エラーメッセージを変数に設定
        if (error.response && error.response.data && error.response.data.errors) {
          this.errorMessage = '登録に失敗しました。入力した情報を確認してください';
        } else {
          this.errorMessage = '登録に失敗しました。もう一度お試しください'; 
        }
        if(process.env.NODE_ENV === 'development'){
          console.log('Registration failed:', error.response.data);
        }
      }
    },
}
</script>