<template>
  <v-app>
    <home-app-bar
      :img-height="imgHeight"
    />
    <v-img
      dark
      src="https://picsum.photos/id/20/1920/1080?blur=5"
      gradient="to top right, rgba(19,84,122,.6), rgba(128,208,199,.9)"
      :height="imgHeight"
    >
      <v-row
        align="center"
        justify="center"
        :style="{ height: `${imgHeight}px` }"
      >
        <v-col
          cols="12"
          class="text-center"
        >
          <h1 class="display-1 mb-4">
            自分の描きたい絵柄を探しにいこう。
          </h1>
          <h4
            class="subheading"
            :style="{ letterSpacing: '5px' }"
          >
            貴方の絵柄探しツール
          </h4>
        </v-col>
      </v-row>
    </v-img>

    <v-sheet id="diagnosis">
      <v-container
        fluid
        :style="{ maxWidth: '1280px' }"
      >
        <v-row justify="center" class="my-8">
          <v-col cols="12" class="text-center">
            <h2 class="display-1 mb-6">さぁ、自分のなりたい絵柄を探しにいこう！</h2>
            <diagnosis-start-button x-large />
          </v-col>
        </v-row>
      </v-container>
    </v-sheet>

    <v-sheet id="about">
      <v-container
        fluid
        :style="{ maxWidth: '1280px' }"
      >
        <v-row justify="center" class="my-8">
          <v-col cols="12" class="text-center">
            <h2 class="display-1 mb-4">このアプリについて</h2>
            <p class="subtitle-1 mb-6">このサイトは貴方の描きたい絵柄を見つけるアプリケーションです</p>
            <v-btn
              color="primary"
              outlined
              large
              to="/about"
            >
              詳しく見る
            </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-sheet>

    <app-footer /> <!-- footer コンポーネント -->
  </v-app>
</template>

<script>
export default {
  middleware: ['logged-in-redirect'],
  data () {
    return {
      imgHeight: 500,
    }
  }
}
</script>
