<template lang="pug">

  //- A template for a single input within the EditSettingsModal
  b-form-group(
    v-bind="{ label, description }"
    :label-for="id"
  )
    //- The input
    component(
      :is="inputTag"
      :id="id"
      ref="input"
      v-model="setting"
      v-bind="inputProps"
      @keydown.tab="onTab"
    )
    //- Description (if any)


</template>

<script lang="coffee">

  import syncValueMixin from '~/plugins/mixins/syncValue'

  parseNumber = ( value ) ->
    # If the value is a number (from @inputProps.type = 'number'), convert it to a number
    if @inputProps.type is 'number'
      Number value
    else
      value

  export default

    mixins: [
      syncValueMixin(
        'setting',
        save: parseNumber
        load: parseNumber
        # (I.e. if we get a string while the input type is number, we try to convert it to a number)
      )
    ]

    props:
      value:
        required: true
      properties:
        type: Object
        default: -> {}

    computed:

      id: -> "edit-settings-input-#{@$vnode.key}-#{Math.random().toString(36).slice(2)}"

      label: -> @properties.label || @$vnode.key

      description: ->
        # If description is an object with true/false keys, use the appropriate one depending on the value; otherwise, use the description as is
        { description } = @properties
        if description?[true] and description[false]
          description[@setting]
        else
          description

      inputTagAndProps: ->
        
        mappings =
          multiline: =>
            tag: 'b-textarea'
            props:
              rows: Math.max( 10, Math.min( 20, @value?.split('\n').length ) )
              style: if @properties.monospace
                'font-family: monospace; tab-size: 2; -moz-tab-size: 2;'
              else ''
              placeholder: @properties.placeholder or 'Enter text here'
          text:
            tag: 'b-input'
            props:
              type: 'text'
              placeholder: @properties.placeholder or 'Enter text here'
          number:
            tag: 'b-input'
            props:
              type: 'number'
              placeholder: @properties.placeholder or 'Enter a number here'
          boolean:
            tag: 'b-checkbox'
            props:
              switch: true

        if @properties.type
          mapping = mappings[ @properties.type ]
          mapping?() or mapping
        else
          # If none, guess from the value type
          switch typeof @value
            when 'number'
              mappings.number
            when 'boolean'
              mappings.boolean
            else
              mappings.text
        
      inputTag: -> @inputTagAndProps.tag

      inputProps: -> @inputTagAndProps.props

    methods:

      onTab: ( event ) ->
        # If @properties.monospace, clicking tab/shift-tab has to add/remove a tab to all selected lines instead of shifting focus
        if @properties.monospace
          # Get the selection start and end
          { selectionStart, selectionEnd } = @$refs.input.$el
          # Get text portions
          textBefore = @value.substring 0, selectionStart
          selectedText = @value.substring selectionStart, selectionEnd
          textAfter = @value.substring selectionEnd

          # Add the part of the current line before the selection to the selected text (and remove it from the text before respectively)
          lineStart = textBefore.lastIndexOf('\n') || 0
          selectedText = textBefore.substring(lineStart + 1, selectionStart) + selectedText
          textBefore = textBefore.substring 0, lineStart + 1

          # Add/remove a tab to all selected lines
          selectedText = selectedText.replace /(\n|^)(\t?)/g, if event.shiftKey then '$1' else '$1$2\t'
          # Update the value
          @setting = textBefore + selectedText + textAfter
          event.preventDefault()

          # Restore the selection once the input has been updated
          @$nextTick =>
            @$refs.input.$el.setSelectionRange selectionStart + (if event.shiftKey then -1 else 1), selectionEnd + (if event.shiftKey then -1 else 1)

</script>
