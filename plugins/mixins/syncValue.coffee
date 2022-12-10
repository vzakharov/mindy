# A simple mixin that creates a computed getter/setter synced (via $emit) with the `value` prop

export default ( key, { deep } = {} ) ->

  data: ->

    [key]: @value

  watch:

    [key]: {
      deep
      handler: (value) -> @.$emit "input", value
    }