<template>
  <v-container>
    <v-row justify="center">
      <v-col cols="12" md="8">
        <!-- プロフィール表示部分 -->
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
              v-model="username"
              label="ペンネーム"
              :rules="usernameRules"
              prepend-icon="mdi-account-circle-outline"
              required
            ></v-text-field>

            <!-- よく使うペン -->
            <v-select
              v-model="favoriteArtSupply"
              :items="favoriteArtSupplyOptions"
              label="よく使うペン"
              :rules="favoriteArtSupplyRules"
              prepend-icon="mdi-fountain-pen"
              required
            ></v-select>

            <!-- 自己紹介 -->
            <v-textarea
              v-model="bio"
              label="自己紹介"
              :rules="bioRules"
              prepend-icon="mdi-text-account"
            ></v-textarea>
          </v-form>
        </v-card-text>
        <v-card-actions>
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
      return {
      valid: true,
      dialog: false, // ダイアログの表示状態を管理
      // icon: null,
      username: "",
      usernameRules: [
        (v) => !!v || "ユーザー名は必須です",
        (v) => (v && v.length <= 20) || "ユーザー名は20文字以内で入力してください",
      ],
      favoriteArtSupply: null,
      favoriteArtSupplyOptions: [
        "デジタルペン : ペンタブレット(ペンタブ)",
        "デジタルペン : 液晶タブレット(液タブ)",
        "つけペン : Gペン",
        "つけペン : 丸ペン",
        "つけペン : カブラペン",
        "その他"
      ],
      favoriteArtSupplyRules: [
        (v) => !!v || "よく使うペンを選択してください",
      ],
      bio: "",
      bioRules: [
        (v) => (v && v.length <= 200) || "自己紹介は200文字以内で入力してください",
      ],
      profile:{
        username: '初期ユーザー名',
        ArtStyle: '未判定',
        favoriteArtSupply: '未設定',
        bio: 'プロフィールを編集して自己紹介を書こう！',
        icon: null
      }
    };
  },
  mounted() {
    console.log('myProfile.vue mounted フック実行'); // 追記
    console.log('fetchProfile() 呼び出し前'); // 追記
    // リロード時にプロフィール情報を取得
    this.watchUserCurrent();
    console.log('fetchProfile() 呼び出し後'); // 追記
  },
  methods: {
    watchUserCurrent() { // ウォッチャーメソッド
    const unwatch = this.$watch( // `$watch` の戻り値（解除関数）を unwatch 変数に保存
      () => this.$store.state.user.current, // 監視する値
      (newValue, oldValue) => { // 値が変化した時の処理
        console.log('user.current が変化しました:', newValue);
        if (newValue) { // newValue が truthy (null, undefined でない) なら初期化完了とみなす
          console.log('user.current が初期化されたので fetchProfile() を実行します');
          this.fetchProfile(); // プロフィール情報取得
          unwatch(); // 保存した解除関数を呼び出してウォッチャーを解除
        }
      }
    );
  },
    // プロフィール情報を取得
    async fetchProfile() {
      try {
        console.log("Vuex user state:", this.$store.state.user.current.id); 
        const userId = this.$store.state.user.current; // Vuex からログイン中のユーザーID取得
        
        const response = await this.$axios.$get(`api/v1/profiles/${userId.id}`);
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
    },
     saveProfile() {
      if (this.$refs.form.validate()) {
        // バリデーション成功時の処理
        console.log("saveProfile メソッド実行");

        // 現在ログインしているユーザーのIDを取得 (Vuexから)
        const userId = this.$store.state.user.current.id;
        console.log(userId);

        // API にリクエストを送信
        this.$axios.$patch(`api/v1/profiles/${userId}`, {
          profile: {
            pen_name: this.username,
            art_supply: this.favoriteArtSupply,
            introduction: this.bio,
          }
        })
        .then(response => {
          // APIリクエストが成功した場合の処理
          console.log('プロフィール更新成功', response);
          // プロフィールデータの更新
          this.profile = {
              username: this.username,
              favoriteArtSupply: this.favoriteArtSupply,
              bio: this.bio,
           }
           this.closeDialog();
        })
        .catch(error => {
          console.error('プロフィール更新失敗', error);
          alert('プロフィールの更新に失敗しました。');
        });
      }
    },
  },
};
</script>