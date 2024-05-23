<template>
  <div>
    <h2>
      Usersテーブルの取得
    </h2>
    <table v-if="users.length">
      <thead>
        <tr>
          <th>id</th>
          <th>name</th>
          <th>email</th>
          <th>created_at</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(user, i) in users"
          :key="`user-${i}`"
        >
          <td>{{ user.id }}</td>
          <td>{{ user.name }}</td>
          <td>{{ user.email }}</td>
          <td>{{ dateFormat(user.created_at) }}</td>
        </tr>
      </tbody>
    </table>

    <div v-else>
      ユーザーが取得できませんでした
    </div>


    <v-card-title>
        VuetifyカスタムCSSの検証
    </v-card-title>
    <v-card-text>
        ipad（768px）とmobile（426px）で表示・非表示
    </v-card-text>
    
    <v-card-text>
      <v-card
        v-for="(cls, i) in customClass"
        :key="`cls-${i}`"
        :color="cls.color"
        :class="cls.name"
      >
        <v-card-text>
          {{ cls.des }}
        </v-card-text>
      </v-card>
    </v-card-text>
  </div>
</template>

<script>
export default {
  data () {
    return {
      customClass: [
          { name: 'hidden-ipad-and-down', color: 'error', des: 'ipad未満で隠す' },
          { name: 'hidden-ipad-and-up', color: 'info', des: 'ipad以上で隠す' },
          { name: 'hidden-mobile-and-down', color: 'success', des: 'mobile未満で隠す' },
          { name: 'hidden-mobile-and-up', color: 'warning', des: 'mobile以上で隠す' }
        ]
    }
  },
  async asyncData ({ $axios }) {
    let users = []
    await $axios.$get('/api/v1/users')
      .then(res => (users = res))
    return { users }
  },
  computed: {
    dateFormat () {
      return (date) => {
        const dateTimeFormat = new Intl.DateTimeFormat(
          'ja', { dateStyle: 'medium', timeStyle: 'short' }
        )
        return dateTimeFormat.format(new Date(date))
      }
    }
  }
}
</script>