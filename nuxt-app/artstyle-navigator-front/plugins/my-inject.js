class MyInject {
  constructor (ctx) {
    this.app = ctx.app
  }

  // 日付のフォーマット変換
  dateFormat(dateStr) {
    const dateTimeFormat = new Intl.DateTimeFormat(
      'ja', { dateStyle: 'medium', timeStyle: 'short' }
    )
    return dateTimeFormat.format(new Date(dateStr))
  }

  // プロジェクトリンク
  projectLinkTo (id, name = 'project-id-dashboard') {
    return { name, params: { id } }
  }
}

export default ({ app }, inject) => {
  inject('my', new MyInject({ app }))
}
