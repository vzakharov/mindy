<template lang="pug">
  
  div(v-if="syncLocal.loaded")
    b-modal(
      v-if="!auth.token"
      :visible="true"
      size="sm"
      hide-footer
      centered
      hide-header
      no-close-on-backdrop
      no-close-on-esc
    )
      Auth(
        v-bind.sync="auth.form"
        :busy="busy"
        v-on="{ login }"
      )
    template
      TwoPanesAndSidebar(
          v-bind.sync="layout"
          brand="Mindy"
          tagline="Brainstorm with AI"
          secondaryPaneIcon="layout-sidebar"
        )
        template(#sidebar)
          //- New chat button
          b-button.btn-lg.btn-block(
            variant="outline-primary"
            :to="{ query: { id: undefined } }"
          )
            b-icon.pr-2(icon="chat")
            | New chat
          div.pt-3
            MindyChatList(v-bind="{ chats, routedMessage, loggedIn }")
        template(#sidebar-footer)
          MindySidebarFooter(
            v-bind="{ user, busy }"
          )
        template(#primary-pane)
          MindyChat(
            v-bind.sync="chat"
            :query="query"
            :busy="busy"
            :associations="associations"
            @query="sendMessage"
            @tryAgain="reply(tree.parent($event))"
            @editMessage="({ message, content }) => $set(message, 'content', content)"
            @deleteChat="deleteChat"
          )
        template(#secondary-pane)
          MindyWorkspace(
            v-bind.sync="workspace"
            :busy="busy"
            v-on="{ randomQuery, elaborate, generateContent }"
          )
      //- 
      
      //- Sumary modal
      b-modal#summary-modal(
        ref="summaryModal"
        :title="`Summary ${summary.kind}`"
        size="lg"
        centered
        v-model="summary.show"
        hide-footer
      )
        div.d-flex.flex-column.flex-grow-1
        div.flex-grow-1(v-if="busy.summarizing")
          div.text-center
            b-spinner
          div.text-center
            | Generating summary...
        div(v-else)
          h2(v-text="summary.headline")
          p
            em(v-text="summary.intro")
          div(v-for="section in summary.sections")
            h3(v-text="section.headline")
            div(v-for="paragraph in section.paragraphs", v-html="$md.render(paragraph)")
            ul(v-if="section.bullets")
              li(v-for="bullet in section.bullets", v-html="$md.render(bullet)")
          p(v-text="summary.conclusion")
          p
            strong(v-text="summary.callToAction")
          //- //- Button to rebuild the summary
          //- b-button(
          //-   variant="outline-primary"
          //-   @click="summarize"
          //- )
          //-   b-icon.pr-2(icon="arrow-repeat"
          //-     @click="summarize(true)"
          //-   )
          //-   | Try again

  div.d-flex.flex-column.vh-100.justify-content-center.align-items-center(v-else)
    b-spinner

</template>

<script lang="coffee">

  import yaml from 'js-yaml'

  import authMixin from '~/plugins/mixins/bubbleAuth'
  import computedData from '~/plugins/mixins/computedData'
  import Chat from '~/plugins/chat'
  import log from '~/plugins/log'
  import Magic from 'almostmagic'
  import markmap from '~/plugins/markmap'
  import syncLocal from '~/plugins/mixins/syncLocal'
  import TreeLike from '~/plugins/treeLike'
  import tryActionMixin from '~/plugins/mixins/tryAction'
  import magic from '~/plugins/magic'

  export default

    head: ->

      { bookmark, content} = @routedMessage || {}

      title: "#{@chat.title} · Mindy"

    meta: [
      name: 'viewport'
      content: 'width=device-width, initial-scale=1, user-scalable=no'
    ]

    mixins: [
      authMixin
      tryActionMixin
      syncLocal
        keys: [
          'messages'
          'usdSpent'
          'openaiKey'
          'openAIkey' # for backwards compatibility
        ]
        format: 'yaml'
        prefix: 'mindy'

      computedData
        'workspace.context': ->
          { tree, routedMessage: message } = @chat
          _.find(
            [
              ...tree.heritage(message, includeSelf: true)
              ...tree.ancestors(message)
            ],
            (message) -> message.context?.mindmap
          )?.context
        'workspace.chat': -> @chat
        'workspace.message': -> @routedMessage

    ]

    data: ->

      messages: []
      messageBeingRepliedTo: null
      routedMessage: null
      openaiKey: null
      openAIkey: null # for backwards compatibility
      usdSpent: 0
      idsOfChatsBeingNamed: []
      associations: []

      summary:
        ready: false
        kind: ''
        headline: ''
        intro: ''
        body: ''
        show: false

      query: ''

      layout:
        resetLayout: false

      workspace:
        context: {}
        chat: {}
        summary: {}
    
    mounted: ->

      Object.assign window, { markmap, @magic, vm: @ }

    computed: {

      firstReply: -> @chat.thread?.length < 2 || true 
      
      tree: -> new TreeLike @messages, vm: @

      chat: 
        get: -> {
          ...(window.chat = new Chat @, @routedMessage)
          @messageBeingRepliedTo
        }
        set: (chat) -> @routedMessage = chat?.lastMessage

      chats: -> @tree.orphans().reverse().map?( (message) => new Chat @, message )

      magicConfig: ->
        {
          apiUrl: process.env.MAGIC_API_URL
          @openaiKey
          externalCostContainer: @
        }
      
      magic

    }


    watch:
      
      openAIkey: (key) ->
        if key
          @openaiKey = key

      chat: -> @layout.resetLayout = true

      chats: (chats) ->
        # For all untitled chats, derive the title using magic
        await @try 'namingChats', =>
          @associations = []
          await Promise.all chats.map (chat) =>
            # log 'Naming chat',
            { title, content, id } = chat.firstMessage || {}
            if content and not title
              { title, isGibberish } = await @magic.chatTitle.generate({ content })
              if isGibberish
                title = chat.title # I.e. "Chat #..."
              _.assign chat.firstMessage, { title }
              @messages = [ ...@messages ]
              @$nextTick =>
                await @try 'fetchingAssociations', =>
                  { @associations } = await @magic.freeAssociations.generate( concept: title || content.slice(0, 20) )
        , oneAtATime: true

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
      
    methods:

      deleteChat: ->
        # Ask for confirmation, then delete
        if window.confirm "Are you sure you want to delete the chat \"#{chat.title}\"? THERE IS NO UNDO!"
          log 'chatIndex',
          chatIndex = @chats.findIndex (chat) => chat.id is @chat.id
          @messages = @tree.delete @chat.firstMessage
          # @chat = @chats[chatIndex] ? @chats[chatIndex - 1] ? null
          @routedMessage = null

      elaborate: (topic) ->
        @$nextTick =>
          @sendMessage
            content: "#{topic}?"
            parent: @chat.lastMessage

      generateContent: (message) ->
        @try 'generatingContent', =>
          
          log 'Generating content for message',
          try { context, context: { content, mindmap, content: { type } } } = message

          log 'Grandparent:',
          grandParent = @tree.grandParent message
          currentContent = grandParent?.context?.content
          modifier = @getModifier grandParent
          @$set context, type, await @magic.generate[type][modifier].generate {
            conversation: @chat.getConversation(message)
            markmap: markmap.dump mindmap
            currentContent
            requestedContent: content
            ...( 
              if currentContent?
                [currentContent.type]: grandParent.context[currentContent.type]
              else
                {}
            )
          }
      
      reply: (message) ->

        @try 'replying', =>

          # log 'Replying to message',
          @messageBeingRepliedTo = message
          # log 'parent:',
          parent = @tree.parent message
          # log 'Modifier',
          modifier = @getModifier parent
          firstTime = modifier is 'firstTime'
          replies = await @magic.reply[modifier].generate log 'Generate request:', {
            ...@randomSeed()
            ...(
              if firstTime
                {}
              else
                try { context, context: { content, mindmap, content: { type } } } = parent 
                {
                  precedingConversation: @chat.getConversation(message)
                  markmap: markmap.dump mindmap if mindmap
                  currentContent: content if content
                  ...(
                    if content?
                      [type]: context[type]
                    else
                      {}
                  )
                }
            )
            query: message.content
          }
          
          console.log replies

          replies.forEach (reply) =>
            @addBotReply message, reply

      
      getModifier: (message, type) ->
        # if @chat.conversationAbove.length is 0
        if @chat.getConversation(message).length is 0
          'firstTime'
        else
          # If there is context.text/code, 'fromText/fromCode' respectively, otherwise 'continued'
          { type } = message.context?.content ? {}
          if type and message.context[type]
            "from#{_.capitalize type}"
          else
            'continued'
            

      randomSeed: -> { seed: _.random(100, 999)}

      randomQuery: ->

        @query = ''
        @try 'generatingRandomQuery', =>
          @query = await @magic.randomQuery().generate()

      sendMessage: ({ content, parent }) ->

        # log 'Sending message', content, parent
        @messages = [
          ...@messages
          @routedMessage = @tree.createChild parent, {
            content
            user: isBot: false
          }
        ]

        @query = ''

        @$nextTick => @reply @routedMessage

      addBotReply: ( message, { reply, mindmap, thoughts, content }) ->
        @messages = [
          ...@messages
          @routedMessage = @tree.createChild message, {
            content: reply
            thoughts
            context: {
              mindmap
              content
            }
            user: isBot: true
          }
        ]
    
</script>

<style>

pre {
  /* dark background */
  background-color: #1e1e1e;
  /* light text */
  color: #d4d4d4;
  /* rounded */
  border-radius: 5px;
  /* shadow */
  box-shadow: 0 0 5px 0 rgba(0, 0, 0, 0.5);
  /* padding */
  padding: 10px;
  /* margin */
  margin: 5px;
}

</style>