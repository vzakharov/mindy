# A simple mixin that creates a computed getter/setter synced (via $emit) with the `value` prop

identity = (value) -> value

export default ( key, { deep, save = identity, load = identity } = {} ) ->
  
  # debugger

  data: ->
    [key]: null

  watch:

    [key]: {
      deep
      handler: (value) -> @$emit 'input', save.call @, value
    }

    value: {
      deep
      immediate: true
      handler: (value) ->
        @[key] = load.call @, value
    }