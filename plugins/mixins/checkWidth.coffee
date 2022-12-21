# A simple mixin that determines if the screen width is less than a given breakpoint (768px by default)

import _ from 'lodash'

export default ( breakpoint = 768 ) ->

  data: ->
    narrow: false
    wide: true
    width: null

  mounted: ->

    do checkNarrow = =>
      @width = window.innerWidth
      @narrow = @width < breakpoint
      @wide = not @narrow
      console.log "Width changed to #{@width}"
    
    window.addEventListener 'resize', _.debounce checkNarrow, 100