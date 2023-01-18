<template lang="pug">
  
  div(v-if="syncLocal.loaded")
    TwoPanesAndSidebar(
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
          :busy="busy"
          @query="sendMessage"
          @editMessage="({ message, content }) => $set(message, 'content', content)"
          @deleteChat="deleteChat"
        )
      template(v-slot:secondary-pane)
        MindyWorkspace(
          v-bind.sync="workspace"
          v-on="{ randomQuery, elaborate, summarize }"
        )
    //- 
    
    //- Sumary modal
    b-modal#summary-modal(
      ref="summaryModal"
      :title="`Summary ${summary.format}`"
      size="lg"
      centered
      v-model="summary.show"
    )
      div.d-flex.flex-column.flex-grow-1
        div.flex-grow-1(v-if="busy.summarizing")
          div.text-center
            b-spinner
          div.text-center
            | Generating summary...
        div(v-else)
          h2(v-text="summary.headline")
          em(v-text="summary.intro")
          div(v-html="$md.render(summary.body || '')")

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

      title: "#{@chat.title} · Mindy"

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

    ]

    data: ->

      messages: []
      routedMessage: null
      openaiKey: null
      usdSpent: 0
      idsOfChatsBeingNamed: []

      summary:
        format: ''
        headline: ''
        intro: ''
        body: ''
        show: false

      query: ''

      layout:
        resetLayout: false

      workspace:
        context: null
          
    computed:
      
      tree: -> new TreeLike @messages, vm: @

      chat: 
        get: -> window.chat = new Chat @, @routedMessage
        set: (chat) -> @routedMessage = chat?.lastMessage

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
          returns:
            thoughts: 'Mindy’s internal monologue to help it come up with a good answer. Required.'
            reply: 'A succinct, useful reply to the user’s question or topic. Required.'
            mindmapYaml: "A YAML-formatted array summarizing the conversation.#{ if @chat.exchanges.length then ' For continued conversations, every new mindmap iteration should expand, not replace, the previous one.' else '' } Required."
        examples:
          [
            ...if @chat.exchanges.length < 1 then [
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

          # log "Fixing YAML formatting",
          # mindmapYaml = mindmapYaml.split('\n').map((line, index, lines) ->
          #   if index > 0
          #     previousLine = lines[index - 1]
          #     dashIndex = previousLine.indexOf '-'
          #     if dashIndex > -1
          #       if line[dashIndex] is ' '
          #         line = line.slice(0, dashIndex) + '-' + line.slice(dashIndex + 1)
          #   line
          # ).join('\n')

          # log "Converted mindmap from YAML",
          output.mindmap = yaml.load mindmapYaml

          # The mindmap list must contain strictly two items: the root and the first level of children. Therefore if there's another number of items, or if the first item is not a string, or if the second item is not an array, we reject the mindmap.
          if output.mindmap.length isnt 2 or not _.isString(output.mindmap[0]) or not _.isArray(output.mindmap[1])
            throw new Error "Mindmap is invalid: #{mindmapYaml}"

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

      deleteChat: ->
        # Ask for confirmation, then delete
        if window.confirm "Are you sure you want to delete the chat \"#{chat.title}\"? THERE IS NO UNDO!"
          chatIndex = @chats.indexOf @chat
          @messages = @tree.delete @chat.firstMessage
          @chat = @chats[chatIndex] || @chats[chatIndex - 1] || null

      summarize: ->

        @try 'summarizing', =>

          conversation = @chat.exchangeContents
          { context: { mindmap }} = @chat.lastMessageWith('context.mindmap')
          format = window.prompt 'What format do you want to use (e.g. blog post, email, landing page, etc.)?', 'blog post'
          if format isnt null
            @summary.show = true
            Object.assign @summary, {
              format
              ...(await @magic.generate(['headline', 'intro', 'body'], { conversation, mindmap, format },
                specs:
                  description: "Generates a markdown-formatted summary in the given format based on a given conversation and mindmap."
                  returns:
                    headline: 'Top-level headline for the summary. Required.'
                    intro: 'Introductory paragraph for the summary. Required.'
                    body: 'Body of the summary, in markdown format. Required.'
              ))
            }


      elaborate: (topic) ->
        @$nextTick =>
          @sendMessage
            content: "#{topic}?"
            parent: @chat.lastMessage

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
              returns:
                query: 'An example input to start a conversation with Mindy. Should be wow-worthy.'
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
            await @mindy.generate(
              query: message.content
              continued: !!@chat.exchanges.length
              buildMindmap: true
              reminder: "Mindy cannot 'look up' information as she is not connected to the Internet and only has general knowledge."
            )
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