<template>
  <v-container>

    <!-- fetch()が実行中は、このローディング表示だけを描画 -->
    <div v-if="$fetchState.pending" class="loading-container">
      <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
      <p class="mt-4 grey--text">ユーザー情報を読み込んでいます...</p>
    </div>

    <!-- fetch() でエラーが発生した場合のUI(404 を除く) -->
    <div v-else-if="$fetchState.error" class="error-container">
      <p class="text-h6">ページの読み込みに失敗しました。</p>
      <p class="grey--text">時間をおいて再度お試しください。</p>
      <v-btn color="primary" @click="$fetch">
        <v-icon left>mdi-refresh</v-icon>
        再試行
      </v-btn>
    </div>

    <div v-else>
      <v-row 
        v-if="profile"
        justify="center"
      >
        <v-col cols="12" md="8">
          <!-- プロフィール表示部分 -->
          <v-card>
            <!-- アイコン画像 -->
            <div class="avatar-wrapper my-4 ml-4">
              <v-avatar size="120">
                <v-img
                  v-if="rawProfile && rawProfile.avatar_url"
                  :src="profile.avatar_url"
                  alt="User Avatar"
                />
                <v-icon v-else size="120">mdi-account-circle</v-icon>
              </v-avatar>

              <!-- 削除ボタン（アイコンがある時だけ） -->
              <v-btn
                v-if="rawProfile && rawProfile.avatar_url"
                icon
                small
                color="error"
                class="avatar-delete-btn"
                @click="deleteAvatar"
              >
                <v-icon small>mdi-close</v-icon>
              </v-btn>
            </div>

            <v-card-title>現在のプロフィール</v-card-title>

            <v-card-text>
              <p>ペンネーム: {{ profile.username }}</p>
              <p>
                自分の絵柄: {{ profile.ArtStyle }}
                <!-- ここでもし未判定なら絵柄判定をするページへの誘導を作る -->
              </p>
              <p>よく使うペン: {{ profile.favoriteArtSupply || '未設定' }}</p>
              <p>自己紹介: {{ profile.bio }}</p>
            </v-card-text>

            <!-- フォロー情報 -->
            <v-card-text class="pt-0 text-center">
              <follow-stats
                :user-id="Number($route.params.id)"
                :following="followingCount"
                :followers="followersCount"
              />
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
          <div class="mt-2">
            <follow-form 
              v-if="$auth.loggedIn && !isOwnProfile"
              :user-id="Number($route.params.id)"
            />
          </div>
        </v-col>
      </v-row>
    </div>

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
            <!-- アイコン画像アップロード -->
            <v-file-input
              :key="iconInputKey"
              v-model="editProfile.iconFile"
              label="アイコン画像"
              accept="image/png, image/jpeg, image/jpg"
              prepend-icon="mdi-account-circle"
              @change="onIconChange"
            />

            <!-- ユーザー名変更 -->
            <v-text-field
              v-model="editProfile.username"
              label="ペンネーム(必須)"
              :rules="usernameRules"
              :counter="pennameMax"
              prepend-icon="mdi-account-circle-outline"
              required
            ></v-text-field>

            <!-- よく使うペン -->
            <v-select
              v-model="editProfile.favoriteArtSupply"
              :items="favoriteArtSupplyOptions"
              label="よく使うペン(任意)"
              :rules="favoriteArtSupplyRules"
              prepend-icon="mdi-fountain-pen"
            ></v-select>

            <!-- 自己紹介 -->
            <v-textarea
              v-model="editProfile.bio"
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
            :disabled="!valid || loading"
            :loading="loading"
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
import { translateErrorMessages } from '@/utils/validationMessages';

