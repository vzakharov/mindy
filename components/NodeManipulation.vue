<template lang="pug">
  div.position-fixed(
      :style="clonedStyle"
    )
    b-popover(
      :target="`box-${id}`"
      triggers="hover"
      placement="bottom"
    )
      //- Buttons to expand, edit, etc.
      div.d-flex.justify-content-between
        //- Edit
        button.btn.btn-light.btn-sm(
          @click="propped.editing = true"
        )
          b-icon-pencil
        //- Expand
        button.btn.btn-light.btn-sm(
          @click="$emit('expand')"
        )
          b-icon-plus
        //- Create sibling
        button.btn.btn-light.btn-sm(
          @click="$emit('createSibling')"
        )
          b-icon-diagram-2
        //- Delete
        button.btn.btn-light.btn-sm(
          @click="$emit('remove')"
        )
          b-icon-trash
        //- Auto-expand
        button.btn.btn-outline-primary.btn-sm
          Icon(icon="magic")
    //- 

    //- Input to edit the box
    //- Enter commits, tab commits then emits 'expand', shift+enter commits then emits 'createSibling'
    b-textarea.p-1.text-center(
      ref="editBox"
      v-if="editing"
      v-model="editedText"
      @blur="commitAnd"
      @keydown.enter.exact="commitAnd"
      @keydown.tab.prevent="commitAnd('expand')"
      @keydown.shift.enter="commitAnd('createSibling')"
      :style="'height: 100%; width: 100%; font-size: 1.2em; font-family: inherit;' + ( text ? '' : 'min-width: 100px;' )"
    )
</template>

<script lang="coffee">
  
  import _ from 'lodash'
  import log from '~/plugins/log'
  import updatePropsMixin from '~/plugins/mixins/updateProps'

  export default

    props: ['id', 'element', 'text', 'editing']

    mixins: [
      updatePropsMixin
    ]

    data: ->

      clonedStyle: {}
      editedText: @text

    methods:

      commitAnd: (method) ->
        # Remove any newlines from the text, as well as multiple spaces, and trim
        @editedText = @editedText.replace(/\n/g, '').replace(/ {2,}/g, ' ').trim()
        # If there's no text, set text to 'tba'
        if not @editedText
          @editedText = 'tba'

        @$emit('commit', [ @editedText, method ])

        @propped.editing = false

    watch:
      editing:
        immediate: true
        handler: (editing) ->
          if editing
            # Place the edit box in the same position as the box's element
            { top, left, width, height } = @element.getBoundingClientRect()
            # Get font family from the box's element
            { fontFamily } = window.getComputedStyle(@element)
            @clonedStyle = {
              top: "#{top}px"
              left: "#{left}px"
              width: "#{width}px"
              height: "#{height}px"
              fontFamily
            }
            # Temporarily hide the box's element
            @element.style.visibility = 'hidden'
            # Focus the edit box on the next tick
            @$nextTick -> @$refs.editBox.focus()
          else
            @element.style.visibility = 'visible'
            @clonedStyle = {}

</script>