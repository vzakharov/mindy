<template lang="pug">
  //- "Context" is a sort of a canvas/workspace that visualizes the topic according to the conversation so far. It helps the user to understand the topic better while at the same time giving the bot more context to work with. Visually, the context is represented as a mind map or a similar visual aid. Under the hood, the context is plain text, with one non-indented line representing the main topic, and any following tab-indented lines representing sub-topics (think nested bullet points but with tabs instead of asterisks).
  b-col

    b-row#mermaid-container.justify-content-center
    //- Error message if the context is invalid with a suggestion to edit in plain text
    b-alert.text-left.mt-3(
      v-if="!isValid"
      variant="danger"
      show
    )
      strong Cannot render the mind map; please edit the context below:
      ul 
        li Exactly one line with no tabs in the beginning
        li Every next line indented by the same, fewer, or just one more tab than the previous line
    
    //- Button to edit the context in plain text
    b-button.btn-sm.btn-light.m-1(
      @click="editInPlainText = !editInPlainText; mixpanel.track('Switched plain text context editing ' + (editInPlainText ? 'on' : 'off'))"
      :variant="isValid ? editInPlainText ? 'outline-success' : 'light' : 'outline-danger'"
    )
      | 🖉
    //- Button to rebuild the mind map
    b-button.btn-sm.btn-light.m-1(
      @click="$emit('rebuild')"
    )
      | ↺

    b-row(
      v-show="editInPlainText || !isValid"
      :style="isValid ? '' : 'border: 1px solid red; border-radius: 5px; padding: 10px;'"
    )
      EditSettings(
        title="Edit context in plain text"
        :value="{ context }"
        @input="context = $event.context"
        :properties=`{
          context: {
            type: 'multiline',
            monospace: true,
            label: 'Mind map tree',
            placeholder: 'Main topic\\n\\tSub-topic\\n\\t\\tSub-sub-topic\\n\\tAnother sub-topic',
            description: 'Tab/Shift-Tab to indent/unindent lines.'
          }
        }`
      )

</template>

<script lang="coffee">

  import log from '~/plugins/log'
  import mountedMixin from '~/plugins/mixins/mounted'
  import mixpanelMixin from '~/plugins/mixins/mixpanel'

  class MermaidValidationError extends Error

  getIndent = ( line, tabSize = 2) => ( line.length - line.trimLeft().length ) / tabSize

  export default

    mixins: [
      mountedMixin
      mixpanelMixin
    ]

    props: [
      'value'
    ]

    data: ->

      chartRendered: false
      editInPlainText: false
      wasInvalid: false
      contextChanged: false

    computed:

      context:

        get: -> @value

        set: (value) -> @$emit 'input', value

      isValid: ->
        try
          @validate @context
          if @wasInvalid
            @wasInvalid = false
            @mixpanel.track 'Context fixed'
          return true
        catch e
          console.error e
          if not @wasInvalid
            @wasInvalid = true
            @mixpanel.track 'Invalid context'
          return false

      mermaidString: ->

        try @validate(@context) catch e then return ''

        # - Add "mindmap\n" at the beginning
        # - Escape special characters: -, @, ~, ", ( and ). Escaping is done with #[ascii code]; (e.g. #64; for @)
        result = 'mindmap\n' + @context.replace /[~@\-~"()]/g, (match) -> "##{match.charCodeAt(0)};"
        console.log result
        return result
      
      

    mounted: ->

      console.log 'MindyContext mounted'
      # Check if there's a script with id "mermaid-init" and if not, create one
      if document.getElementById 'mermaid-init'
        console.log 'mermaid-init script already exists'
      else
        console.log 'creating mermaid-init script'
        script = document.createElement 'script'
        script.id = 'mermaid-init'
        script.type = 'module'
        window.mermaidLoaded = {
          state: false,
          resolve: null
        }
        window.mermaidLoaded.promise = new Promise ( resolve ) ->
          Object.assign window.mermaidLoaded, { resolve }
        script.innerHTML = """
          let resolve = null
          import mermaid from 'https://unpkg.com/mermaid@9/dist/mermaid.esm.mjs';
          console.log({mermaid})
          import mindmap from 'https://unpkg.com/@mermaid-js/mermaid-mindmap@9/dist/mermaid-mindmap.esm.mjs';
          console.log({mindmap})
          await mermaid.registerExternalDiagrams([mindmap]);
          mermaid.startOnLoad = false;
          Object.assign(window, {mermaid, mindmap});
          console.log('mermaid loaded')
          window.mermaidLoaded.state = true
          window.mermaidLoaded.resolve()
        """
        document.head.appendChild script
        console.log script
    
    watch:
      
      mermaidString:
        immediate: true
        handler: (string) ->
          @chartRendered = false
          console.log 'Creating mermaid chart for', string
          if not @mounted.state
            console.log 'Waiting for the component to be mounted'
            await @mounted.promise
            console.log 'Component mounted'
          if not window.mermaidLoaded.state
            console.log 'Waiting for mermaid to be loaded'
            await window.mermaidLoaded.promise
            console.log 'Mermaid loaded'
          element = document.getElementById 'mermaid-container'
          @$nextTick =>
            console.log 'Updating mermaid chart'
            mermaid.renderAsync "mermaid-#{Date.now()}", string, (svg) =>
              element.innerHTML = svg
              @chartRendered = true
              console.log 'Mermaid chart updated'

      context: ->
        if not @contextChanged
          @contextChanged = true
          @mixpanel.track 'Context changed'


    methods:

      helloWorld: ->
        console.log 'Hello world'

      validate: ( context ) ->
        # Validates the context

        # First of all, test that the context meets the requirements:
        # 1. Exactly one line with no indentation in the beginning
        # 2. The second line must be indented by one level
        # 3. Every next line must be indented by not more than previous line plus one and not less than one level

        if !context
          throw new MermaidValidationError('Context is empty')

        lines = context.split('\n')

        # 1. Exactly one line with no indentation in the beginning
        if getIndent( lines[0] ) != 0
          throw new MermaidValidationError('The first line must not be indented')

        # 2. The second line must be indented by one level
        # Also use this line to get if it's a tab or a space and how many spaces per level (if it's a space)
        if getIndent( lines[1] ) == 0
          throw new MermaidValidationError('The second line must be indented')
        
        tabSize = getIndent( lines[1], 1 )

        # 3. Every next line must be indented by not more than previous line plus one and not less than one level
        for i in [ 2...lines.length ]

          if getIndent( lines[i], tabSize ) > getIndent( lines[i-1], tabSize ) + 1
            throw new MermaidValidationError("Line #{i+1} is indented by more than one level more than the previous line")

          if getIndent( lines[i], tabSize ) < 1
            throw new MermaidValidationError("Line #{i+1} is not indented; only one root topic is allowed")
                
        # console.log { @context }

        return true



</script>


<style scoped>
  .code {
    font-family: monospace;
    background-color: #1e1e1e;
    color: #d4d4d4;
    height: calc(100% - 2.5rem);
  }
</style>