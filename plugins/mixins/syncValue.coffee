# A simple mixin that creates a computed getter/setter synced (via $emit) with the `value` prop

identity = (value) -> value

export default ( key, { deep, save = identity, load = identity } = {} ) ->
  
  data: ->

    # Make sure `value` is a prop
    if not @$options.propsData.value?
      throw new Error "Component #{@$options.name} requires a `value` prop. Make sure to use :value or v-model in the parent component to represent `#{key}`."

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

    }

