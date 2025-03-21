<template>
  <v-container>
    <v-row justify="center">
      <v-col cols="12" md="8">
        <!-- プロフィール表示部分 -->
        <app-toaster />
        <v-card>
          <v-card-title>現在のプロフィール</v-card-title>
          <v-card-text>
            <p>ペンネーム: {{ profile.username }}</p>
            <p>
              自分の絵柄: {{ profile.ArtStyle }}
              <!-- ここでもし未判定なら絵柄判定をするページへの誘導を作る -->
            </p>
            <p>よく使うペン: {{ profile.favoriteArtSupply }}</p>
            <p>自己紹介: {{ profile.bio }}</p>
            <v-img
              v-if="profile.icon"
              :src="profile.icon"
              max-width="100"
            ></v-img>
            <v-icon v-else icon="mdi-account"></v-icon>
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn
              v-if="isOwnProfile"
              color="primary"
              @click="openDialog"
            >
              プロフィール編集
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>

    <!-- プロフィール編集ダイアログ -->
    <v-dialog
    v-if="isOwnProfile"
      v-model="dialog"
      max-width="900"
    >
      <v-card>
        <v-card-title>
          <v-btn
            icon
            color="grey"
            class="mr-8"
            @click="closeDialog"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
          プロフィール編集
          <v-spacer></v-spacer>
        </v-card-title>
        <v-card-text>
          <v-form
            ref="form"
            v-model="valid"
            lazy-validation
          >
            <!-- アイコン変更は画像を保存できるようになってから実装する -->
            <!-- <v-file-input
              v-model="icon"
              label="アイコンを選択"
              accept="image/*"
              prepend-icon="mdi-camera"
            ></v-file-input> -->

            <!-- ユーザー名変更 -->
            <v-text-field
              v-model="profile.username"
              label="ペンネーム(必須)"
              :rules="usernameRules"
              :counter="pennameMax"
              prepend-icon="mdi-account-circle-outline"
              required
            ></v-text-field>

            <!-- よく使うペン -->
            <v-select
              v-model="profile.favoriteArtSupply"
              :items="favoriteArtSupplyOptions"
              label="よく使うペン(任意)"
              :rules="favoriteArtSupplyRules"
              prepend-icon="mdi-fountain-pen"
            ></v-select>

            <!-- 自己紹介 -->
            <v-textarea
              v-model="profile.bio"
              label="自己紹介(任意)"
              :rules="bioRules"
              :counter="introductionMax"
              prepend-icon="mdi-text-account"
            ></v-textarea>
          </v-form>
        </v-card-text>
        <v-card-actions>
          <v-btn
            color="primary lighten-1"
            @click="resetDialog"
          >
            クリア
          </v-btn>
          <v-spacer></v-spacer>
          <v-btn color="grey lighten-2" @click="closeDialog">キャンセル</v-btn>
          <v-btn
            color="primary"
            :disabled="!valid"
            @click="saveProfile"
          >
            変更を保存
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
export default {
  layout: 'logged-in',
  data() {
    const pennameMax = 20
    const introductionMax = 200
      return {
      valid: true,
      dialog: false, // ダイアログの表示状態を管理
      // icon: null,
      pennameMax,
      introductionMax,
      usernameRules: [
        (v) => !!v || "ユーザー名は必須です",
        (v) => (v && v.length <= 20) || "ユーザー名は20文字以内で入力してください",
      ],
      favoriteArtSupplyOptions: [
        "デジタルペン : ペンタブレット(ペンタブ)",
        "デジタルペン : 液晶タブレット(液タブ)",
        "つけペン : Gペン",
        "つけペン : 丸ペン",
        "つけペン : カブラペン",
        "その他"
      ],
      favoriteArtSupplyRules: [],
      bioRules: [
        (v) => !v || (v && v.length <= 200) || "自己紹介は200文字以内で入力してください",
      ],
      profile:{
        // username: '初期ユーザー名',
        username: this.$store.state.user.current.name,
        ArtStyle: '未判定',
        favoriteArtSupply: '未設定',
        bio: 'プロフィールを編集して自己紹介を書こう！',
        icon: null
      }
    };
  },
  computed: {
    isOwnProfile() {
    // 現在のログインユーザーとそのユーザーが所有しているプロフィールIDとルートパラメータの :user_id が一致しているか
    const currentUserId = this.$store.state.user.current?.id;  // 現在のログインユーザーID
    const paramsId = Number(this.$route.params.id);       // URLのuser_idを数値化
    const profileUserId = this.$store.state.user.profile?.user_id;

    console.log("ログイン中のユーザーID:", currentUserId);
    console.log("プロフィールのID:", paramsId);
    console.log("URLのID:", profileUserId);

    return currentUserId === paramsId && paramsId === profileUserId;
    }
  },
  mounted() {
    // リロード時にプロフィール情報を取得
    const userId = this.$route.params.id;
    this.fetchProfile(userId);
  },
  methods: {
    // プロフィール情報を取得
    async fetchProfile(userId) {
      try {
        const response = await this.$axios.$get(`api/v1/users/${userId}/profiles`);
        if (response) {
          this.profile = {
            username: response.pen_name,
            ArtStyle: response.art_style ? response.art_style.name : "未判定",
            favoriteArtSupply: response.art_supply || "未設定",
            bio: response.introduction || "プロフィールを編集して自己紹介を書こう！",
          };
        }
      } catch (error) {
        console.error("プロフィール情報の取得に失敗", error);
      }
    },
    openDialog() {
      // ダイアログを開く前に、フォームの値を現在のプロフィールで初期化する処理を実装する予定
      this.dialog = true;
    },
    closeDialog() {
      this.dialog = false;
      // ダイアログを閉じるときにバリデーションをリセット
      this.valid = true;
       if (this.$refs.form) {
        this.$refs.form.resetValidation();
      }
      // this.$refs.form.reset();
    },
    resetDialog(){
      this.$refs.form.reset();
    },
     saveProfile() {
      if (this.$refs.form.validate()) {
        // バリデーション成功時の処理
        console.log("saveProfile メソッド実行");

        // 現在ログインしているユーザーのIDを取得 (Vuexから)
        const userId = this.$store.state.user.current.id;
        console.log(userId);

        // API にリクエストを送信
        this.$axios.$patch(`api/v1/users/${userId}/profiles`, {
          profile: {
            pen_name: this.profile.username,
            art_supply: this.profile.favoriteArtSupply,
            introduction: this.profile.bio,
          }
        })
        .then(response => {
          // APIリクエストが成功した場合の処理
          console.log('プロフィール更新成功', response);
          //  this.$refs.form.reset();
           this.closeDialog();
           // this.$store.dispatch('getProfileUser', this.username) でも可
           // ↑の場合は レスポンスからではなく、送信するデータの pen_name を Vuex に送っている
           this.$store.dispatch('getProfileUser', response)
        })
        .catch(error => {
          console.error('プロフィール更新失敗', error);
          // alert('プロフィールの更新に失敗しました。');
          const msg = 'プロフィールの更新に失敗しました。'
          return this.$store.dispatch('getToast', { msg })
        });
      }
    },
  },
};
</script>