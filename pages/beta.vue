<template lang="pug">

  TwoPanesAndSidebar(
      v-if="syncLocal.loaded"
      brand="Mindy"
      tagline="Brainstorm with AI"
      secondaryPaneIcon="layout-sidebar"
    )
    template(v-slot:sidebar)
      //- New chat button
      b-button.btn-lg.btn-block(
        variant="outline-primary"
        :to="{ query: { id: undefined } }"
      )
        b-icon.pr-2(icon="chat")
        | New chat
      div.pt-3
        MindyChatList(v-bind="{ chats, routedMessage }")
    template(v-slot:sidebar-footer)
      MindySidebarFooter
    template(v-slot:primary-pane)
      MindyChat(
        v-bind="chat"
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
  import Chat from '~/plugins/chat'

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
          'messages'
        ]
        format: 'yaml'
        prefix: 'mindy'

      computedData
        'mindmap.code': -> @chat.routedMessage?.context ? @chat.tree.thread?(@chat.routedMessage)?.find((message) -> message.context)?.context

    ]

    data: ->

      messages: []
      routedMessage: null

      mindmap:
        code: null
    
    computed:

      chat: -> new Chat @tree, @routedMessage
      
      tree: -> new TreeLike @messages, vm: @

      chats: -> @messages.filter( (message) -> !message.parentId ).map( (message) => new Chat @tree, message )
          
    watch:

      '$route.query.id':
        immediate: true
        handler: (id) ->
          log "Navigating to message ##{id}"
          if id
            await @syncLocal.promise
            log 'Route changed, finding message',            
            @routedMessage = @messages.find (message) => String(message.id) is String(id)
          else
            @routedMessage &&= null
      
      'routedMessage': (message) ->
        
        if message

          { id } = message
          @tree.nudge message
          @messages = [ ...@messages]

          if @$route.query.id isnt String(id)
            @$router.push query: { id }

</script>