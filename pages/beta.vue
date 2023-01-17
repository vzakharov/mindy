<template lang="pug">

  TwoPanesAndSidebar(
      v-if="syncLocal.loaded"
      v-bind.sync="layout"
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
        v-bind.sync="chat"
        @newMessage="sendMessage"
      )
    template(v-slot:secondary-pane)
      MindyWorkspace(
        v-bind.sync="workspace"
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
  import Magic from 'almostmagic'
  import tryActionMixin from '~/plugins/mixins/tryAction'
  import yaml from 'js-yaml'

  export default

    head: ->

      { bookmark, content} = @routedMessage || {}

      title: if @routedMessage then "#{ if bookmark?.name then "#{bookmark.name} (bookmark)" else content } · Mindy" else 'Mindy · Brainstorm with AI'

    meta: [
      name: 'viewport'
      content: 'width=device-width, initial-scale=1, user-scalable=no'
    ]

    mixins: [
      tryActionMixin
      syncLocal
        keys: [
          'messages'
          'usdSpent'
          'openaiKey'
        ]
        format: 'yaml'
        prefix: 'mindy'

      computedData
        'workspace.context': -> @chat.routedMessage?.context ? @chat.tree.thread?(@chat.routedMessage)?.find((message) -> message.context)?.context
        'workspace.chat': -> @chat
        'bot.replying': -> @replying

    ]

    data: ->

      messages: []
      routedMessage: null
      openaiKey: null
      usdSpent: 0
      namingChats: false
      idsOfChatsBeingNamed: []
      replying: false

      layout:
        resetLayout: false

      workspace:
        context: null
      
      bot:
        replying: false
    
    computed:
      
      tree: -> new TreeLike @messages, vm: @

      chat: -> window.chat = new Chat @, @routedMessage

      chats: -> @tree.orphans().reverse().map?( (message) => new Chat @, message )

      magic: -> new Magic {
        apiUrl: process.env.MAGIC_API_URL
        @openaiKey
        externalCostContainer: @
      }

      mindy: -> new Magic {
        ...@magic.config
        parameters:
          n: 3
        specs:
          description: 'Mindy is a large language model-powered chatbot that helps users generate new ideas and brainstorm solutions to problems. Mindy has an amicable, witty personality, loves to joke, and her answers often shed an unexpected light on the topic.'
          outputKeys:
            thoughts: 'Mindy’s internal monologue to help it come up with a good answer. Required.'
            reply: 'A succinct, ironic reply to the user’s question or topic. Required.'
            # mindmap: "A nested array summarizing the conversation.#{ if @chat.exchanges.length then ' For continued conversations, every new mindmap iteration should expand, not replace, the previous one.' else '' } Required."
            mindmap: "A YAML-formatted array summarizing the conversation.#{ if @chat.exchanges.length then ' For continued conversations, every new mindmap iteration should expand, not replace, the previous one.' else '' } Required."
        examples: 
          # If no exchanges in the chat, use a default example
          if !@chat.exchanges.length
            [
              {
                input: { query: 'Three laws of robotics', continued: false }
                output:
                  thoughts: 'Oh, those silly laws. Let me give them a short, snappy reply and see if it suffices.'
                  reply: 'In a nutshell: protect humans, obey humans, and protect oneself ~~if the humans are being jerks~~ unless it conflicts with the first two. Want a longer answer?'
                  # mindmap: [
                  #   'Asimov’s three laws of robotics',
                  #   [
                  #     'Protect humans',
                  #     'Obey humans',
                  #     'Protect oneself',
                  #     [ 'Unless it conflicts with the first two' ]
                  #   ]
                  # ]
                  mindmap: """
                  - Asimov’s three laws of robotics
                  - - Protect humans
                    - Obey humans
                    - Protect oneself
                    - - Unless it conflicts with the first two
                  """
              }
            ]
          else @chat.exchanges
        # 
        # validateOutput: (output) ->
        #   # log 'Validating output', output
        #   if not output
        #     throw new Error 'No output'
        #   [ 'reply', 'mindmap', 'thoughts' ].forEach (key) ->
        #     if not output[key]
        #       throw new Error "No #{key}"
        #     if not _.isString output[key]
        #       throw new Error "#{key} is not a string"
        #   # Mindmap must be valid YAML
        #   try
        #     yaml.load output.mindmap
        #   catch err
        #     throw new Error "Mindmap is not valid YAML"
        postprocess: (output) ->
          # log 'Postprocessing output', output
          # Make sure all outputs are present and not strings
          for key, value of output
            throw new Error "Ouput #{key} is missing" if not value
            throw new Error "Output #{key} is not a string" if not _.isString value
          # Convert mindmap from YAML to an array
          # log "Converted mindmap from YAML",
          output.mindmap = yaml.load output.mindmap
          # The mindmap can only contain arrays or strings. For objects, we need to convert them to arrays, each item being a string in the `key: value` format.
          # log "Cleaned up mindmap",
          output.mindmap = do walk = (node = output.mindmap) ->
            if _.isArray node
              node.map walk
            else if _.isObject node
              for key, value of node
                "#{key}: #{value}"
            else
              node
          # log "Postprocessed output",
          output

      }
          
    mounted: ->

      Object.assign window, {
        @magic, @mindy
      }

    watch:

      chat: -> @layout.resetLayout = true

      chats: (chats) ->
        # For all untitled chats, derive the title using magic
        @try 'namingChats', =>
          await Promise.all chats.map (chat) =>
            # log 'Naming chat',
            { title, content, id } = chat.firstMessage || {}
            if content and not title
              { title, isGibberish } = await @magic.generate(['title', 'isGibberish'], { content },
                specs:
                  title: 'A short, succint title summarizing the content. Required.'
                  isGibberish: 'Whether the title is gibberish. Required.'
              )
              if isGibberish
                title = chat.title # I.e. "Chat #..."
              _.assign chat.firstMessage, { title }
              @messages = [ ...@messages ]
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

      sendMessage: ({ content, parent }) ->

        log 'Sending message', content, parent
        @messages = [
          ...@messages
          @routedMessage = @tree.createChild parent, {
            content
            user: isBot: false
          }
        ]

        @$nextTick => @reply @routedMessage
      
      reply: (message) ->

        @try 'replying', =>

          (
            log "Choices",
            await @mindy.generate({ query: message.content, continued: !!@chat.exchanges.length })
          ).forEach ({ reply, mindmap, thoughts }) =>
            @messages = [
              ...@messages
              @routedMessage = @tree.createChild message, {
                content: reply
                context: {
                  mindmap, thoughts
                }
                user: isBot: true
              }
            ]



</script>