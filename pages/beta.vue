<template lang="pug">

  TwoPanesAndSidebar(
      v-if="syncLocal.loaded"
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
        v-bind.sync="chat"
      )
    template(v-slot:secondary-pane)
      MindyMindmapSpace

</template>

<script lang="coffee">

  import syncLocal from '~/plugins/mixins/syncLocal'
  import log from '~/plugins/log'

  export default

    head: ->

      { bookmark, content} = @routedMessage || {}

      title: if @routedMessage then "#{ if bookmark?.name then "#{bookmark.name} (bookmark)" else content } · Mindy" else 'Mindy · Brainstorm with AI'

    meta: [
      name: 'viewport'
      content: 'width=device-width, initial-scale=1, user-scalable=no'
    ]

    mixins: [
      syncLocal
        keys: [
          [ 'messages', dataPath: 'chat' ]
        ]
        format: 'yaml'
        prefix: 'mindy'
    ]

    data: ->
      chat:
        messages: []
        routedMessageId: 3
        title: 'Mindy tutorial'
    
    # watch:

    #   '$route.query.id':
    #     immediate: true
    #     handler: (id) ->
    #       log "Navigating to message ##{id}"
    #       if id
    #         await @syncLocal.promise
    #         @chat.routedMessageId = id

</script>