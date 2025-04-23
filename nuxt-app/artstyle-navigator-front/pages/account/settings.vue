<template>
  <v-container>
    <v-card>
      <v-card-title class="headline">Update your profile</v-card-title>
      <v-form
        ref="form"
        v-model="isValid"
        @submit.prevent="saveChanges"
      >
        <v-card-text>
          <v-text-field
            v-model="user.name"
            :counter="nameMax"
            :rules="nameRules"
            label="Name"
            required
          ></v-text-field>

          <v-text-field
            v-model="user.email"
            :rules="emailRules"
            label="Email"
            type="email"
            required
          ></v-text-field>

          <v-text-field
            v-model="user.password"
            :rules="form.updatePasswordRules"
            :hint="currentHint"
            :persistent-hint="showPersistentHint"
            :counter="''"
            label="パスワード"
            type="password"
            required
            @input="onPasswordInput"
          ></v-text-field>

          <v-text-field
            v-model="user.confirmPassword"
            :rules="passwordConfirmationRules"
            label="パスワード確認"
            type="password"
            required
          ></v-text-field>

          <v-text-field
            v-if="user.password"
            v-model="user.currentPassword"
            label="現在のパスワード"
            type="password"
            required
          ></v-text-field>

          <div class="d-flex align-center mb-4">
            <v-img
              :src="profileImage"
              max-width="50"
              max-height="50"
              class="mr-2"
            ></v-img>
            <a href="#">change</a>
          </div>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            type="submit"
            color="primary"
            :disabled="!isValid || loading"
            :loading="loading"
            >
            Save changes
          </v-btn>
        </v-card-actions>
      </v-form>
    </v-card>
  </v-container>
</template>

<script>
import { translateErrorMessages } from '@/utils/validationMessages.js'

  export default {
    layout: 'logged-in',
    data() {
      const nameMax = 50
      return {
        // 現在のユーザーの設定データを表示する
        user: {
          name: '',
          email: '',
          password: '',
          confirmPassword: '',
          currentPassword: '',
        },
        profileImage: 'https://randomuser.me/api/portraits/women/1.jpg', // サンプルとしてランダムな画像URL
        isValid: false,
        loading: false,
        nameMax,
        showPersistentHint: true,
        currentHint: 'パスワードは変更する場合のみ入力してください',
        nameRules: [
          v => (v && v.trim().length > 0) || '名前を入力してください',
          v => (!!v && nameMax >= v.length) || `${nameMax}文字以内で入力してください`
        ],
        emailRules: [
          v => !!v || '',
          v => /.+@.+\..+/.test(v) || ''
        ],
      }
    },
    computed: {
      form() {
        const min = '6文字以上'
        const msg = `${min}必須。空白不可。半角英数字・ﾊｲﾌﾝ・ｱﾝﾀﾞｰﾊﾞｰが使えます`
        const rules = v => {
          if (!v) return true // 空欄OK（変更しない時）
          return /^[\w-]{6,72}$/.test(v) || msg
        }
        const updatePasswordRules = [rules]
        return { min, msg, updatePasswordRules }
      },
      passwordConfirmationRules() {
        return [
          v => v === this.user.password || 'パスワードが一致しません'
        ]
      }
    },
    watch: {
      // パスワード入力時にリアルタイムバリデーション実行
      'user.password'(val) {
        this.$refs.form?.validate();
      },
      'user.confirmPassword'(val) {
        this.$refs.form?.validate();
      }
    },
    mounted() {
      const userId = this.$store.state.user.current?.id;
      console.log(`ユーザーID:${userId}`);
      this.fetchUserAccount(userId);
    },
    beforeDestroy () {
      this.resetToast()
    },
    methods: {
      async fetchUserAccount(userId){
        try {
          const response = await this.$axios.$get(`api/v1/users/${userId}`);
          if (response) {
            this.user = {
              name: response.name,
              email: response.email,
            };
          }
        } catch (error) {
          console.error("ユーザー情報の取得に失敗", error);
        }
      },
      onPasswordInput() {
        if (this.user.password === '') { // こちらを用意しておくことで入力をやめたときにPWが必要ないことを再表示できる
          this.currentHint = 'パスワードは変更する場合のみ入力してください'
        } else {
          this.currentHint = '6文字以上必須。空白不可。半角英数字・ﾊｲﾌﾝ・ｱﾝﾀﾞｰﾊﾞｰが使えます'
          this.showPersistentHint = false
        }
      },
      async saveChanges() {
        this.loading = true; // ここでローディング開始
        const startTime = Date.now(); // 開始時間を記録
        const payload = {
          // payload の中に入力された name, email の値を含める
          name: this.user.name,
          email: this.user.email,
        };

        if(this.user.password) {
          // name, email しか含まれてない payload の値に 入力された PW の値を含める
          payload.password = this.user.password;
          payload.password_confirmation = this.user.confirmPassword;
          payload.current_password = this.user.currentPassword
        }

        try {
          const response = await this.$axios.$patch('api/v1/auth', payload)
          console.log('保存が成功', response);
          this.$store.dispatch('getCurrentUser', response.data);
        } catch (error) {
          const timeout = -1
          
          if (error.response && error.response.status === 422) {
            // console.error('ユーザーアカウント更新失敗', error);
            // const msg = 'ユーザーアカウントの更新に失敗しました。'
            // this.$store.dispatch('getToast', { msg });
            const errors = error.response.data.errors;
            console.log(errors);
            const msgArray = Array.isArray(errors?.full_messages) ? errors.full_messages : errors || [];
            const translated = translateErrorMessages(msgArray); // 日本語に変換
            this.$store.dispatch('getToast', { msg: translated , timeout })
          } else {
            const msg = ['アカウント更新に失敗しました。']
            this.$store.dispatch('getToast', { msg, timeout })
          }
        } finally {
          // this.loading = false;
          const elapsed = Date.now() - startTime;
          const minDuration = 500; // 最低500ms(0.5秒)はローディング。こちらは速さ重視。
          const remainingTime = Math.max(minDuration - elapsed, 0);

          setTimeout(() => {
            this.loading = false;
          }, remainingTime);
        }
      },
      // Vuexのtoast.msgの値を変更する
      resetToast () {
          return this.$store.dispatch('getToast', { msg: null })
      },
    },
  }
</script>
