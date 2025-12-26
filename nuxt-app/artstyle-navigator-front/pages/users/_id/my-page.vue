<template>
  <v-container>
    <div v-if="$fetchState.pending" class="loading-container">
      <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
      <p class="mt-4 grey--text">ユーザー情報を読み込んでいます...</p>
    </div>

    <div v-else-if="$fetchState.error" class="error-container">
      <p class="text-h6">ページの読み込みに失敗しました。</p>
      <p class="grey--text">時間をおいて再度お試しください。</p>
      <v-btn color="primary" @click="$fetch">
        <v-icon left>mdi-refresh</v-icon>
        再試行
      </v-btn>
    </div>

    <v-row v-else>
      
      <!-- ユーザー情報セクション => コンポーネント化できそう -->
      <v-col cols="12" md="4">
        <v-card>
          <v-card-text class="text-center">
            <!-- ユーザーアイコン -->
            <v-avatar size="128" class="mb-4">
              <!-- <img src="https://placekitten.com/128/128" alt="User Avatar" /> -->
              <!-- <img v-if="profile.icon" :src="profile.icon" alt="User Avatar" />
              <v-icon v-else size="128">mdi-account-circle</v-icon> -->
            </v-avatar>

            <!-- ユーザー名と特徴 -->
            <h2 class="mb-2">ユーザー名</h2>
            <h2 v-if="profile" class="mb-2">{{ profile.username }}</h2>

            <p class="text-subtitle-1">自己紹介文</p>
            <p v-if="profile" class="text-subtitle-1">{{ profile.bio }}</p> 
            
            <!-- フォロー情報 -->
            <div class="d-flex justify-center my-4">
              <follow-stats

                :user-id="Number($route.params.id)"
                :following="followingCount"
                :followers="followersCount"
              />
            </div>

            <!-- フォローフォーム -->
            <div class="d-flex justify-center my-4">
              <follow-form
                v-if="$auth.loggedIn && !isOwnPage"
                :user-id="Number($route.params.id)"
              />
            </div>

            <!-- プロフィール編集ボタン -->
            <v-btn
              v-if="isOwnPage" 
              color="primary"
              :to="$my.projectLinkTo($authentication.user.id, 'users-id-my-profile')">
              プロフィール編集
            </v-btn>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- 投稿フィードセクション -->
      <v-col cols="12" md="8">
        <!-- この投稿フォーム(PostForm)もコンポーネント化できそう -->
        <v-card
          v-if="isOwnPage" 
        >
          <v-card-title>
            投稿する
          </v-card-title>
          <v-form
            ref="form"
            lazy-validation
          >
            <v-card-text>
              <!-- 画像の添付 -->
              <v-file-input
                :key="fileInputKey"
                label="画像を選択"
                accept="image/png, image/jpeg, image/jpg"
                @change="onFileChange"
              ></v-file-input>

              <v-text-field
                v-model="newPost.title"
                label="タイトル(必須)"
                :counter="titleMax"
                :rules="titleRules"
              ></v-text-field>

              <!-- 絵柄の選択 -->
              <v-select
                v-model="newPost.artStyleId"
                label="絵柄を選択(必須)"
                :items="artStyles"
                item-text="name"
                item-value="id"
                :rules="artStyleRules"
              ></v-select>

              <!-- キャプション -->
              <v-text-field
                v-model="newPost.caption"
                label="絵の説明(任意)"
                :counter="captionMax"
                :rules="captionRules"
              ></v-text-field>
            </v-card-text>

            <v-card-actions class="justify-end">
              <v-btn 
                color="primary"
                :disabled="!isFormValid"
                :loading="loading"
                @click="createPost"
              >
                投稿する
              </v-btn>
            </v-card-actions>
          </v-form>
        </v-card>
        <!-- ここまでPostForm -->

        <!-- 正常に取得できた場合の表示（投稿がある場合） -->
        <div v-if="posts.length > 0">
          <v-card
            v-for="post in posts"
            :key="post.id"
            class="mt-4"
          >
            <!-- ここには元の <v-card> の中身（v-card-titleからv-card-actionsまで）をそのまま入れる -->
            <v-card-title class="d-flex align-center">
              <!-- アバターと名前 -->
              <v-avatar size="40" class="mr-3">
                <img src="#" alt="User Avatar" />
              </v-avatar>
              <span class="font-weight-medium">ユーザー名</span>

              <v-spacer></v-spacer>

              <v-menu offset-y>
                <template #activator="{ on, attrs }">
                  <v-btn icon v-bind="attrs" v-on="on">
                    <v-icon>mdi-dots-horizontal</v-icon>
                  </v-btn>
                </template>
                <v-list>
                  <v-list-item
                    v-if="isOwnPage"
                    :disabled="isDeleting"
                    @click="deletePost(post.id)"
                  >
                    <v-list-item-icon>
                      <v-icon>mdi-trash-can-outline</v-icon>
                    </v-list-item-icon>
                    <v-list-item-content>
                      <v-list-item-title>削除</v-list-item-title>
                    </v-list-item-content>
                  </v-list-item>
                </v-list>
              </v-menu>
            </v-card-title>

            <v-card-subtitle class="font-weight-bold text-h6">
              {{ post.title }}
            </v-card-subtitle>
            <div v-if="post.post_images && post.post_images.length > 0">
              <!-- 将来的に複数画像になっても対応できるように v-for を使う -->
              <div v-for="image in post.post_images" :key="image.id">

                <v-img
                  v-if="image.image_url"
                  :src="image.image_url"
                  :alt="image.caption"
                  class="white--text align-end"
                  gradient="to bottom, rgba(0,0,0,.1), rgba(0,0,0,.5)"
                  max-height="500px"
                  contain
                >
                </v-img>

                <!-- PostImageのcaption -->
                <v-card-text>
                  説明: {{ image.caption }}
                </v-card-text>

                <!-- PostImageに紐づく絵柄 -->
                <v-card-text v-if="image.art_style">
                  絵柄: {{ image.art_style.name }}
                </v-card-text>

                <v-card-actions>
                  <v-btn icon>
                    <!-- いいね数アイコン  -->
                    <v-icon>mdi-heart</v-icon>
                    <!-- 押すとカウントが増えるようにする -->
                  </v-btn>
                </v-card-actions>
              </div>
            </div>
          </v-card>
        </div>

        <!-- 正常に取得できたが、投稿が1件もなかった場合の表示 -->
        <v-alert
          v-else
          type="info"
          outlined
          class="mt-6"
        >
          まだ投稿がありません
        </v-alert>

      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { translateErrorMessages } from '@/utils/validationMessages';
