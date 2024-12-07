<template>
  <v-container>
    <!-- エラーメッセージを表示するためのコンポーネント -->
    <ErrorMessage
      :error-message="errorMessage"
    />

    <v-card width="400px" class="mx-auto mt-5">
      <v-card-title>
        <h1 class="display-1">
          新規登録
        </h1>
      </v-card-title>
      <v-card-text>
        <v-form
          ref="form"
          v-model="isValid"
          lazy-validation
          @submit.prevent="userForm"
        >
          <v-text-field
            v-model="user.name"
            :rules="nameRules"
            :counter="max"
            prepend-icon="mdi-account"
            label="名前"
          />
          <v-text-field
            v-model="user.email"
            :rules="signupEmailRules"
            prepend-icon="mdi-email"
            label="メールアドレス"
            placeholder="your@email.com"
          />
          <v-text-field
            v-model="user.password"
            :rules="form.signupPasswordRules"
            :hint="form.hint"
            prepend-icon="mdi-lock"
            :append-icon="toggle.icon"
            :type="toggle.type"
            label="パスワード"
            :placeholder="form.min"
            :counter="''"
            @click:append="show = !show"
          />
          <v-text-field
            v-model="user.password_confirmation"
            prepend-icon="mdi-lock"
            :append-icon="toggle.icon"
            :type="toggle.type"
            label="パスワード確認"
            @click:append="show = !show"
          />
          <v-card-actions>
            <v-btn
              type="submit"
              color="light-green darken-1"
              class="white--text"
              :disabled="!isValid || loading"
              :loading="loading"
              block
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
    components: {
      ErrorMessage
    },
    layout: 'before-login',
    data() {
      const max = 50
      return {
          max,
          user: {
              name: '',
              email: '',
              password: '',
              password_confirmation: '',
          },
          isValid: false,
          loading: false,
          nameRules: [
            v => (v && v.trim().length > 0) || '名前を入力してください',
            v => (!!v && max >= v.length) || `${max}文字以内で入力してください`
          ],
          signupEmailRules: [
            v => !!v || '',
            v => /.+@.+\..+/.test(v) || ''
          ],
          show: false,
          errorMessage: '',
      };
    },
    computed: {
      form() {
        const min = '6文字以上'
        const msg = `${min}必須。空白不可。半角英数字・ﾊｲﾌﾝ・ｱﾝﾀﾞｰﾊﾞｰが使えます`
        const rules = v => /^[\w-]{6,72}$/.test(v) || msg
        const hint = msg
        const signupPasswordRules = [rules]
        return {min, msg, signupPasswordRules, hint}
      },
      toggle() {
        const icon = this.show ? 'mdi-eye' : 'mdi-eye-off'
        const type = this.show ? 'text' : 'password'
        return { icon, type }
      }
    },
    methods: {
      userForm() {
        this.registerLoading();
        this.userRegister();
      },
      registerLoading(){
        this.loading = true
        setTimeout(() => {
          this.loading = false
        }, 3000)
      },
      formReset(){
        this.$refs.form.reset();
        this.user = {
          name: '',
          email: '',
          password: '',
          password_confirmation: ''
        };
      },
      userRegister() {
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
          this.formReset();
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