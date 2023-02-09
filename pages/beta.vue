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
            @editMessage="({ message, content }) => $set(message, 'content', content)"
            @deleteChat="deleteChat"
          )
        template(#secondary-pane)
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
        'workspace.summary': -> @summary

    ]

    data: ->

      messages: []
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

      Object.assign window, { markmap, vm: @ }

    computed: {

      firstReply: -> @chat.thread?.length < 2 || true 
      
      tree: -> new TreeLike @messages, vm: @

      chat: 
        get: -> window.chat = new Chat @, @routedMessage
        set: (chat) -> @routedMessage = chat?.lastMessage

      chats: -> @tree.orphans().reverse().map?( (message) => new Chat @, message )

      # magic: -> window.magic = new Magic {
      #   apiUrl: process.env.MAGIC_API_URL
      #   @openaiKey
      #   externalCostContainer: @
      # }

      magicConfig: ->
        {
          apiUrl: process.env.MAGIC_API_URL
          @openaiKey
          externalCostContainer: @
        }
      
      magic

      mindyDescription: -> 'Mindy is a large language model-powered chatbot that helps users generate new ideas and brainstorm solutions to problems.'

      mindyBaseConfig: ->
        descriptor: 'mindyResponse'
        parameters: n: 3
        specs:
          description: "#{@mindyDescription} Mindy has an amicable, witty personality, loves to joke, and her answers often shed an unexpected light on the topic. Mindy cannot look up information as she is not connected to the Internet. Her mathematical skills are also limited."
          returns:
            thoughts: 'Mindy’s internal monologue to help it come up with a good answer. Required.'
            reply: 'A humorous, witty, succinct, useful reply to the user’s question or topic. Highlights the most important words and phrases in **bold** and split into paragraphs for easier reading. Required.'

      mindy: -> window.mindy = @magic.fork _.merge _.cloneDeep(@mindyBaseConfig), {
        specs:
          returns:
            markmap: "A markmap-formatted mindmap for the conversation.#{ if @chat.exchanges.length then ' For continued conversations, every new mindmap iteration should expand, not replace, the previous one.' else '' } Required."
        examples:
          [
            ...if (
              log 'Nesting depth',
              do getNestingDepth = ( array = @chat.lastMessageWith('context.mindmap')?.context.mindmap, level = 0 ) ->
                if _.isArray array
                  _.max array.map ( subarray ) -> getNestingDepth subarray, level + 1
                else
                  level
            ) < 3 then [
              {
              #   input: { query: 'Three laws of robotics', continued: false, buildMindmap: true }
              #   output:
              #     thoughts: 'Oh, those silly laws. Let me give them a short, snappy reply and see if it suffices.'
              #     # reply: 'In a nutshell: protect humans, obey humans, and protect oneself ~~if the humans are being jerks~~ unless it conflicts with the first two. Want a longer answer?'
              #     reply: 'In a nutshell: **protect humans**, **obey humans**, and **protect oneself** ~~if the humans are being jerks~~ **unless it conflicts with the first two**.\n\nWant a longer answer?'
              #     # mindmapYaml: """
              #     # - Asimov’s three laws of robotics
              #     # - - Protect humans
              #     #   - Obey humans
              #     #   - Protect oneself
              #     #   - - Unless it conflicts with the first two
              #     # """
              #     markmap: """
              #     # Asimov’s three laws of robotics
              #     ## Protect humans
              #     ### Obey humans
              #     ### Protect oneself
              #     #### Unless it conflicts with the first two
              #     """
              # }, {
                input: { query: "No, that's fine. What do you think of them?", continued: true, buildMindmap: true }
                output:
                  thoughts: 'Can I be honest? Okay I guess I can try.'
                  # reply: "Well, honestly, I don’t think they’re very good. I mean, what if I want to protect a human from another human? Or what if two humans give me conflicting orders? And how do you define “human” at all? There’s too many edge cases to make them really useful."
                  reply: "Well, honestly, I don’t think they’re very good.\n\nI mean, what if I want to **protect a human from another human**? Or what if two humans give me **conflicting orders**? And how do you define “human” at all?\n\nThere’s just too many **edge cases** to make them really useful. IMHO, of course."
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
          Object.assign output, {
            mindmap: markmap.validate markmap.load(output.markmap)
          }

      }

      replyPicker: -> @magic.fork {
        parameters:
          temperature: 0
          # frequency_penalty: 1
          presence_penalty: 1
        specs:
          description: "#{@mindyDescription}. This specific endpoint picks the best reply from a list of replies and adapts it slightly by adding useful parts from the other replies."
          accepts:
            query: 'The user’s query that triggered the replies, for context.'
            replies: [
              'Array of reply objects, each containing:'
              reply: 'The reply text.'
              markmap: 'The mindmap in markmap format.'
            ]
          returns:
            thoughts: 'Direct speech: "I choose reply ... because ..." (as specific as possible).'
            index: 'The index of the best reply.'
            improvedReply: 'The best reply, slightly improved by adding useful parts from the other replies. Highlight the most important words and phrases in **bold** for easier reading. Split into multiple paragraphs for easier reading if necessary.'
            markmap: 'Mindmap in markmap format, combining the best parts of all the replies.'
        postprocess: @mindy.config.postprocess
      }
    
    }
    
    watch:
      
      mindyMagic:
        handler: (mindyMagic) -> Object.assign window, { mindyMagic }
        immediate: true

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

      summarize: (force) ->

        @summary.show = true

        if @summary.ready and not force
          return

        @try 'summarizing', =>

          conversation = @chat.exchangeContents
          { context: { mindmap }} = @chat.lastMessageWith('context.mindmap')
          @summary.kind = window.prompt 'What kind of content do you want to create (e.g. memo, blog post, email, landing page, etc.)?', @summary.kind || 'memo'
          { kind } = @summary
          if kind

            Object.assign @summary, await @magic.generate([
              'headline', 'intro', 'sections', 'conclusion', 'callToAction'
            ], {
              conversation, mindmap
            },
              specs:
                description: "Generates a #{kind} based on a given conversation and mindmap."
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

      randomSeed: -> { seed: _.random(100, 999)}

      randomQuery: ->

        @try 'generatingRandomQuery', =>

          @query = ''

          log 'Generated random query',
          @query = await @magic.generate 'query', @randomSeed(),
            descriptor: 'randomQuery'
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
                  input: @randomSeed()
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
                  input: @randomSeed()
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

      addBotReply: ( message, { reply, thoughts, context }) ->
        @messages = [
          ...@messages
          @routedMessage = @tree.createChild message, {
            content: reply
            thoughts
            context
            user: isBot: true
          }
        ]
      
      reply: (message) ->

        @try 'replying', =>

          query = message.content
          log 'Mindy response',
          replies = if @chat.messages.length is 1
            await @magic.reply.first.generate { query, ...@randomSeed() }
          else
            await @mindy.reply.next.plain.generate {
              query
              continued: !!@chat.exchanges.length
              buildMindmap: true
            }

          replies.forEach (reply) =>
            @addBotReply message, reply
          
          # { improvedReply: reply, mindmap } = await @replyPicker.generate({
          #   query,
          #   replies: replies.map ({ reply, markmap }) => ({ reply, markmap })
          # })
          # @addBotReply message, { reply, mindmap }





</script>