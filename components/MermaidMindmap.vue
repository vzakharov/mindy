<template lang="pug">
  div.w-100.d-flex.flex-column.justify-content-center.align-items-center
    //- Mindmap container, invisible if the vm is not mounted or if there's no code
    div#mermaid-container.w-100.d-flex.flex-column.justify-content-center.align-items-center(
      ref="container"
      v-show="!busy.rendering && code"
      v-html="svg"
    )
    //- Spinner taking up all the parent container and making the background semi-transparent if loading
    b-spinner(v-show="busy.rendering")
    div(v-show="!code")
      h2.display-6 This is your workspace
      ul.lead
        li Start by asking questions in the chat
        li Mindy will automatically create a mindmap for you
        li Unsure what to ask? 
          span.text-primary(@click="$emit('randomQuery')" style="cursor: pointer;") Click here
          | .
    NodeManipulation(
      v-for="box, index in boxes"
      :key="box.id"
      v-bind.sync="box"
      @expand="expand(index)"
      @createSibling="createSibling(index)"
      @remove="remove(index)"
      @commit="updateText(index, $event)"
    )
        
</template>

<script lang="coffee">

  import log from '~/plugins/log'

  import mermaid from 'mermaid'
  import mindmap from '@mermaid-js/mermaid-mindmap'

  log "Imported:", { mermaid, mindmap}

  mermaid.initialize { startOnLoad: false }
  mermaid.registerExternalDiagrams [ mindmap ]

  import tryActionMixin from '~/plugins/mixins/tryAction'

  export default

    props: ['code']

    mixins: [ tryActionMixin ]

    data: ->

      busy:
        rendering: false
      boxes: []
      svg: ''
    
    computed:

      mermaidString: ->
        # log "Mermaid string computed:",
        if @code
          'mindmap\n' + @code.replace /[~@\-~"(){}]/g, (match) -> "##{match.charCodeAt(0)};"
        else
          """
          mindmap
          This is your workspace
            Start by asking questions in the chat
            Mindy will automatically create a mindmap for you
            Unsure what to ask? Click here
          """
      
      actionBoxes: ->
        # log "Special boxes computed:",
        if !@code
          4: => @$emit 'randomQuery'
          # (This is the one that says "Click here"; the indexing starts at 1)
      
      lines:
        get: -> @code.split '\n'
        set: (lines) -> @code = lines.join '\n'
      
    methods:

      getLevel: (index) -> (@lines[index].match /\t/g)?.length || 0
      
      indent: (text, level) -> "\t".repeat(level) + text

      expand: (index) ->

        # Add a line after the index in code, add levelDelta more indentation levels (tabs)
        lines = @lines
        lines.splice index + 1, 0, @indent("[ ]", @getLevel(index) + 1)
        @lines = lines

      createSibling: (index) ->

        # Add a line after the box's index in code, add levelDelta less indentation levels (tabs)
        lines = @lines
        # Find a line with the same indentation level as the one at index
        for siblingIndex in [index + 1...lines.length]
          if @getLevel(siblingIndex) <= @getLevel(index)
            break
        lines.splice siblingIndex, 0, @indent("[ ]", @getLevel(index))
        log "Lines after creating sibling:",
        @lines = lines

      remove: (index) ->

        # Show a confirmation dialog
        if !window.confirm "Are you sure you want to delete this box and all its descendants? THERE IS NO UNDO!"
          return
          
        # Remove the line at the box's index in code, as well as all further lines with higher indentation levels
        lines = @lines
        for lastDescendantIndex in [index + 1...lines.length]
          if @getLevel(lastDescendantIndex) <= @getLevel(index)
            break
        lines.splice index, lastDescendantIndex - index
        @lines = lines
      
      updateText: (index, [ text, method ]) ->

        { lines } = @
        lines[index] = @indent text, @getLevel(index)
        @lines = lines
        @[method]?(index)


      render: ->

        @try 'rendering', =>

          if @code
            mermaid.renderAsync "mermaid-svg", @mermaidString, (svg) => @svg = svg
      # 

    watch:

      svg: ->

        container = document.getElementById 'mermaid-container'

        @boxes = []
        index = 0

        # Go through every .mindmap-node element within the SVG and create boxes for them
        container.querySelectorAll('.mindmap-node').forEach (element) =>

          # Get the element's bounding box
          box = element.getBoundingClientRect()

          # Come up with a random ID for the box
          id = Math.random().toString(36).substr(2, 9)

          # Take all tspan's within and join them with a space
          text = Array.from(element.querySelectorAll('tspan')).map((element) -> element.textContent.replace /\s{2,}/g, ' ').join ' '

          # Create a virtual box with the same dimensions and position
          box = {
            element
            id
            text
            editing: !text
            index: index++
          }
          # (We set the editing property to true if the text is empty so that the user can start typing right away. It also helps when we're creating a new box, as this will make it editable right away.)

          @boxes.push box

          # Assign the id to the element
          element.id = "box-#{id}"
          element.style.cursor = 'pointer'

          if @actionBoxes?[index]
            element.onclick = @actionBoxes[index]
          else
            # # On double click, set the box's editing property to true
            # element.ondblclick = => box.editing = true
            # On click, emit a "request to elaborate"
            element.onclick = => @$emit 'elaborate', box.text
    
      code:
        immediate: true
        handler: (code) ->
          if code
            console.log "Updating mermaid chart"
            @render()
          else
            console.log "Clearing mermaid chart"
            @svg = ''

</script>