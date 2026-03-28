<template>
  <v-app>
    <home-app-bar />

    <v-img
      dark
      src="https://picsum.photos/id/20/1920/1080?blur=5"
      gradient="to top right, rgba(19,84,122,.6), rgba(128,208,199,.9)"
      height="300"
    >
      <v-row align="center" justify="center" style="height: 300px;">
        <v-col cols="12" class="text-center">
          <h1 class="display-1 mb-3">絵柄診断アプリについて</h1>
          <p class="subheading">あなたの「描きたい絵柄」を見つけるためのアプリです</p>
        </v-col>
      </v-row>
    </v-img>

    <v-sheet>
      <v-container style="max-width: 860px;">

        <!-- 機能紹介 -->
        <v-row class="my-8">
          <v-col cols="12" class="text-center mb-4">
            <h2 class="display-1">このアプリでできること</h2>
            <p class="grey--text mt-2">3つの主な機能を提供しています</p>
          </v-col>
          <v-col
            v-for="feature in features"
            :key="feature.title"
            cols="12"
            md="4"
          >
            <v-card outlined height="100%">
              <v-card-text class="text-center">
                <v-icon size="40" :color="feature.color" class="mb-3">
                  {{ feature.icon }}
                </v-icon>
                <h3 class="subtitle-1 font-weight-bold mb-2">{{ feature.title }}</h3>
                <p class="body-2 grey--text">{{ feature.description }}</p>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

        <v-divider />

        <v-row class="my-8">
          <v-col cols="12" class="text-center mb-4">
            <h2 class="display-1">使い方</h2>
            <p class="grey--text mt-2">3ステップで始められます</p>
          </v-col>
          <v-col cols="12">
            <v-timeline dense>
              <v-timeline-item
                v-for="(step, i) in steps"
                :key="i"
                color="primary"
                small
              >
                <v-card outlined>
                  <v-card-title class="subtitle-1 font-weight-bold">
                    {{ step.title }}
                  </v-card-title>
                  <v-card-text class="grey--text">
                    {{ step.description }}
                  </v-card-text>
                </v-card>
              </v-timeline-item>
            </v-timeline>
          </v-col>
        </v-row>

        <v-divider />

        <v-row class="my-8" justify="center">
          <v-col cols="12" class="text-center">
            <h2 class="display-1 mb-3">さっそく診断してみよう！</h2>
            <p class="grey--text mb-6">あなたの好きな・描きたい絵柄を見つけにいこう！</p>
            <diagnosis-start-button x-large />
          </v-col>
        </v-row>

      </v-container>
    </v-sheet>

    <app-footer />
  </v-app>
</template>

<script>
export default {
  name: 'AboutPage',
  middleware: ['logged-in-redirect'],
  data() {
    return {
      features: [
        {
          title: '絵柄診断',
          description: '複数の質問に答えるだけで、あなたに合った絵柄を診断します。',
          icon: 'mdi-palette',
          color: 'teal'
        },
        {
          title: '作品投稿',
          description: '自分の作品を投稿して、絵柄タグを付けてシェアできます。',
          icon: 'mdi-image-plus',
          color: 'blue'
        },
        {
          title: 'フォロー',
          description: '気になるユーザーをフォローして、作品をチェックできます。',
          icon: 'mdi-account-multiple',
          color: 'deep-purple'
        },
      ],
      steps: [
        {
          title: 'アカウントを作成する',
          description: 'メールアドレスとパスワードで簡単に登録できます。'
        },
        {
          title: '絵柄診断をする',
          description: '診断ページでいくつかの質問に答えると、あなたの絵柄タイプが分かります。'
        },
        {
          title: '作品を投稿・探索する',
          description: '自分の作品を投稿したり、他のユーザーの作品を見て参考にしよう。'
        },
      ]
    }
  }
}
</script>