export default {
  layout: 'logged-in',
  data() {
    const pennameMax = 20
    const introductionMax = 200
      return {
      rawProfile: null,
      valid: true,
      loading: false,
      updateProfileSuccess: false,
      dialog: false, // ダイアログの表示状態を管理
      pennameMax,
      introductionMax,
      followingCount: 0,
      followersCount: 0,
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
      editProfile: { // 編集用オブジェクトを追加
        username: '',
        ArtStyle: '',
        favoriteArtSupply: '',
        bio: '',
        iconFile: null
      },
      iconInputKey: 0,
    };
  },

  async fetch() {
    const userId = this.$route.params.id;

    const followingPromise = this.$axios.get(`/api/v1/users/${userId}/following`);
    const followersPromise = this.$axios.get(`/api/v1/users/${userId}/followers`);

    const [followingResponse, followersResponse] = await Promise.all([followingPromise, followersPromise]);

    this.followingCount = followingResponse.data.length;
    this.followersCount = followersResponse.data.length;

    try {
      await this.$axios.get(`/api/v1/users/${userId}`);
  
      try {
        const profileResponse = await this.$axios.get(`/api/v1/users/${userId}/profiles`);
        this.rawProfile = profileResponse.data;
      } catch (profileError) {
        // プロフィールがない(404)場合は、rawProfileをnullにする
        if (profileError.response && profileError.response.status === 404) {
          this.rawProfile = null;
        } else {
          // プロフィール取得時の予期せぬエラーは throw する
          throw profileError;
        }
      }
    } catch (userError) {
      // ユーザー取得が失敗した場合（ユーザーが存在しない）
      if (userError.response && userError.response.status === 404) {
        return this.$nuxt.error({ statusCode: 404, message: 'お探しのユーザーは見つかりませんでした' });
      }
      throw userError;
    }
  },

  computed: {
    // 表示用に整形したプロフィールデータ
    profile() {
      // プロフィールデータ(rawProfile)が存在しない場合
      if (!this.rawProfile) {
        return {
          username: '未設定',
          ArtStyle: '未判定',
          favoriteArtSupply: '未設定',
          bio: 'プロフィールを編集して自己紹介を書こう！',
          avatar_url: null,
        };
      }

      // プロフィールデータが存在する場合
      return {
        username: this.rawProfile.pen_name,
        ArtStyle: this.rawProfile.art_style ? this.rawProfile.art_style.name : '未判定',
        favoriteArtSupply: this.rawProfile.art_supply || null,
        bio: this.rawProfile.introduction || 'プロフィールを編集して自己紹介を書こう！',
        avatar_url: this.rawProfile.avatar_url || null
      };
    },

    isOwnProfile() {
    // 現在のログインユーザーとルートパラメータの :user_id が一致しているか
    const currentUserId = this.$store.state.user.current?.id;
    const paramsId = Number(this.$route.params.id);

    return currentUserId === paramsId; // プロフィールIDのチェックを削除
    }
  },

  methods: {
    openDialog() {
      // rawProfileを元に編集用データを作成する
      if (this.rawProfile) {
        // プロフィールが存在する場合
        this.editProfile = {
          username: this.rawProfile.pen_name,
          favoriteArtSupply: this.rawProfile.art_supply || null, // 設定されていなければ null
          bio: this.rawProfile.introduction || null, // 設定されていなければ null
          iconFile: null,
        };
      } else {
        // プロフィールがまだ存在しない場合（新規作成）
        this.editProfile = {
          username: this.$store.state.user?.current.name, // ログインユーザー名を初期値に
          favoriteArtSupply: null,
          bio: null,
          iconFile: null,
        };
      }
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

    async saveProfile() {
      if (this.$refs.form.validate()) {
        this.loading = true;
        const startTime = Date.now(); // 開始時間を記録
        // 現在ログインしているユーザーのIDを取得 (Vuexから)
        const userId = this.$store.state.user.current?.id;

        const formData = new FormData();
        formData.append('profile[pen_name]', this.editProfile.username);

        if (this.editProfile.favoriteArtSupply) {
          formData.append('profile[art_supply]', this.editProfile.favoriteArtSupply);
        }

        if (this.editProfile.bio) {
          formData.append('profile[introduction]', this.editProfile.bio);
        }

        if (this.editProfile.iconFile) {
          formData.append('profile[avatar]', this.editProfile.iconFile);
        }

        try {
          // API にリクエストを送信
          const response = await this.$axios.$patch(`api/v1/users/${userId}/profiles`, formData);

          // APIリクエストが成功した場合の処理
          console.log('プロフィール更新成功', response);
          // 更新をしたプロフィール情報をセット
          this.rawProfile = response; 
          this.$store.dispatch('getProfileUser', response)
          this.updateProfileSuccess = true;
        } catch (error) {
          if (error.response && error.response.status === 422) {
            console.error('プロフィール更新失敗', error);
            // alert('プロフィールの更新に失敗しました。');
            // const msg = 'プロフィールの更新に失敗しました。';
            const errors = error.response.data.errors;
            const msgArray = errors || [];
  
            // 翻訳関数を使用
            const translated = translateErrorMessages(msgArray);
            this.$store.dispatch('getToast', { msg: translated })
          } else {
            // 不明なエラーの場合に対応
            const msg = ['プロフィールの更新に失敗しました。'];
            this.$store.dispatch('getToast', { msg });
          }
          this.updateProfileSuccess = false;
        } finally {
          // this.loading = false
          const elapsed = Date.now() - startTime;
          const minDuration = 500; // 最低500ms(0.5秒)はローディング。こちらは速さ重視。
          const remainingTime = Math.max(minDuration - elapsed, 0);

          setTimeout(() => {
            this.loading = false;
            // 成功した時のダイアログを閉じる(updateProfileSuccess = true)
            if (this.updateProfileSuccess) {
              this.closeDialog();
            }
          }, remainingTime);
        }
      }
    },

    resetIconInput() {
      this.iconInputKey += 1;
    },

    onIconChange(file) {
      if (!file) {
        this.editProfile.iconFile = null;
        this.resetIconInput();
        return;
      }

      const allowedTypes = ['image/png', 'image/jpeg', 'image/jpg'];
      if (!allowedTypes.includes(file.type)) {
        this.$store.dispatch('getToast', { msg: ['対応していないファイル形式です(png, jpg, jpegのみ)'] });
        this.editProfile.iconFile = null;
        this.resetIconInput();
        return;
      }

      const maxSize = 5 * 1024 * 1024;
      if (file.size > maxSize) {
        this.$store.dispatch('getToast', { msg: ['ファイルサイズは5MB以下にしてください'] });
        this.editProfile.iconFile = null;
        this.resetIconInput();
        return;
      }

      this.editProfile.iconFile = file;
    },

    async deleteAvatar() {
      const userId = this.$store.state.user.current?.id;

      try {
        await this.$axios.delete(`/api/v1/users/${userId}/profiles/destroy_avatar`);

        this.rawProfile.avatar_url = null;

        this.editProfile.iconFile = null;
        this.resetIconInput();

        this.$store.dispatch('getToast', { msg:['アイコンを削除しました'] });
      } catch (error) {
        this.$store.dispatch('getToast', { msg: ['アイコンの削除に失敗しました'] });
      }
    }

  },
};
</script>

<style scoped>
.loading-container, .error-container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 80vh;
}

.avatar-wrapper {
  position: relative;
  display: inline-block;
}

.avatar-delete-btn {
  position: absolute;
  top: -6px;
  right: -8px;
  background-color: white;
}

</style>
