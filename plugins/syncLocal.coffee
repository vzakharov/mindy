export default ({ computeSettings, keys, container } = {}) ->

  mounted: ->

    # If container is undefined, use either this.settings or (if none) just this
    if container is undefined
      container = @settings or @
    
    # If container is other than `this`, get the container key as string by going through all keys in `this` and comparing the value with the container object
    if container isnt @
      containerKey = Object.keys(@).find key => @[key] is container
      unless containerKey
        throw new Error "Could not find container key in this"

    ( keys or Object.keys(container) ).forEach ( key ) =>

      localValue = localStorage.getItem(key)
      defaultValue = container[key]

      console.log key: key, localValue: localValue, defaultValue: defaultValue

      isObject = typeof defaultValue is 'object'
      isArray = Array.isArray defaultValue
      if isObject
        localValue = JSON.parse(localValue or null)

      container[key] = if isObject and not isArray
        {...defaultValue, ...localValue}
      else
        localValue or defaultValue

      keyToWatch = if containerKey then "#{containerKey}.#{key}" else key
      @$watch keyToWatch,
        deep: true
        handler: (value) ->
          localStorage.setItem(key, if isObject then JSON.stringify(value) else value)

      # If computeSettings is set, then define a this get/set for the key
      if computeSettings
        # Define a getter/setter for the key
        Object.defineProperty this, key,
          get: -> container[key]
          set: (value) -> container[key] = value