export default async ({ store, $axios }) => {
  // プロジェクト一覧が存在しない場合
  if (!store.state.project.list.length) {
    await $axios.$get('/api/v1/pictures')
      .then(projects => store.dispatch('getProjectList', projects))
  }
}