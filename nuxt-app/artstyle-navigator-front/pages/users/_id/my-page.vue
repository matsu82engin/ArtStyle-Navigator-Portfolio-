<template>
  <v-container>
    <v-row>
      <!-- ユーザー情報セクション => コンポーネント化できそう -->
      <v-col cols="12" md="4">
        <v-card>
          <v-card-text class="text-center">
            <!-- ユーザーアイコン -->
            <v-avatar size="128" class="mb-4">
              <img src="https://placekitten.com/128/128" alt="User Avatar" />
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
          </v-card-text>

          <v-card-actions class="justify-end">
              <v-btn color="primary">
                投稿する
              </v-btn>
          </v-card-actions>
        </v-card>
        <!-- ここまでPostForm -->

        <!-- 
          ここもコンポーネント化できる。
          ただし、v-for は除いてコンポーネント化して、
          このページで v-for を使う。
        -->
        <v-card 
          v-for="post in 3"
          :key="post"
          class="mt-4"
        >
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
          <v-card-text>
            投稿内容のテキストが表示されます。
          </v-card-text>
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
      
    }
  },
  computed: {

  },
  methods: {
  },
}


</script>