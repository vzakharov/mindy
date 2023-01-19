<template lang="pug">
  div.d-flex.flex-column.vh-minus-navbar.justify-content-between
    //- Header: buttons to edit in plain text, pick colors, settings, ideas, etc.
    div.bg-light.border-bottom.px-3.py-2.py-md-4.d-flex.justify-content-end
      //- Ideas
      button.btn.btn-light.btn-sm.mx-1.lightgray
        b-icon-lightbulb(
          @click="show.ideas = !show.ideas"
          :class="show.ideas ? 'text-primary' : ''"
        )
      //- Theme
      button.btn.btn-light.btn-sm.mx-1.lightgray(
        v-b-modal.theme-modal
      )
        b-icon-palette
      b-modal#theme-modal(
        ref="themeModal"
        title="Pick a theme"
        centered
      )
        ThemePicker(
          @input="pickTheme"
        )
        b-icon-palette
      //- Settings
      button.btn.btn-light.btn-sm.mx-1.lightgray
        b-icon-gear
      //- Summarize
      button.btn.btn-outline-primary.btn-sm.mx-1.px-2(
          @click="$emit('summarize')"
        )
        b-icon-file-earmark-text.mr-2
        | {{ summary.ready ? 'Summarize' : 'View summary' }}
      //- Download
      button.btn.btn-outline-secondary.btn-sm.mx-1.px-2
        b-icon-download.mr-2
        | Download
      //- Help
      button.btn.btn-light.btn-sm.mx-1.lightgray
        b-icon-question-circle
    //- 

    //- Mindmap
    div.d-flex.justify-content-center(ref="mindmap")
      MermaidMindmap.overflow-auto(
        :code="mindmapCode"
        v-on="$listeners"
      )

    //- Footer: ideas, if enabled
    div.pt-2.p-2.p-md-4(ref="footer")
      div.border.p-3.d-flex.justify-content-between.align-items-center(
        v-if="show.ideas"
        style="font-size: 1.5em;"
      )
        div
        div
          b-icon-lightbulb.text-primary.mr-2
          | Click on a box to expand it further
        div
          //- Next idea
          button.btn.btn-light.btn-sm.lightgray
            b-icon-arrow-right
    
</template>

<script lang="coffee">

  import updatePropsMixin from '~/plugins/mixins/updateProps'
  import autoHeightMixin from '~/plugins/mixins/autoHeight'

  export default

    props: ['context', 'chat', 'summary' ]

    mixins: [
      updatePropsMixin
      autoHeightMixin "mindmap", footerRef: "footer"
    ]

    data: ->

      show:
        ideas: false
    
    computed:

      mindmap: ->

        # If context has a 'mindmap' key, return it. Otherwise, return the context itself (for backwards compatibility)
        @context?.mindmap ? @context

      mindmapCode: ->

        { mindmap } = @

        # If code is a string, give it
        if typeof mindmap is "string"
          mindmap
        # If it's an array, convert it to a string
        else if Array.isArray mindmap
          # Make sure there's only one root (i.e. only one, the first item, which is not an array)
          if mindmap.slice(1).find (item) -> !Array.isArray item
            # Create a new root and put all the items in it. Use the chat's title as the root string
            mindmap = [ chat.title, mindmap ]

          # Go through each item and increase indent recursively if the line is an array too
          do convert = (lines = mindmap, indent = 0) ->
            lines
              .map (line) ->
                if Array.isArray line
                  convert line, indent + 1
                else
                  "#{'  '.repeat indent}#{line}"
              .join "\n"

    methods:

      pickTheme: (theme) ->
        console.log theme
        # hide the modal
        @$refs.themeModal.hide()


</script>