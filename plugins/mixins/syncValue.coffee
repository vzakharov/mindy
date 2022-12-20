# A simple mixin that creates a computed getter/setter synced (via $emit) with the `value` prop

identity = (value) -> value

export default ( key, { unfold, deep, save = identity, load = identity } = {} ) ->
  
  data: ->

    # Make sure `value` is a prop
    if not @$options.propsData.value?
      throw new Error "Component #{@$options.name} requires a `value` prop. Make sure to use :value or v-model in the parent component to represent `#{key}`."

    # If `unfold` is set, automatically set `deep` to true (because we'll be watching every key in `value`)
    if unfold
      if not deep? then console.warn "Component #{@$options.name} has `unfold` set to true, but `deep` is not set. Setting `deep` to true."
      deep = true


    [key]: null

    syncValue:
      watchers: []

  watch:

    [key]: {
      deep
      handler: (value) ->
        @$emit 'input', save.call @, value
    }

    value: {
      deep
      immediate: true
      handler: (value) ->
        @[key] = load.call @, value

        # If `unfold` is set, set every corresponding data key to the value of `value` and watch it
        if unfold
          # Delete old watchers, if any
          @syncValue.watchers.forEach (watcher) -> watcher()
          _.forOwn value, (value, subKey) =>
            # Throw an error if there is no data with that key
            if key not of @
              throw new Error "Component #{@$options.name} does not have a data key `#{subKey}`, which is required because `unfold` is set to true."
            console.debug "Setting #{subKey} to", value
            @[subKey] = value
            # Create new watcher
            @syncValue.watchers.push @$watch subKey, (value) ->
              @[key][subKey] = value

    }

