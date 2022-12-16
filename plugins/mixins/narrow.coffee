# A simple mixin that determines if the screen width is less than a given breakpoint (768px by default)
export default ( breakpoint = 768 ) ->

  data: ->
    narrow: false
    wide: true

  mounted: ->

    do checkNarrow = =>
      @narrow = window.innerWidth < breakpoint
      @wide = not @narrow
      console.log { @narrow, @wide }
    
    window.addEventListener 'resize', checkNarrow