<template>
  <v-container>
    <v-card>
      <v-card-title class="headline">Update your profile</v-card-title>
      <v-card-text>
        <v-form>
          <v-text-field
            v-model="user.name"
            label="Name"
            required
          ></v-text-field>

          <v-text-field
            v-model="user.email"
            label="Email"
            type="email"
            required
          ></v-text-field>

          <v-text-field
            v-model="user.password"
            label="Password"
            type="password"
            required
          ></v-text-field>

          <v-text-field
            v-model="user.confirmPassword"
            label="Confirm Password"
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
        </v-form>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="primary" @click="saveChanges"> Save changes </v-btn>
      </v-card-actions>
    </v-card>
  </v-container>
</template>

<script>
  export default {
    layout: 'logged-in',
    data() {
      return {
        // 現在のユーザーの設定データを表示する
        user: {
          name: '',
          email: '',
          password: '',
          confirmPassword: '',
        },
        profileImage: 'https://randomuser.me/api/portraits/women/1.jpg', // サンプルとしてランダムな画像URL
      }
    },
    mounted() {
      const userId = this.$store.state.user.current?.id;
      console.log(`ユーザーID:${userId}`);
      this.fetchUserAccount(userId);
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
      saveChanges() {
        // ここに保存処理を記述
        console.log('変更を保存しました');
        const payload = {
          // payload の中に入力された name, email の値を含める
          name: this.user.name,
          email: this.user.email,
        };

        if(this.user.password) {
          // name, email しか含まれてない payload の値に 入力された PW の値を含める
          payload.password = this.user.password;
          payload.password_confirmation = this.user.confirmPassword;
        }

        this.$axios.$patch('api/v1/auth', payload)
        .then(response => {
          console.log('保存が成功', response);
          // Vuex に新しいユーザー情報の保存
          this.$store.dispatch('getCurrentUser', response.data);
        })
        .catch(error => {
          console.error('ユーザーアカウント更新失敗', error);
          const msg = 'ユーザーアカウントの更新に失敗しました。'
          return this.$store.dispatch('getToast', { msg })
        })
      },
    },
  }
</script>
