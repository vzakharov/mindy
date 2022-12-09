# A simple mix-in to add a "mounted" data property that is set to true when the component is mounted
export default

  data: ->
    mounted: false

  mounted: ->
    @mounted = true