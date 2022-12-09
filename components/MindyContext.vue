<template lang="pug">
  //- "Context" is a sort of a canvas/workspace that visualizes the topic according to the conversation so far. It helps the user to understand the topic better while at the same time giving the bot more context to work with. Visually, the context is represented as a mind map or a similar visual aid. Under the hood, the context is plain text, with one non-indented line representing the main topic, and any following tab-indented lines representing sub-topics (think nested bullet points but with tabs instead of asterisks).
  div
    //- Tabs to switch between visual and plain text representations
    b-tabs(nav-wrapper-class="sticky-top bg-white")
      //- Visual representation
      b-tab(title="Mind map")

        //- //- Centered spinner if the chart is not rendered yet
        //- b-spinner(v-if="!chartRendered" small style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);")
        b-container
          b-row.sticky-top(
            align-v="center"
            style="height: calc(100vh - 200px);"
          )
            b-col

              pre.mermaid#mermaid-container(
                v-if="isValid"
                v-text="mermaidString"
              )
              //- Error message if the context is invalid with a suggestion to edit in plain text
              b-alert(
                v-else
                variant="danger"
                show
              )
                strong Cannot render the mind map; please edit the context in the <em>Plain text</em> tab.
                ul 
                  li Exactly one line with no indentation in the beginning
                  li The second line must be indented by one level
                  li Every next line must be indented by not more than previous line plus one and not less than one level

      //- Plain text representation
      b-tab(title="Plain text")
        //- The text area (monospace dark theme, full-height)
        //- Red border if the context is invalid
        b-textarea(
          v-model="context"
          rows="25"
          :style=`{
            borderColor: isValid ? 'transparent' : 'red',
            fontFamily: 'monospace'
          }`
        )
        //- Save button
        //- b-button(
        //-   variant="primary"
        //-   @click="saveContext"
        //- )
        //-   | Save

</template>

<script lang="coffee">

  import log from '~/plugins/log'
  import mountedMixin from '~/plugins/mixins/mounted'

  class MermaidValidationError extends Error

  getIndent = ( line, tabSize = 2) => ( line.length - line.trimLeft().length ) / tabSize

  export default

    mixins: [
      mountedMixin
    ]

    props: [
      'value'
    ]

    data: ->

      chartRendered: false

    computed:

      context:

        get: ->
          # Remove everything after and including \n```
          @value.replace? /\n```[\s\S]*/, ''

        set: (value) ->
          @$emit 'input', value

      isValid: ->
        try
          @validate @context
          return true
        catch e
          console.error e
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
            element?.removeAttribute 'data-processed'
            mermaid.init()
            @chartRendered = true

    methods:

      helloWorld: ->
        console.log 'Hello world'

      validate: ( context ) ->
        # Validates the context

        # First of all, test that the context meets the requirements:
        # 1. Exactly one line with no indentation in the beginning
        # 2. The second line must be indented by one level
        # 3. Every next line must be indented by not more than previous line plus one and not less than one level

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