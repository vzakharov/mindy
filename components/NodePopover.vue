<template lang="pug">
  div.position-fixed(
      :style="clonedStyle"
    )
    b-popover(
      :target="`box-${box.id}`"
      triggers="hover"
      placement="bottom"
    )
      //- Buttons to expand, edit, etc.
      div.d-flex.justify-content-between
        //- Edit
        button.btn.btn-light.btn-sm(
          @click="enableEditing"
        )
          b-icon-pencil
        //- Expand
        button.btn.btn-light.btn-sm
          b-icon-plus
        //- Create sibling
        button.btn.btn-light.btn-sm
          b-icon-diagram-2
        //- Delete
        button.btn.btn-light.btn-sm
          b-icon-trash
        //- Auto-expand
        button.btn.btn-outline-primary.btn-sm
          Icon(icon="magic")
    //- 

    //- Input to edit the box
    b-textarea.p-1.text-center(
      ref="editBox"
      v-if="editing"
      v-model="text"
      @blur="disableEditing"
      style="height: 100%; width: 100%; font-size: 1.2em; font-family: inherit;"
    )
</template>

<script lang="coffee">
  
  import _ from 'lodash'
  import log from '~/plugins/log'

  export default

    props: ['box']

    data: ->

      editing: false
      clonedStyle: {}
      text: @box.text

    methods:

      enableEditing: ->
        # Place the edit box in the same position as the box's element
        { top, left, width, height } = @box.element.getBoundingClientRect()
        # Get font family from the box's element
        { fontFamily } = window.getComputedStyle(@box.element)
        @clonedStyle = {
          top: "#{top}px"
          left: "#{left}px"
          width: "#{width}px"
          height: "#{height}px"
          fontFamily
        }
        # Temporarily hide the box's element
        @box.element.style.visibility = 'hidden'
        @editing = true
        # Focus the edit box on the next tick
        @$nextTick -> @$refs.editBox.focus()
      
      disableEditing: ->
        @box.element.style.visibility = 'visible'
        @clonedStyle = {}
        @editing = false
        @$emit 'update:text', @text

</script>