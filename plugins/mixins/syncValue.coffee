# A simple mixin that creates a computed getter/setter synced (via $emit) with the `value` prop

identity = (value) -> value

export default ( key, { deep, save = identity, load = identity } = {} ) ->

  get = ->
    load.call @, @value

  set = (value) ->
    @$emit "input", save.call @, value

  computed:
    not deep and
      [key]: { get, set }

  data: ->
    if deep
      [key]: get.call @
    else
      {}

  watch:

    deep and
      [key]: {
        deep: true
        handler: set
      }