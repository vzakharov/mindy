<template lang="pug">
  div.h-100
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
    div.d-flex.flex-column.justify-content-center.align-items-center#workspace(
        ref="workspace"
        style="overflow: auto; height: 100%;"
      )
      div(v-if="!context")
        h2.display-6 This is your workspace
        ul.lead
          li Start by asking questions in the chat.
          li Mindy will automatically fill the workspace for you.
          li Unsure what to ask? 
            span.text-primary(@click="$emit('randomQuery')" style="cursor: pointer;") Click here
            | .
      template(v-else)
        template(v-if="pickedContext==='mindmap'")
          //- Mindmap
          MermaidMindmap.overflow-auto(
            v-show="show.mindmap"
            :code="mindmapCode"
            v-on="$listeners"
            v-bind="{ show }"
          )
        template(v-else-if="pickedContext==='text' && context.text")
          //- Text (markdown, rendered)
          div.overflow-auto.p-4.border.shadow-lg.rounded-lg(
            style="max-width: 600px"
            v-html="$md.render(context.text || '')"
          )
        template(v-else-if="pickedContext==='code' && context.code")
          //- Code (monospace font)
          div.overflow-auto.p-4.border.shadow-lg.rounded-lg.bg-dark.text-light(
            style="max-width: 600px; font-family: Consolas, Courier, monospace; white-space: pre-wrap;"
            v-html="context.code"
          )
    
    //- Footer(
    div#footer.bg-light.border-top.px-3.py-2.py-md-4.d-flex.justify-content-end(
        v-show="context"
        ref="footer"
      )
      //- Context switch: mindmap/text/code
      button.btn.btn-sm.rounded-pill.mx-2(
        v-for="type in ['mindmap', 'text', 'code']"
        :class="type === pickedContext ? 'btn-primary' : 'btn-light'"
        @click="pickedContext = type"
      )
        b-icon(
          :icon="{ mindmap: 'diagram-3', text: 'file-earmark-text', code: 'code' }[type]"
        )
    
</template>

<script lang="coffee">

  import updatePropsMixin from '~/plugins/mixins/updateProps'
  import autoHeightMixin from '~/plugins/mixins/autoHeight'
  import computedDataMixin from '~/plugins/mixins/computedData'

  export default

    props: ['context', 'chat', 'summary' ]

    mixins: [
      updatePropsMixin
      autoHeightMixin "workspace"
      computedDataMixin
        'show.mindmap': -> @mindmap && @pickedContext is 'mindmap'
    ]

    data: ->

      show:
        ideas: false
        mindmap: true
      pickedContext: 'mindmap'
    
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