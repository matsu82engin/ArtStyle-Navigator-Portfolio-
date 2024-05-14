<template>
  <v-app>
    <v-sheet>
      <v-container
        fluid
        :style="{ maxWidth: '1280px' }"
      >
        <v-row
          v-for="(menu, i) in menus"
          :key="`menu-${i}`"
        >
          <v-col 
            cols="12"
          >
            <div
              :is="`home-${menu.title}`" 
            />
          </v-col>
        </v-row>
      </v-container>
    </v-sheet>
    <app-footer />
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
      menus: [
        { title: 'about'},
        { title: 'another-art-style'},
        { title: 'find-my-art-style-button'},
        { title: 'many-art-style'}
      ]
    }
  }
}
</script>
