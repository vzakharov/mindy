<template lang="pug">
  span {{ dots }}
</template>

<script lang="coffee">

  export default

    data: ->
      count: 2
      interval: null

    computed:

      dots: ->
        '.'.repeat @count + 1

    watch:

      dots:
        handler: -> @$emit 'refresh', @dots
        immediate: true

    mounted: ->
      @interval = setInterval =>
        @count = ( @count + 1 ) % 3
      , 500
    
    beforeDestroy: ->
      clearInterval @interval

</script>