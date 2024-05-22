<template>
  <v-app>
    <home-app-bar
      :menus="menus"
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

    <v-sheet>
      <v-container
        fluid 
        :style="{ maxWidth: '1280px' }"
        :menus="menus"
      >
        <v-row 
          v-for="(menu, i) in menus" 
          :key="`menu-${i}`"
        >
          <v-col
            :id="menu.title" 
            cols="12"
          >
            <v-card flat>
              <v-card-title class="justify-center display-1">
                {{ (`${menu.content}`) }}
              </v-card-title>
              <v-card-text class="text-center">
                {{ menu.subtitle }}
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12">
             <div :is="`home-${menu.title}`" />  <!-- ここがコンポーネント -->
          </v-col>
        </v-row>
      </v-container>
    </v-sheet>
    <app-footer /> <!-- footer コンポーネント -->
  </v-app>
</template>

<script>
import HomeAbout from '~/components/Home/HomeAbout'
import HomeAnotherArtStyle from '~/components/Home/HomeAnotherArtStyle'
import HomeFindMyArtStyleButton from '~/components/Home/HomeFindMyArtStyleButton'
import HomeManyArtStyle from '~/components/Home/HomeManyArtStyle'

export default {
  components: {
    HomeAbout,
    HomeAnotherArtStyle,
    HomeFindMyArtStyleButton,
    HomeManyArtStyle,
  },
  data () {
    return {
      imgHeight: 500,
      menus: [
        {
          title: 'about', 
          value: 'About',
          content: 'このアプリについて',
          subtitle: 'このサイトは貴方の描きたい絵柄を見つけるアプリケーションです'
        },
        {
          title: 'another-art-style',
          value: 'SomeStyle',
          content: 'いろいろな絵柄',
          subtitle: '貴方の好きな絵柄は？'
        },
        {
          title: 'find-my-art-style-button',
          value: 'YourStyle',
          content: 'さぁ、自分のなりたい絵柄を探しにいこう！',
          subtitle: 'Push Button!!'
        },
        {
          title: 'many-art-style',
          value: 'Tips',
          content: 'みんなの絵柄',
          subtitle: '他の人の絵柄の書き方・コツを紹介'
        }
      ],
    }
  }
}
</script>
