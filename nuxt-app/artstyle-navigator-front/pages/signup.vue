<template>
  <v-container>
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
export default {
    name: 'SignupForm',
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
    beforeDestroy () {
    // Vueインスタンスが破棄される直前にVuexのtoast.msgを削除する(無期限toastに対応)
    this.resetToast()
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
        // ユーザー登録
        let lastError = null //エラーを保存する変数

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
              // ログイン処理をしたとき失敗した場合(理論的に失敗しないが念の為)
              console.log(error.response)
              const msg = 'ログインに失敗しました。'
              const timeout = -1
              this.loading = false;
              lastError = error;
              return this.$store.dispatch('getToast', { msg, timeout })
            });
          })
          .catch(error => {
            if (error.response && error.response.status === 422) {
              const msg = 'フォームの入力内容にエラーがあります。'
              const timeout = -1
              this.loading = false;
              return this.$store.dispatch('getToast', { msg, timeout })
            } else {
              const apiError = this.$my.apiErrorHandler(error.response)
              lastError = error;
              this.$nuxt.error({
                statusCode: apiError?.statusCode || 500, // エラーハンドラが返すステータスコードまたは 500
                message: apiError?.message || 'An unexpected error occurred', // ハンドラのメッセージまたはデフォルトメッセージ
              });
            }
          })
          .finally(() => {
            if (process.env.NODE_ENV === 'development' && lastError) {
            console.error('Error during signup or login:', lastError);
            }
          })
      },
      // Vuexのtoast.msgの値を変更する
      resetToast () {
          return this.$store.dispatch('getToast', { msg: null })
      }
    },
};
</script>
