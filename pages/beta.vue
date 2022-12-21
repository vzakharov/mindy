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
      MindyMindmapSpace(
        v-bind.sync="mindmap"
      )
  div.d-flex.flex-column.vh-100.justify-content-center.align-items-center(v-else)
    b-spinner

</template>

<script lang="coffee">

  import syncLocal from '~/plugins/mixins/syncLocal'
  import log from '~/plugins/log'
  import computedData from '~/plugins/mixins/computedData'

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

      computedData
        'chat.title': -> @mindmap.code?.split('\n')[0]?.trim()
        'mindmap.code': -> @chat.routedMessage?.context

    ]

    data: ->

      chat:
        messages: []
        routedMessage: null
        title: null
      mindmap:
        code: null

    watch:

      '$route.query.id':
        immediate: true
        handler: (id) ->
          log "Navigating to message ##{id}"
          if id
            await @syncLocal.promise
            console.log 'syncLocal.promise resolved'
            @chat.routedMessage = @chat.messages.find (message) -> String(message.id) is String(id)
      
      'chat.routedMessage': (message) ->
        
        if message

          { id } = message

          if @$route.query.id isnt id
            @$router.push query: { id }

</script>