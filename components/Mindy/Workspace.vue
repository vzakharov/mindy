<template lang="pug">
  div.h-100
    //- Header: buttons to edit in plain text, pick colors, settings, ideas, etc.
    div.bg-light.border-bottom.px-3.pt-2.pt-md-4
      div.d-flex.justify-content-end
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
        //- //- Summarize
        //- button.btn.btn-outline-primary.btn-sm.mx-1.px-2(
        //-     @click="$emit('summarize')"
        //-   )
        //-   b-icon-file-earmark-text.mr-2
        //-   | {{ summary.ready ? 'Summarize' : 'View summary' }}
        //- Download
        button.btn.btn-outline-secondary.btn-sm.mx-1.px-2
          b-icon-download.mr-2
          | Download
        //- Help
        button.btn.btn-light.btn-sm.mx-1.lightgray
          b-icon-question-circle
      b-tabs
        b-tab(
            :active="show.mindmap"
            @click="pickedContext = 'mindmap'"
          )
          template(#title)
            b-icon-diagram-3
        b-tab(
            v-if="context && context.content"
            :active="!show.mindmap" 
            @click="pickedContext = 'content'"
          )
          template(#title)
            b-icon(
              :icon="{ text: 'file-earmark-text', code: 'code' }[context.content.type]"
            )
            span.ml-1 {{ context.content.title }}
    //- 

    //- Workspace
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
        template(v-if="show.mindmap")
          //- Mindmap
          MermaidMindmap(
            v-show="show.mindmap"
            :code="mindmapCode"
            v-on="$listeners"
            v-bind="{ show }"
          )
        template(v-else-if="context.content")
          template(v-if="context.content.type==='text' && context.text")
            //- Text (markdown, rendered), edit via prompt on double click
            div.p-4.border.shadow-lg.rounded-lg(
              style="max-width: 600px"
              v-html="$md.render(context.text || '')"
              @dblclick="context.text = window.prompt('Edit text', context.text)"
            )
          template(v-else-if="context.content.type==='code' && context.code")
            //- Code (monospace font)
            pre.p-4(
              style="max-width: 600px; font-family: Consolas, Courier, monospace; white-space: pre-wrap;"
              v-html="context.code"
              @dblclick="context.code = window.prompt('Edit code', context.code)"
            )
          template(v-else-if="context.content")
            //- No text/code
            div.text-muted(style="width: 200px;")
              template(v-if="busy.generatingContent")
                | Generating <strong>{{ context.content.title }}</strong>{{ movingDots }}
              template(v-else)
                | No <strong>{{ context.content.type }}</strong> yet. Click the button below to generate one.
    
</template>

<script lang="coffee">

  import updatePropsMixin from '~/plugins/mixins/updateProps'
  import autoHeightMixin from '~/plugins/mixins/autoHeight'
  import computedDataMixin from '~/plugins/mixins/computedData'
  import movingDotsMixin from '~/plugins/mixins/movingDots'

  export default

    props: [ 'context', 'chat', 'message', 'busy' ]

    mixins: [
      updatePropsMixin
      autoHeightMixin "workspace"
      computedDataMixin
        'show.mindmap': -> @mindmap && ( @pickedContext is 'mindmap' || !@context.content )
      movingDotsMixin
    ]

    data: -> {

      show:
        ideas: false
        mindmap: true
      pickedContext: 'mindmap'
      window

    }
    
    watch:
      context: (context) ->
        # If no content, emit a request to generate one
        if context?.content and not context[ context.content.type ]
          @$emit 'generateContent', @message

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