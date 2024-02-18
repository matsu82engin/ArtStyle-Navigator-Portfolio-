<template>
  <div>
    <h1>User Profile</h1>
    <p>User Name: {{ user.name }}</p>
  </div>
</template>

<script>
export default {
  async asyncData({ $axios, params, app }) {
    try {
      const data  = await $axios.$get(`/api/v1/users/${params.id}`, {
      });
      console.log('取得したユーザー情報:', data);
      return { user: data };
    } catch (error) {
      console.error('ユーザーデータの取得中にエラーが発生しました:', error);
      throw error; 
    }
  },
};
</script>
