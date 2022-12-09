<template lang="pug">
  //- "Context" is a sort of a canvas/workspace that visualizes the topic according to the conversation so far. It helps the user to understand the topic better while at the same time giving the bot more context to work with. Visually, the context is represented as a mind map or a similar visual aid. Under the hood, the context is plain text, with one non-indented line representing the main topic, and any following tab-indented lines representing sub-topics (think nested bullet points but with tabs instead of asterisks).
  //- The visual representation is generated using nuxt-mermaid-string, which is a wrapper around mermaid.js, a "markdown-inspired" JavaScript library for generating diagrams from text.
  div
    //- Tabs to switch between visual and plain text representations
    b-tabs
      //- Visual representation
      b-tab(title="Mind map")
        VueMermaidString(
          v-if="isValid"
          :value="mermaidString"
        )
        //- Error message if the context is invalid with a suggestion to edit in plain text
        b-alert(
          v-else
          variant="danger"
          show
        )
          strong Cannot render the mind map; please edit the context in the
            em Plain text
          |  tab.
          p The context must meet the following requirements:
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
          :style="{ borderColor: isValid ? 'transparent' : 'red' }"
        )
        //- Save button
        b-button(
          variant="primary"
          @click="saveContext"
        )
          | Save

</template>

<script lang="coffee">

  class MermaidValidationError extends Error

  getIndent = ( line, tabSize = 2) => ( line.length - line.trimLeft().length ) / tabSize

  export default

    props: [
      'value'
    ]

    computed:

      context:

        get: ->
          # Remove everything after and including \n```
          @value.replace? /\n```[\s\S]*/, ''

        set: (value) ->
          @$emit 'input', value

      isValid: -> try @validate(@context) catch e then false

      mermaidString: ->

        # Generates the mermaid string from the context, i.e.:
        # the word "mindmap"
        #   context, indented by one more level

        try @validate(@context) catch e then throw new MermaidValidationError e.message

        lines = @context.split('\n')

        # Take the tab size & character from the second line
        tabSize = getIndent( lines[1], 1 )
        tabChar = lines[1][0]

        # Indent all lines by one level
        lines = lines.map (line) -> tabChar + line

        # Add the word "mindmap" to the beginning
        lines.unshift 'mindmap'

        # Join the lines with newlines
        lines.join '\n'

    methods:

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