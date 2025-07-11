<template>
  <v-container>
    <v-row>
      <!-- ユーザー情報セクション => コンポーネント化できそう -->
      <v-col cols="12" md="4">
        <v-card>
          <v-card-text class="text-center">
            <!-- ユーザーアイコン -->
            <v-avatar size="128" class="mb-4">
              <!-- <img src="https://placekitten.com/128/128" alt="User Avatar" /> -->
            </v-avatar>

            <!-- ユーザー名と特徴 -->
            <!-- <h2 class="mb-2">ユーザー名</h2> -->
            <h2 class="mb-2">{{ $authentication.user.name }}</h2>
            <p class="text-subtitle-1">自己紹介文</p>

            <!-- フォロー情報 -->
            <div class="d-flex justify-center my-4">
              <div class="mr-4">
                <strong>100</strong> フォロー中
              </div>
              <div>
                <strong>200</strong> フォロワー
              </div>
            </div>

            <!-- プロフィール編集ボタン -->
            <v-btn 
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
        <v-card>
          <v-card-title>
            投稿する
          </v-card-title>
          <v-card-text>
            <!-- 投稿テキストエリア -->
            <v-textarea
              label="いま何してる？"
              rows="3"
              auto-grow
            ></v-textarea>

            <v-text-field
              v-model="newPost.title"
              label="タイトル(必須)"
            ></v-text-field>

            <!-- 絵柄の選択 -->
            <v-select
              v-model="newPost.artStyleId"
              label="絵柄を選択(必須)"
              :items="artStyles"
              item-text="name"
              item-value="id"
            ></v-select>

            <!-- キャプション -->
            <v-text-field
              v-model="newPost.caption"
              label="絵の説明(任意)"
            ></v-text-field>
          </v-card-text>

          <v-card-actions class="justify-end">
            <v-btn 
              color="primary"
              @click="createPost"
            >
              投稿する
            </v-btn>
          </v-card-actions>
        </v-card>
        <!-- ここまでPostForm -->

        <!-- 投稿一覧 -->
        <v-card
          v-for="post in posts"
          :key="post.id"
          class="mt-4"
        >

        <!-- 
          ここもコンポーネント化できる。
          ただし、v-for は除いてコンポーネント化して、
          このページで v-for を使う。
        -->
          <v-card-title class="d-flex align-center">
            <!-- アバターと名前 -->
            <v-avatar size="40" class="mr-3">
              <img src="#" alt="User Avatar" />
            </v-avatar>
            <span class="font-weight-medium">ユーザー名</span>

          <v-spacer></v-spacer>
          <v-menu offset-y>
              <template #activator="{ on, attrs }">
                <v-btn
                  icon
                  v-bind="attrs"
                  v-on="on"
                  >
                   <!-- <v-icon>mdi-dots-vertical</v-icon> 縦の３点リーダー -->
                   <v-icon>mdi-dots-horizontal</v-icon>
                </v-btn>
              </template>
              <v-list>
                <v-list-item
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

          <!-- 投稿タイトル表示 -->
          <v-card-subtitle class="font-weight-bold text-h6">
            {{ post.title }}
          </v-card-subtitle>

          <div v-if="post.post_images && post.post_images.length > 0">
          <!-- 将来的に複数画像になっても対応できるように v-for を使う -->
            <div v-for="image in post.post_images" :key="image.id">
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
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
export default {
  name: 'MyPage',
  layout: 'logged-in',
  data() {
    return {
      newPost: {
        title: '',
        artStyleId: null,
        caption: ''
      },
      posts: [], // fetchPost() で取得した投稿一覧のデータが入る
      artStyles: [], // fetchArtStyles() で取得した絵柄一覧が入る
      selectedArtStyleId: null,
    }
  },
  mounted() {
    this.fetchPosts();
    this.fetchArtStyles();
  },
  methods: {
    // async createPost() {
    //   if (!this.newPost.title || !this.newPost.artStyleId) return

    //   try {
    //     const response = await this.$axios.post('/api/v1/posts', {
    //       post: {
    //         title: this.newPost.title,
    //         post_images_attributes: [
    //           {
    //             art_style_id: this.newPost.artStyleId,
    //             // 複数画像が送信できるようになったら position は変更
    //             position: 0,
    //             caption: this.newPost.caption
    //           }
    //         ]
    //       }
    //     })

    //     // 投稿成功後、初期化やリロード
    //     this.newPost.title = ''
    //     this.newPost.artStyleId = null
    //     this.newPost.caption = ''
    //     await this.fetchPosts()
    //   } catch (error) {
    //     console.error('投稿に失敗しました:', error)
    //   }
    // },
    // 本来の投稿メソッドではない
    async createPost() {
      // titleが空なら何もしない
      if (!this.newPost.title) {
        alert('タイトルと絵柄は必須です。');
        return;
      }

      // 送信するデータを組み立てる
      const postData = {
        post: {
          title: this.newPost.title,
          post_images_attributes: [
            {
              art_style_id: this.newPost.artStyleId,
              caption: this.newPost.caption,
              // 他にも position や tips などがあればここに追加
            }
          ]
        }
      };

      try {
        // 組み立てたデータを送信
        await this.$axios.post('/api/v1/posts', postData);

        this.newPost.title = '';
        this.newPost.artStyleId = null;
        this.newPost.caption = '';
        await this.fetchPosts();
      } catch (error) {
        console.error('投稿に失敗しました:', error);
        // alert('投稿に失敗しました。');
        const errors = error.response.data.errors;
        const msgArray = errors || [];
        const translated = translateErrorMessages(msgArray);
        this.$store.dispatch('getToast', { msg: translated })
      }
    },

    async deletePost(postId) {
      if (!confirm("この投稿を削除してよろしいですか？")) return;

      try {
        await this.$axios.$delete(`/api/v1/posts/${postId}`);
        // 投稿一覧から削除された投稿を除外する
        this.posts = this.posts.filter(post => post.id !== postId);
      } catch (error) {
        console.error("削除失敗:", error);
        alert("削除に失敗しました");
      }
    },

    // マイページを開いた時に今まで投稿したデータを取得するメソッドが必要
    async fetchPosts() {
      try {
        const response = await this.$axios.get('/api/v1/posts') // 自分の投稿一覧API これはつまり投稿したものを取り出している
        this.posts = response.data
        console.log('レスポンスデータ:', response.data);
      } catch (error) {
        console.error('投稿一覧の取得に失敗しました:', error);
      }
    },
    async fetchArtStyles() {
      try {
        const response = await this.$axios.get('/api/v1/art_styles')
        this.artStyles = response.data
      } catch (error) {
        console.error('絵柄の取得に失敗しました:', error)
      }
    }
  },
}
</script>
