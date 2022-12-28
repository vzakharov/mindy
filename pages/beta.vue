<template lang="pug">

  TwoPanesAndSidebar(
      v-if="syncLocal.loaded"
      brand="Mindy"
      tagline="Brainstorm with AI"
      secondaryPaneIcon="layout-sidebar"
    )
    template(v-slot:sidebar)
      MindySidebar(
        v-bind="{ chats }"
      )
    template(v-slot:sidebar-footer)
      MindySidebarFooter
    template(v-slot:primary-pane)
      MindyChat(
        v-bind.sync="chat"
      )
    template(v-slot:secondary-pane)
      MindyWorkspace(
        v-bind.sync="mindmap"
      )
  div.d-flex.flex-column.vh-100.justify-content-center.align-items-center(v-else)
    b-spinner

</template>

<script lang="coffee">

  import syncLocal from '~/plugins/mixins/syncLocal'
  import log from '~/plugins/log'
  import computedData from '~/plugins/mixins/computedData'
  import TreeLike from '~/plugins/treeLike'

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
        'chat.tree' : -> new TreeLike(@chat.messages, vm: @)
        'mindmap.code': -> @chat.tree.thread?(@chat.routedMessage)?.find((message) -> message.context)?.context

    ]

    data: ->

      chat:
        messages: []
        tree: {}
        routedMessage: null
        title: null
      mindmap:
        code: null
    
    computed:

      chats: -> @chat.tree.children(@chat.tree.root)
          
    watch:

      '$route.query.id':
        immediate: true
        handler: (id) ->
          log "Navigating to message ##{id}"
          if id
            await @syncLocal.promise
            log 'Route changed, finding message',            
            @chat.routedMessage = @chat.messages.find (message) => String(message.id) is String(id)
      
      'chat.routedMessage': (message) ->
        
        if message

          { id } = message

          if @$route.query.id isnt String(id)
            @$router.push query: { id }

</script>