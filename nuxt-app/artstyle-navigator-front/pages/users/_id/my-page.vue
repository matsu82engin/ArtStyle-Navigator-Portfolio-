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
              label="タイトル(必須)"
              v-model="newPost.title"
            ></v-text-field>

            <!-- 絵柄の選択 -->
            <v-select
              label="絵柄を選択(必須)"
              :items="artStyles"
              item-text="name"
              item-value="id"
              v-model="newPost.artStyleId"
            ></v-select>

            <!-- キャプション -->
            <v-text-field
              label="絵の説明(任意)"
              v-model="newPost.caption"
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
        <!-- <v-card 
          v-for="post in 3"
          :key="post"
          class="mt-4"
        > -->
          <v-card-title>
            <v-list-item class="pa-0">
              <v-list-item-avatar>
                <v-avatar>
                    <img src="#" alt="User Avatar">
                </v-avatar>
              </v-list-item-avatar>
              <v-list-item-content>
                  <v-list-item-title>ユーザー名</v-list-item-title>
              </v-list-item-content>
          </v-list-item>
          <!-- ここの v-spacer の意味は？ -->
          <v-spacer></v-spacer>
          <v-menu offset-y>
              <template #activator="{ on, attrs }">
                <v-btn
                  icon
                  v-bind="attrs"
                  v-on="on"
                  >
                   <v-icon>mdi-dots-vertical</v-icon>
                </v-btn>
              </template>
              <v-list>
                <v-list-item>
                  <v-list-item-title>削除</v-list-item-title>
                </v-list-item>
              </v-list>
            </v-menu>
          </v-card-title>

          <!-- 投稿タイトル表示 -->
          <v-card-subtitle class="font-weight-bold text-h6">
            {{ post.title }}
          </v-card-subtitle>
          <!-- 
            このいいねと数、画風はコンポーネント化できそう
            もしかしたら画像も含めてもいいかもしれない
          -->
          <v-card-actions>
              <v-btn icon>
                <!-- いいね数も?  -->
                <v-icon>mdi-heart</v-icon>
              </v-btn>
              画風: xxxxxxx
          </v-card-actions>
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
      posts: [],
      artStyles: [],
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
        alert('タイトルは必須です。');
        return;
      }

      // 送信するデータを組み立てる
      const postData = {
        post: {
          title: this.newPost.title
        }
      };

      try {
        // 組み立てたデータを送信
        await this.$axios.post('/api/v1/posts', postData);

        this.newPost.title = '';
        await this.fetchPosts();
      } catch (error) {
        console.error('投稿に失敗しました:', error);
        alert('投稿に失敗しました。');
      }
    },

    // マイページを開いた時に今まで投稿したデータを取得するメソッドが必要
    async fetchPosts() {
      try {
        const response = await this.$axios.get('/api/v1/posts') // 自分の投稿一覧API これはつまり投稿したものを取り出している
        this.posts = response.data
        console.log(response.data);
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