export default {
  name: 'MyPage',
  layout: 'logged-in',
  data() {
    const titleMax = 50;
    const captionMax = 1000;
    return {
      newPost: {
        title: '',
        artStyleId: null,
        caption: '',
        imageFile: null,
      },
      posts: [], // fetchPost() で取得した投稿一覧のデータが入る
      profileUser: null,
      artStyles: [], // fetchArtStyles() で取得した絵柄一覧が入る
      fileInputKey: 0,
      selectedArtStyleId: null,
      loading: false,
      isDeleting: false, // 削除処理中かどうかのフラグ
      titleMax,
      captionMax,
      followingCount: 0,
      followersCount: 0,
      titleRules: [
        // 入力必須
        v => !!v || "投稿タイトルは必須です",
        v => !v || v.length <= titleMax || `${titleMax}文字以内で入力してください`
      ],
      artStyleRules: [
        // 入力必須
        v => !!v || "画像の絵柄選択は必須です",
      ],
      captionRules: [
        // 1000文字制限
        v => !v || v.length <= captionMax || `${captionMax}文字以内で入力してください`
      ],
    }
  },

  async fetch() {
    const userId = this.$route.params.id;
    try {
      // プロフィール取得のPromise。失敗した場合は null を返すようにする
      const profilePromise = this.$axios.get(`/api/v1/users/${userId}/profiles`)
        .catch(error => {
          // プロフィール取得が404エラーの場合は、失敗と見なさない（正常系として扱う）
          if (error.response && error.response.status === 404) {
            return { data: null }; // プロフィールがない場合は null データとして返す
          }
          // それ以外のエラー（500など）は、Promise.all全体を失敗させるためにエラーを再度throwする
          throw error;
        });

      // 投稿一覧取得のPromise。こちらは失敗したらページ全体のエラーとしたいので、catchは付けない
      const postsPromise = this.$axios.get(`/api/v1/users/${userId}/posts`);

      const followingPromise = this.$axios.get(`/api/v1/users/${userId}/following`);
      const followersPromise = this.$axios.get(`/api/v1/users/${userId}/followers`);

      const [
        postsResponse,
        profileResponse,
        followingResponse,
        followersResponse
      ] = await Promise.all([
        postsPromise,
        profilePromise,
        followingPromise,
        followersPromise
      ]);

      this.posts = postsResponse.data;
      this.profileUser = profileResponse.data; // プロフィールがない場合は null が入る
      this.followingCount = followingResponse.data.length;
      this.followersCount = followersResponse.data.length;

      await this.fetchArtStyles();

    } catch (error) {
      // ここに来るエラーは「ユーザーが存在しない(postsが404)」か「サーバーエラー(500)」
      if (error.response && error.response.status === 404) {
        return this.$nuxt.error({ statusCode: 404, message: 'お探しのユーザーは見つかりませんでした' });
      }
      // サーバーエラーなど、その他の致命的なエラー
      throw error;
    }
  },

  computed: {
    // 表示用に整形したプロフィールデータ
    profile() {
      // プロフィールデータ(rawProfile)が存在しない場合
      if (!this.profileUser) {
        return {
          username: '未設定',
          ArtStyle: '未判定',
          favoriteArtSupply: '未設定',
          bio: 'プロフィールを編集して自己紹介を書こう！',
          icon: null,
        };
      }

      // プロフィールデータが存在する場合
      return {
        username: this.profileUser.pen_name,
        ArtStyle: this.profileUser.art_style ? this.profileUser.art_style.name : '未判定',
        favoriteArtSupply: this.profileUser.art_supply || '未設定',
        bio: this.profileUser.introduction || 'プロフィールを編集して自己紹介を書こう！',
        icon: this.profileUser.icon || '未設定',
      };
    },

    isFormValid() {
      // newPostオブジェクトの必須項目がすべて「truthy」（空文字やnullでない）かをチェック
      return !!this.newPost.title && !!this.newPost.artStyleId && !!this.newPost.imageFile;
    },

    isOwnPage() {
    // 現在のログインユーザーとルートパラメータの :user_id が一致しているか
    const currentUserId = this.$store.state.user.current?.id; // 現在のログインユーザーID
    const paramsId = Number(this.$route.params.id); // URLのuser_idを数値化

    console.log("ログイン中のユーザーID:", currentUserId);
    console.log("入力されたID:", paramsId);

    return currentUserId === paramsId; // プロフィールIDのチェックを削除
    }
  },

//  画像に rules を追加するようなことがあれば以下を追加 
//   watch: {
//   'newPost.imageFile'(newFile) {
//     if (!newFile) {
//       this.$refs.form?.resetValidation?.(); // バリデーションリセット
//     }
//   }
// },

  methods: {
    resetFileInput() {
      this.fileInputKey += 1; // keyを変更するとv-file-inputが再描画され完全リセット
    },

    async createPost() {
      if (!this.$refs.form.validate()) {
        return; // バリデーションが失敗したら中断
      }

      // 画像必須チェック（絵柄選択とは別に）
      if (!this.newPost.imageFile) {
        this.$store.dispatch('getToast', { msg: ['画像ファイルを選択してください'] });
        return;
      }

      this.loading = true; // ここでローディング開始
      const startTime = Date.now(); // 開始時間を記録

      const formData = new FormData();
      formData.append('post[title]', this.newPost.title);
      formData.append('post[post_images_attributes][0][art_style_id]', this.newPost.artStyleId);
      formData.append('post[post_images_attributes][0][caption]', this.newPost.caption);
      // 他にも position や tips などがあればここに追加

      if (this.newPost.imageFile) {
        formData.append('post[post_images_attributes][0][image]', this.newPost.imageFile);
      }

      // 現在ログインしているユーザーのIDを取得 (Vuexから)
      const userId = this.$store.state.user.current?.id;
      console.log(userId);

      try {
        // 組み立てたデータを送信
        await this.$axios.post(`/api/v1/users/${userId}/posts`, formData);

        this.$refs.form.reset() 
        this.newPost.imageFile = null;
        await this.fetchPosts(userId);
      } catch (error) {
        console.error('投稿に失敗しました:', error);
        const errors = error.response.data.errors;
        const msgArray = errors || [];
        const translated = translateErrorMessages(msgArray);
        this.$store.dispatch('getToast', { msg: translated })
      } finally {
        const elapsed = Date.now() - startTime;
        const minDuration = 500; // 最低500ms(0.5秒)はローディング表示
        const remainingTime = Math.max(minDuration - elapsed, 0);

        setTimeout(() => {
          this.loading = false;
        }, remainingTime);
      }
    },

    onFileChange(file) {
      // this.newPost.imageFile = file;

      // ファイルチェック
      if (!file) {
        // this.newPost.imageFile = null;
        // return
        this.newPost.imageFile = null;
        this.resetFileInput(); // ← これを呼ぶ
        return;
      }

      // 拡張子チェック
      const allowedTypes = ['image/png', 'image/jpg', 'image/jpeg'];
      if (!allowedTypes.includes(file.type)) {
        this.$store.dispatch('getToast', { msg: ['対応していないファイル形式です(png, jpg, jpegのみ)']})
        this.newPost.imageFile = null;
        this.resetFileInput(); // ← これを呼ぶ
        return;
      }

      // サイズチェック
      const maxSize = 5 * 1024 * 1024;
      if (file.size > maxSize) {
        this.$store.dispatch('getToast', { msg: ['ファイルサイズは5MB以下にしてください'] });
        this.newPost.imageFile = null;
        this.resetFileInput();
        return;
      }

      // 問題なければセット
      this.newPost.imageFile = file;
    },

    async deletePost(postId) {
      if (this.isDeleting) return; // 処理中(true)なら何もしない（連打防止）
      if (!confirm("この投稿を削除してよろしいですか？")) return;

      this.isDeleting = true;
      const userId = this.$store.state.user.current.id;

      try {
        await this.$axios.$delete(`/api/v1/users/${userId}/posts/${postId}`);
        // 投稿一覧から削除された投稿を除外する
        this.posts = this.posts.filter(post => post.id !== postId);
      } catch (error) {
        console.error("削除失敗:", error);
        const msg = ['削除に失敗しました']
        this.$store.dispatch('getToast', { msg })
      } finally {
        this.isDeleting = false;
      }
    },

    // マイページを開いた時に今まで投稿したデータを取得するメソッドが必要
    async fetchPosts(userId) {
      try {
        const response = await this.$axios.get(`/api/v1/users/${userId}/posts`) // 自分の投稿一覧API これはつまり投稿したものを取り出している
        this.posts = response.data
        console.log('レスポンスデータ:', response.data);
      } catch (error) {
        if (error.response && error.response.status === 404) {
          return this.$nuxt.error({
            statusCode: 404,
            message: 'お探しのユーザーは見つかりませんでした'
          });
        } 
        // 404 以外のエラーの場合
        console.error('投稿一覧の取得に失敗しました:', error);
        // トースターは画面に直接エラー情報を出すので必要なし
        throw error;
      }
    },

    async fetchArtStyles() {
      try {
        const response = await this.$axios.get('/api/v1/art_styles')
        this.artStyles = response.data
      } catch (error) {
        console.error('絵柄の取得に失敗しました:', error);
      }
    }
  },
}
</script>

<style scoped>
.loading-container, .error-container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 80vh;
}
</style>
