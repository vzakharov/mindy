# A simple mix-in to add a "mounted" data property that is set to true when the component is mounted, as well as a @window property that is set to the window object
export default

  data: ->

    mounted = {
      state: false
    }

    Object.assign mounted,
      promise: new Promise ( resolve ) -> Object.assign mounted, { resolve }

    {
      mounted
    }

  mounted: ->

    @mounted.resolve()
    @mounted.state = true