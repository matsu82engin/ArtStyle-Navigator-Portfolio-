<template>
  <div>
    <!-- ログイン前のボタン -->
      <v-btn
        v-for="nav_menu in nav_menus"
        :key="nav_menu.id"
        :to="nav_menu.path"
        class="elevation-0"
        :style="{ color: '#0800FF' }" 
        outlined
        >
        {{ nav_menu.menu }}
      </v-btn>
  </div>
</template>

<script>
  export default {
    data(){
      return {
        nav_menus: [
          { id: 1, menu: 'Sign up', path: '/signup' },
          { id: 2, menu: 'Login', path: '/login' },
        ],
      };
    },
    methods: {
      menu_close(){
        this.nav_lists.forEach(function(navList) {
          navList.active = false;
        });
      },
    }
  }
</script>
