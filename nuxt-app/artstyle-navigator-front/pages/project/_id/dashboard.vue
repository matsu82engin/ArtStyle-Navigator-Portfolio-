<template>
  <div>
    <!-- 現在のパスが表示。これを表示することによって今どのページにいるかわかる -->
    {{ $route.fullPath }}
  </div>
</template>

<script>
export default {
}
</script>