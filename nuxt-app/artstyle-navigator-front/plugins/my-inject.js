class MyInject {
  constructor (ctx) {
    this.app = ctx.app
  }
}

export default ({ app }, inject) => {
  inject('my', new MyInject({ app }))
}
