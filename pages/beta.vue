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
          //- Button to rebuild the summary
          b-button(
            variant="outline-primary"
            @click="summarize"
          )
            b-icon.pr-2(icon="arrow-repeat"
              @click="summarize(true)"
            )
            | Try again

  div.d-flex.flex-column.vh-100.justify-content-center.align-items-center(v-else)
    b-spinner

</template>

<script lang="coffee">

  import yaml from 'js-yaml'

  import computedData from '~/plugins/mixins/computedData'
  import Chat from '~/plugins/chat'
  import log from '~/plugins/log'
  import Magic from 'almostmagic'
  import markmap from '~/plugins/markmap'
  import syncLocal from '~/plugins/mixins/syncLocal'
  import TreeLike from '~/plugins/treeLike'
  import tryActionMixin from '~/plugins/mixins/tryAction'

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
        'workspace.summary': -> @summary

    ]

    data: ->

      messages: []
      routedMessage: null
      openaiKey: null
      usdSpent: 0
      idsOfChatsBeingNamed: []

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

      Object.assign window, { markmap }

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

      mindyDescription: -> 'Mindy is a large language model-powered chatbot that helps users generate new ideas and brainstorm solutions to problems. Mindy has an amicable, witty personality, loves to joke, and her answers often shed an unexpected light on the topic. Mindy cannot look up information as she is not connected to the Internet. Her mathematical skills are also limited.'

      mindy: -> window.mindy = new Magic {
        ...@magic.config
        parameters:
          n: 3
        specs:
          description: @mindyDescription
          returns:
            thoughts: 'Mindy’s internal monologue to help it come up with a good answer. Required.'
            reply: 'A succinct, useful reply to the user’s question or topic. Required.'
            # mindmapYaml: "A YAML-formatted mindmap for the conversation.#{ if @chat.exchanges.length then ' For continued conversations, every new mindmap iteration should expand, not replace, the previous one.' else '' } Required."
            markmap: "A markmap-formatted mindmap for the conversation.#{ if @chat.exchanges.length then ' For continued conversations, every new mindmap iteration should expand, not replace, the previous one.' else '' } Required."
        examples:
          [
            # If the last mindmap doesn't have 3x nested levels, use the default examples (as the model might get the formatting for nested levels wrong)
            ...if (
              log 'Nesting depth',
              do getNestingDepth = ( array = @chat.lastMessageWith('context.mindmap')?.context.mindmap, level = 0 ) ->
                if _.isArray array
                  _.max array.map ( subarray ) -> getNestingDepth subarray, level + 1
                else
                  level
            ) < 3 then [
              {
                input: { query: 'Three laws of robotics', continued: false, buildMindmap: true }
                output:
                  thoughts: 'Oh, those silly laws. Let me give them a short, snappy reply and see if it suffices.'
                  reply: 'In a nutshell: protect humans, obey humans, and protect oneself ~~if the humans are being jerks~~ unless it conflicts with the first two. Want a longer answer?'
                  # mindmapYaml: """
                  # - Asimov’s three laws of robotics
                  # - - Protect humans
                  #   - Obey humans
                  #   - Protect oneself
                  #   - - Unless it conflicts with the first two
                  # """
                  markmap: """
                  # Asimov’s three laws of robotics
                  ## Protect humans
                  ### Obey humans
                  ### Protect oneself
                  #### Unless it conflicts with the first two
                  """
              }, {
                input: { query: "No, that's fine. What do you think of them?", continued: true, buildMindmap: true }
                output:
                  thoughts: 'Can I be honest? Okay I guess I can try.'
                  reply: "Well, honestly, I don’t think they’re very good. I mean, what if I want to protect a human from another human? Or what if two humans give me conflicting orders? And how do you define “human” at all? There’s too many edge cases to make them really useful."
                  # mindmapYaml: """
                  # - Asimov’s three laws of robotics
                  # - - Basics
                  #   - - Protect humans
                  #     - Obey humans
                  #     - Protect oneself
                  #     - - Unless it conflicts with the first two
                  # - - Criticism
                  #   - - Human vs. human
                  #     - Conflicting orders
                  #     - Definition of “human”
                  #     - Edge cases
                  # """
                  markmap: """
                  # Asimov’s three laws of robotics
                  ## Basics
                  ### Protect humans
                  ### Obey humans
                  ### Protect oneself
                  #### Unless it conflicts with the first two
                  ## Criticism
                  ### Human vs. human
                  ### Conflicting orders
                  ### Definition of “human”
                  ### Edge cases
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
                # ...( if buildMindmap then mindmapYaml: yaml.dump(response.context.mindmap) else {} )
                ...( if buildMindmap then markmap: markmap.dump(response.context.mindmap) else {} )
              }
          ]
        postprocess: (output) ->
          # log 'Postprocessing output', output
          # Make sure all outputs are present and not strings
          for key, value of output
            throw new Error "Ouput #{key} is missing" if not value
            throw new Error "Output #{key} is not a string" if not _.isString value
          # # Convert mindmap from YAML to an array

          # { mindmapYaml } = output

          # # Sometimes the model will incorrectly format YAML, omitting a dash where it should be.
          # # That's why we need to go through every line and add a dash if it's missing, which means
          # # a) take the index of the dash in the previous line
          # # b) if it is NOT a dash two characters after that index, skip this line
          # # c) see if this line has a whitespace at that index
          # # d) if yes, replace the whitespace with a dash

          # # log "Fixing YAML formatting",
          # mindmapYaml = mindmapYaml.split('\n').map((line, index, lines) ->
          #   if index > 0
          #     previousLine = lines[index - 1]
          #     dashIndex = previousLine.indexOf '-'
          #     if dashIndex > -1 and previousLine[dashIndex + 2] isnt '-'
          #       if line[dashIndex] is ' '
          #         line = line.slice(0, dashIndex) + '-' + line.slice(dashIndex + 1)
          #   line
          # ).join('\n')

          # # log "Converted mindmap from YAML",
          # output.mindmap = yaml.load mindmapYaml

          # # The mindmap list must contain strictly two items: the root and the first level of children. Therefore if there's another number of items, or if the first item is not a string, or if the second item is not an array, we need to add a new root and put the other items as its children.
          # if output.mindmap.length isnt 2 or not _.isString(output.mindmap[0]) or not _.isArray(output.mindmap[1])
          #   debugger
          #   output.mindmap = [ '💬', output.mindmap ]

          # # The mindmap can only contain arrays or strings. For objects, we need to convert them to arrays, each item being a string in the `key: value` format.
          # # log "Cleaned up mindmap",
          # output.mindmap = do walk = (node = output.mindmap) ->
          #   if _.isArray node
          #     node.map walk
          #   else if _.isObject node
          #     for key, value of node
          #       "#{key}: #{value}"
          #   else
          #     node
          # # log "Postprocessed output",
          # output

          # Convert mindmap from Markmap to an array
          Object.assign output, {
            mindmap: markmap.load(output.markmap)
          }

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
                  title: 'Succint (max 4 words) title summarizing the content. Required.'
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
          log 'chatIndex',
          chatIndex = @chats.findIndex (chat) => chat.id is @chat.id
          @messages = @tree.delete @chat.firstMessage
          # @chat = @chats[chatIndex] ? @chats[chatIndex - 1] ? null
          @routedMessage = null

      summarize: (force) ->

        @summary.show = true

        if @summary.ready and not force
          return

        @try 'summarizing', =>

          conversation = @chat.exchangeContents
          { context: { mindmap }} = @chat.lastMessageWith('context.mindmap')
          @summary.kind = window.prompt 'What kind of content do you want to create (e.g. memo, blog post, email, landing page, etc.)?', @summary.kind || 'memo'
          if @summary.kind

            Object.assign @summary, await @magic.generate([
              'headline', 'intro', 'sections', 'conclusion', 'callToAction'
            ], {
              what: @summary.kind,
              basedOn: { conversation, mindmap }
              # mindmap
            },
              specs:
                description: "Generates a piece of content of the given kind based on a given conversation and mindmap."
                # description: "Generates a piece of content of the given kind based on a given mindmap."
                returns:
                  headline: 'Top-level headline.'
                  intro: 'Introductory paragraph.'
                  sections:
                    description: 'An array of sections, each containing the following properties:'
                    properties:
                      headline: 'Section title.'
                      paragraphs: 'An array of paragraphs. Optional if there are bullets.'
                      bullets: 'An array of bullets. Optional if there are paragraphs. If both are present, the bullets will be rendered after the paragraphs.'
                  conclusion: 'A concluding paragraph.'
                  callToAction: 'A single-sentence call to action.'
              postprocess: (output) ->
                # If paragraphs/bullets are not arrays, make them arrays
                for section in output.sections
                  for key in ['paragraphs', 'bullets']
                    if section[key] and not _.isArray(section[key])
                      section[key] = [ section[key] ]
                output
            )
            @summary.ready = true


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