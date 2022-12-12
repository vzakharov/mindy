# A simple mixin that creates a computed getter/setter synced (via $emit) with the `value` prop

identity = (value) -> value

export default ( key, { deep, save = identity, load = identity } = {} ) ->

  get = ->
    load.call @, @value

  set = (value) ->
    @$emit "input", save.call @, value

  computed:
    not deep and
      [key]: {
        get, set
      }

  watch:

    deep and

      [key]:
        deep: true
        handler: set

      value:
        deep: true
        immediate: true
        handler: (value) ->
          @[key] = get.call @