<template lang="pug">
  span {{ '.'.repeat(count + 1) }}
</template>

<script lang="coffee">

  export default

    data: ->
      count: 0
      interval: null

    mounted: ->
      @interval = setInterval =>
        @count = ( @count + 1 ) % 3
      , 500
    
    beforeDestroy: ->
      clearInterval @interval

</script>