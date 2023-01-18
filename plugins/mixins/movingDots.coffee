# A mixin that adds a "movingDots" data property that changes every 500ms
export default

  data: ->
    movingDots: '...'
    movingDotsInterval: null

  created: ->
    @movingDotsInterval = setInterval @updateMovingDots, 500

  beforeDestroy: ->
    clearInterval @movingDotsInterval

  methods:
    updateMovingDots: ->
      @movingDots = if @movingDots.length < 3 then @movingDots + '.' else '.'
