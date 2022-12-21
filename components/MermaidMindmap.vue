<template lang="pug">
  div.w-100.d-flex.flex-column.justify-content-center.align-items-center
    //- Mindmap container, invisible if the vm is not mounted
    div#mermaid-container.w-100.d-flex.flex-column.justify-content-center.align-items-center(
      ref="container"
      v-show="!rendering"
    )
    //- Spinner taking up all the parent container and making the background semi-transparent if loading
    b-spinner(v-show="rendering")
    NodeManipulation(
      v-for="box in boxes"
      :key="box.id"
      v-bind.sync="box"
      @expand="expand(box)"
      @createSibling="createSibling(box)"
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

      rendering: false
      boxes: []
    
    computed:

      mermaidString: ->
        log "Mermaid string computed:",
        'mindmap\n' + @code.replace /[~@\-~"()]/g, (match) -> "##{match.charCodeAt(0)};"
      
      lines: ->
        @code.split '\n'
      
    methods:

      addNode: ( index, levelDelta = 0 ) ->

        # Add a line after the box's index in code, add levelDelta more indentation levels (tabs), and set the text to "[ ]" (so that it's an empty node)
        { lines } = @
        level = (lines[index].match /\t/g)?.length || 0
        lines.splice index + 1, 0, "\t".repeat(level + levelDelta) + "[ ]"
        @code = lines.join '\n'
      
      expand: (box) -> @addNode box.index, 1
      createSibling: (box) -> @addNode box.index, 0

      render: ->

        @try 'rendering', =>

          mermaid.renderAsync "mermaid-svg", @mermaidString, (svg) =>

            { container } = @$refs
            container.innerHTML = svg

            do makeBoxes = =>

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

                # On double click, set the box's editing property to true
                element.ondblclick = => box.editing = true
      # 

    watch:
    
      code:
        immediate: true
        handler: (code) ->
          if code
            console.log "Updating mermaid chart"
            @render()
        
</script>