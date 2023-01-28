# A mixin that creates an `propped` property whose properties are setters that emit an `update:<property>` event for each prop of the component

export default

  created: ->

    @propped = {}
    @update = {}

    Object.keys(@$props).forEach (prop) =>

      # Define property @propped to set the value of the prop and emit an `update:<property>` event
      Object.defineProperty @propped, prop, {
        get: => @[prop]
        set: (value) =>
          @$emit "update:#{prop}", value
          console.debug "Emitted `update:#{prop}` event with value", value
      }
      # console.debug "Created `propped.#{prop}=...` setter"
      
      # Define property @update to Object.assign the value of the prop and emit an `update:<property>` event with the new value
      @update[prop] = (value) =>
        @propped[prop] = Object.assign({}, @propped[prop], value)