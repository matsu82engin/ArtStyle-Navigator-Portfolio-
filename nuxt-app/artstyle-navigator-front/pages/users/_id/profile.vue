<template>
  <v-container>
    <v-row justify="center">
      <v-col cols="12" md="8">
        <!-- プロフィール表示部分 -->
        <v-card>
          <v-card-title>現在のプロフィール</v-card-title>
          <v-card-text>
            <p>ユーザー名: {{ profile.username }}</p>
            <p>自分の絵柄: {{ profile.ArtStyle }}</p>
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
      max-width="600"
    >
      <v-card>
        <v-card-title>プロフィール編集</v-card-title>
        <v-card-text>
          <v-form
            ref="form"
            v-model="valid"
            lazy-validation
          >
            <!-- アイコン変更 -->
            <v-file-input
              v-model="icon"
              label="アイコンを選択"
              accept="image/*"
              prepend-icon="mdi-camera"
            ></v-file-input>

            <!-- ユーザー名変更 -->
            <v-text-field
              v-model="username"
              label="ユーザー名"
              :rules="usernameRules"
              required
            ></v-text-field>

            <!-- 自分の絵柄 -->
            <v-select
              v-model="artStyle"
              :items="artStyleTypeOptions"
              label="自分の絵柄"
              :rules="artStyleRules"
              required
            ></v-select>

            <!-- よく使うペン -->
            <v-select
              v-model="favoriteArtSupply"
              :items="favoriteArtSupplyOptions"
              label="よく使うペン"
              chips
              :rules="favoriteArtSupplyRules"
              required
            ></v-select>

            <!-- 自己紹介 -->
            <v-textarea
              v-model="bio"
              label="自己紹介"
              :rules="bioRules"
            ></v-textarea>
          </v-form>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="grey" @click="closeDialog">キャンセル</v-btn>
          <v-btn color="primary"
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
      icon: null,
      username: "",
      usernameRules: [
        (v) => !!v || "ユーザー名は必須です",
        (v) => (v && v.length <= 20) || "ユーザー名は20文字以内で入力してください",
      ],
      artStyle: null,
      artStyleTypeOptions: [
        "リアル系",
        "デフォルメ",
        "ゆる系",
        "萌え系",
        "劇画調",
        "レトロ調",
        "コミックタッチ"
      ],
      artStyleRules: [
        (v) => !!v || "絵柄を選択してください",
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
        ArtStyle: '',
        favoriteArtSupply: '',
        bio: 'プロフィールを編集して自己紹介を書こう！',
        icon: null
      }
    };
  },
  methods: {
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
        console.log("プロフィールの変更を保存します");
        this.profile = {
            username: this.username,
            artStyle: this.artStyle,
            favoriteArtSupply: this.favoriteArtSupply,
            bio: this.bio,
            icon: this.icon
         }
         this.closeDialog();
         // ここでAPIとの連携処理を行う
      }
    },
  },
};
</script>