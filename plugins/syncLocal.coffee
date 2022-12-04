export default ({ computeSettings, keys, container } = {}) ->

  mounted: ->

    # If container is undefined, use either this.settings or (if none) just this
    if container is undefined
      container = @settings ? @

    for key in keys or Object.keys container

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

      @$watch("settings.#{key}", deep: true, handler: (value) ->
        localStorage.setItem(key, if isObject then JSON.stringify(value) else value)

      # If computeSettings is set, then define a this get/set for the key
      if computeSettings
        debugger
        # Define a getter/setter for the key
        Object.defineProperty this, key,
          get: -> container[key]
          set: (value) -> container[key] = value
          
      )