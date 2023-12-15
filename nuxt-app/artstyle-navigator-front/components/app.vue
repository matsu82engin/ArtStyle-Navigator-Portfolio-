<template>
  <div>
    <p>Count is: {{ count }}</p>
    <button @click="increment">+</button>
  </div>
</template>
<script>
export default {
data(){
  return {
    count: 0
  }
},
methods:{
  increment(){
    this.count += 1;
  }
}
}
</script>
