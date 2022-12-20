<template lang="pug">

  TwoPanesAndSidebar(
    brand="Mindy"
    tagline="Brainstorm with AI"
    secondaryPaneCaption="丫"
  )
    template(v-slot:sidebar)
      MindySidebar
    template(v-slot:sidebar-footer)
      MindySidebarFooter
    template(v-slot:primary-pane)
      MindyChatSpace(
        v-model="messages"
      )
    template(v-slot:secondary-pane)
      MindyMindmapSpace

</template>

<script lang="coffee">

  import syncLocal from '~/plugins/mixins/syncLocal'

  export default

    mixins: [
      syncLocal
        keys: [ 'messages' ]
        format: 'yaml'
        prefix: 'mindy'
    ]

    data: ->
      messages: []

</script>