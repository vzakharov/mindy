<template lang="pug">
  div.w-100.d-flex.flex-column.justify-content-center.align-items-center
    //- Mindmap container, invisible if the vm is not mounted
    div#mermaid-container.w-100.d-flex.flex-column.justify-content-center.align-items-center(
      ref="container"
      v-show="!rendering"
    )
    //- Spinner taking up all the parent container and making the background semi-transparent if loading
    b-spinner(v-show="rendering")
    NodePopover(
      v-for="box, index in boxes"
      :key="box.id"
      v-bind="{ box }"
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
      
    methods:

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
                @boxes.push {
                  element
                  id
                  text
                  index: index++
                }

                # Assign the id to the element
                element.id = "box-#{id}"

    watch:
    
      code:
        immediate: true
        handler: (code) ->
          if code
            console.log "Updating mermaid chart"
            @render()
        
</script>