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
        :query="query"
        @query="sendMessage"
        @editMessage="({ message, content }) => $set(message, 'content', content)"
      )
    template(v-slot:secondary-pane)
      MindyWorkspace(
        v-bind.sync="workspace"
        v-on="{ randomQuery }"
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
        'bot.replying': -> @replying
        'bot.generatingRandomQuery': -> @generatingRandomQuery

    ]

    data: ->

      messages: []
      routedMessage: null
      openaiKey: null
      usdSpent: 0
      namingChats: false
      idsOfChatsBeingNamed: []
      replying: false
      generatingRandomQuery: false
      query: ''

      layout:
        resetLayout: false

      workspace:
        context: null
      
      bot:
        replying: false
        generatingRandomQuery: false
    
    computed:
      
      tree: -> new TreeLike @messages, vm: @

      chat: ->
        window.chat = new Chat @, @routedMessage

      chats: -> @tree.orphans().reverse().map?( (message) => new Chat @, message )

      magic: -> window.magic = new Magic {
        apiUrl: process.env.MAGIC_API_URL
        @openaiKey
        externalCostContainer: @
      }

      mindyDescription: -> 'Mindy is a large language model-powered chatbot that helps users generate new ideas and brainstorm solutions to problems. Mindy has an amicable, witty personality, loves to joke, and her answers often shed an unexpected light on the topic.'

      mindy: -> window.mindy = new Magic {
        ...@magic.config
        parameters:
          n: 3
        specs:
          description: @mindyDescription
          outputKeys:
            thoughts: 'Mindy’s internal monologue to help it come up with a good answer. Required.'
            reply: 'A succinct, ironic reply to the user’s question or topic. Required.'
            mindmapYaml: "A YAML-formatted array summarizing the conversation.#{ if @chat.exchanges.length then ' For continued conversations, every new mindmap iteration should expand, not replace, the previous one.' else '' } Required."
        examples:
          # If less than 3 exchanges, use the default example
          [
            ...if @chat.exchanges.length < 3 then [
              {
                input: { query: 'Three laws of robotics', continued: false, buildMindmap: true }
                output:
                  thoughts: 'Oh, those silly laws. Let me give them a short, snappy reply and see if it suffices.'
                  reply: 'In a nutshell: protect humans, obey humans, and protect oneself ~~if the humans are being jerks~~ unless it conflicts with the first two. Want a longer answer?'
                  mindmapYaml: """
                  - Asimov’s three laws of robotics
                  - - Protect humans
                    - Obey humans
                    - Protect oneself
                    - - Unless it conflicts with the first two
                  """
              }
            ] else []
            ..._.map @chat.exchanges, ( { query, response }, index ) =>
              # Only include the mindmap for the last exchange that has a mindmap
              buildMindmap = response is @chat.lastMessageWith('context.mindmap')
              input: {
                query: query.content
                continued: index > 0
                buildMindmap
              }
              output: {
                thoughts: response.context.thoughts
                reply: response.content
                ...( if buildMindmap then mindmapYaml: yaml.dump(response.context.mindmap) else {} )
              }
          ]
        postprocess: (output) ->
          # log 'Postprocessing output', output
          # Make sure all outputs are present and not strings
          for key, value of output
            throw new Error "Ouput #{key} is missing" if not value
            throw new Error "Output #{key} is not a string" if not _.isString value
          # Convert mindmap from YAML to an array

          { mindmapYaml } = output

          # Sometimes the model will incorrectly format YAML, omitting a dash where it should be.
          # That's why we need to go through every line and add a dash if it's missing, which means
          # a) take the index of the dash in the previous line
          # b) see if this line has a whitespace at that index
          # c) if yes, replace the whitespace with a dash

          log "Fixing YAML formatting",
          mindmapYaml = mindmapYaml.split('\n').map((line, index, lines) ->
            if index > 0
              previousLine = lines[index - 1]
              dashIndex = previousLine.indexOf '-'
              if dashIndex > -1
                if line[dashIndex] is ' '
                  line = line.slice(0, dashIndex) + '-' + line.slice(dashIndex + 1)
            line
          ).join('\n')

          # log "Converted mindmap from YAML",
          output.mindmap = yaml.load mindmapYaml
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
      
    watch:

      chat: -> @layout.resetLayout = true

      chats: (chats) ->
        # For all untitled chats, derive the title using magic
        @try 'namingChats', =>
          await Promise.all chats.map (chat) =>
            # log 'Naming chat',
            { title, content, id } = chat.firstMessage || {}
            if content and not title
              { topic: title, isGibberish } = await @magic.generate(['topic', 'isGibberish'], { content },
                specs:
                  topic: 'What is the content about? Required.'
                  isGibberish: 'Whether the content is gibberish. Required.'
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

      randomQuery: ->

        @try 'generatingRandomQuery', =>

          randomSeed = => { seed: _.random(100, 999)}
          @query = ''

          log 'Generated random query',
          { @query } = await @magic.generate randomSeed(),
            parameters:
              temperature: 1
            specs:
              description: @mindyDescription
              outputKeys:
                query: 'An example query to start a conversation with Mindy. Required.'
            examples:
              # If there are more than 5 chats already, pick 2 random chats and use their first messages as queries
              if @chats.length > 5
                _.sampleSize @chats, 2
                .map ({ firstMessage: { content } }) =>
                  input: randomSeed()
                  output: { query: content }
              else
                _.sampleSize([
                  "Startup ideas for someone who is not a programmer"
                  "What is the meaning of life?"
                  "I want to go on a vacation somewhere warm but not too expensive"
                  "JavaScript vs TypeScript"
                  "Top 5 movies of all time"
                  "I'm just bored, what should I do?"
                ], 2).map (query) =>
                  input: randomSeed()
                  output: { query }

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
      
      reply: (message) ->

        @try 'replying', =>

          (
            # log "Choices",
            await @mindy.generate({ query: message.content, continued: !!@chat.exchanges.length, buildMindmap: true })
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