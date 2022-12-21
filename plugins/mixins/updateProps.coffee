# A mixin that creates an `updated` property whose properties are setters that emit an `update:<property>` event for each prop of the component

export default

  created: ->

    @updated = {}
    @update = {}

    Object.keys(@$options.propsData).forEach (prop) =>

      # Define property @updated to set the value of the prop and emit an `update:<property>` event
      Object.defineProperty @updated, prop, {
        get: => @[prop]
        set: (value) =>
          @$emit "update:#{prop}", value
          console.debug "Emitted `update:#{prop}` event with value", value
      }
      console.debug "Created `updated.#{prop}=...` setter"
      
      # Define property @update to Object.assign the value of the prop and emit an `update:<property>` event with the new value
      @update[prop] = (value) =>
        @updated[prop] = Object.assign({}, @updated[prop], value)