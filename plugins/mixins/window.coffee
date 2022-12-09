# A simple mix-in that defines a @window property that is set to the window object during mounting
export default

  data: ->
    window: null

  mounted: ->
    Object.assign @, { window }