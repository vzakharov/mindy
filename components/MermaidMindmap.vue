<template lang="pug">
  div.w-100.d-flex.flex-column.justify-content-center.align-items-center
    //- Mindmap container, invisible if the vm is not mounted
    div#mermaid-container.w-100.d-flex.flex-column.justify-content-center.align-items-center(v-show="!rendering")
    //- Spinner taking up all the parent container and making the background semi-transparent if loading
    b-spinner(v-show="rendering")
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
    
    computed:

      mermaidString: ->
        log "Mermaid string computed:",
        'mindmap\n' + @code.replace /[~@\-~"()]/g, (match) -> "##{match.charCodeAt(0)};"

    methods:
    
      render: ->

        @try 'rendering', =>

          mermaid.renderAsync "mermaid-svg", @mermaidString, (svg) ->
            document.getElementById('mermaid-container').innerHTML = svg
    
    watch:
    
      code:
        immediate: true
        handler: (code) ->
          if code
            console.log "Updating mermaid chart"
            @render()
        
</script>