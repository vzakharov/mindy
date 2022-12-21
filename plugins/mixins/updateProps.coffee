# A mixin that creates an `updated` property whose properties are setters that emit an `update:<property>` event for each prop of the component

export default

  created: ->

    @updated = {}

    Object.keys(@$options.propsData).forEach (prop) =>
      Object.defineProperty @updated, prop, {
        get: => throw new Error "The `update` property is write-only; use just `#{prop}` instead"
        set: (value) =>
          @$emit "update:#{prop}", value
          console.debug "Emitted `update:#{prop}` event with value", value
      }
      console.debug "Created `updated.#{prop}=...` setter"