<template lang="pug">
  div This is chat space
</template>

<script lang="coffee">

  import axios from 'axios'
  import _ from 'lodash'
  import QRCode from 'qrcode'

  import TreeLike from '~/plugins/treeLike'
  import log from '~/plugins/log'

  import syncLocal from '~/plugins/mixins/syncLocal'
  import exposeVM from '~/plugins/exposeVM'
  import tryAction from '~/plugins/tryAction'
  import windowMixin from '~/plugins/mixins/window'
  import mixpanelMixin from '~/plugins/mixins/mixpanel'
  import checkWidthMixin from '~/plugins/mixins/checkWidth'

  import PolygonClient from '~/plugins/polygonClient'

  defaultSettings =
    allowFineTuning: true
    autoBuildContext: true
    numGenerations: 3
    temperature: 0.6

  export default

    mixins: [
      syncLocal
        keys: [
          'user', 'messages', 'openAIkey', 'usdSpent', 'settings', 'chatboxCollapsed', 'chatboxHorizontalAnchor', 'fineTuningRequested'
        ]
        format: 'yaml'
        prefix: 'mindy'
      exposeVM
      tryAction
      windowMixin
      mixpanelMixin
      checkWidthMixin()
    ]

    head: ->

      { bookmark, content} = @routedMessage || {}

      title: if @routedMessage then "#{ if bookmark?.name then "#{bookmark.name} (bookmark)" else content } · Mindy" else 'Mindy · Brainstorm with AI'

      meta: [
        name: 'viewport'
        content: 'width=device-width, initial-scale=1, user-scalable=no'
      ]

    data: ->
      suggestions: []
      hoveredMessage: null
      fineTuningRequested: false
      chatboxCollapsed: false
      chatboxVerticalAnchor: 'top'
      chatboxHorizontalAnchor: 'left'
      darkmode: false
      settings: defaultSettings
      input: ''
      lastMessageTime: null
      sending: false
      generatingContext: false
      generatingReply: false
      enteredName: ''
      checkingName: false
      editing: {
        message: null,
        input: ''
      }
      nameUnavailable: false
      user: {
        name: 'you'
      }
      messages: []
      openAIkey: null
      routedMessage: null
      typingCount: 0
      typingInterval: null
      usdSpent: 0
      bot:
        name: 'mindy'
        isBot: true
      idsBySlug: null
      previousThread: null

    computed:

      generating: -> @generatingContext or @generatingReply

      suggestionsContext: ->
        # Create the suggestion context by using 'Hey Mindy!' as the root node and the others (indented by a tab) as children
        if @suggestions.length
          log 'Suggestion context',
          @suggestionsContext = [
            'Hey Mindy!'
            ...@suggestions.map( (suggestion) -> "\t#{suggestion}" )
          ].join('\n')

      messageForContext: ->
        if @routedMessage
          log "Message with context for routed message #{@routedMessage.id}",
          messageForContext = @getMessageWithContext(@routedMessage)
        if not messageForContext and @suggestionsContext
          log "Using suggestions context",
          messageForContext =
            id: 0
            context: @suggestionsContext
        messageForContext

      context: ->
        # Take the first line of the context, if any
        @routedMessage?.context

      tree: ->
        new TreeLike(@messages, vm: @)

      thread: ->
        # If the existing thread includes the routed message, use that
        if not @routedMessage
          []
        else
          if @previousThread?.includes(@routedMessage)
            @previousThread
          else
            @previousThread = @tree.thread(@routedMessage or @tree.root)
      
      lastMessage: ->
        _.last(@thread)

      polygon: ->
        new PolygonClient({
          @openAIkey
          vm: @
          vmKey: 'usdSpent'
          spent: @usdSpent
          defaultParameters:
            max_tokens: 300 
            n: @settings.numGenerations
            temperature: @settings.temperature
        })

    mounted: ->

      @mixpanel.track 'Started'

      # Show OpenAI key modal if not set
      if !@openAIkey
        console.log "OpenAI key not set; showing modal"
        @$refs.openAIkeyModal.show()
      else
        @$refs.input?.focus()

    methods:

      getSuggestions: ->

        @try 'generatingContext',
          =>
            
            log 'Suggestions:',
            suggestions = await do getSuggestions = =>
              { choices: [{ text }] } = await @polygon.run 'suggest', {}, stop: ['\n\n'], temperature: 1
              # The text returned contains suggestions on how the user can use Mindy in the following format:
              # ```How can I increase customer acquisition?
              # 2. What are some creative ways to spice up dinner?
              # 3. What are some tips to improve my relationships?```
              # I.e., it is an ordered list of questions, with the first question missing the number.
              # We should
              # a) Split them by newline
              # b) Test every line to see if it meets the format and discard the ones that don't
              # c) Remove the list prefix from the lines that do
              suggestions = text
                .split('\n')
                .filter( (line) ->
                  # Test if the line ends with a question mark
                  line.match(/\?$/)
                )
                .map( (line) ->
                  # Remove the list prefix, if any
                  line.replace(/^\d+\.\s*/, '')
                )

            # Add the suggestions to @suggestions
            @suggestions = [ ...@suggestions, ...suggestions ]

            # If there's less than 3 @suggestions, get more
            if @suggestions.length < 3
              @$nextTick @getSuggestions

      getMessageWithContext: (message, { includeSelf = true, direction = 'both' } = {} ) -> 
        # `direction` can be 'past', 'future' or 'both'. 'both' means first past, then future (not the other way around)
        if message
          log "Message with context for #{message.id} (direction: #{direction}, includeSelf: #{includeSelf})",
          switch direction
            when 'past'
              _.findLast @tree.lineage(message, { includeSelf }), (message) -> message.context
            when 'future'
              _.find @tree.heritage(message, { includeSelf }), (message) -> message.context
            when 'both'
              @getMessageWithContext(message, { includeSelf, direction: 'past' }) or @getMessageWithContext(message, { includeSelf, direction: 'future' })

      bookmark: (message) ->
        if message.bookmark
          # Prompt for deletion
          if confirm("Delete the bookmark? THERE IS NO UNDO!")
            @$set message, 'bookmark', false
        else
          # Show a prompt asking for a name. If no name is given, just use `true`
          if name = prompt("Bookmark this reply as what? (Leave blank to bookmark anonymously)")
          # (= is not a typo; we don't want to set the bookmark if the user cancels the prompt)
            @$set message, 'bookmark', if name then { name } else true

      turnOffDarkmode: (darkModeExitPromise) ->

        @darkmode = false
        try
          text = await darkModeExitPromise
          @$bvToast.toast(text, {
            title: '💡',
            variant: 'success',
            autoHideDelay: text.length * 50,
          })

      upvote: (message) ->

        # If no fine-tuning was requested, request it now
        if !@fineTuningRequested
          @$bvModal.show('fine-tuning-request-modal')
          @fineTuningRequested = true
          @mixpanel.track 'Fine-tuning requested'
        else
          { upvoted } = message
          @$set message, 'upvoted', !upvoted
          if message.upvoted
            @mixpanel.track 'Upvoted'
            if !message.everUpvoted
              @polygon.upvote(message.generationId)
            @$set message, 'everUpvoted', true
          else
            @mixpanel.track 'Unupvoted'


      toggleChatboxCollapsed: ->
        @chatboxCollapsed = !@chatboxCollapsed
        if !@chatboxCollapsed
          @chatboxVerticalAnchor = 'top'
          @chatboxHorizontalAnchor = 'left'

      rotateChatboxAnchor: ->
        if @chatboxVerticalAnchor is 'top'
          if @chatboxHorizontalAnchor is 'left'
            @chatboxHorizontalAnchor = 'right'
          else
            @chatboxVerticalAnchor = 'bottom'
        else
          if @chatboxHorizontalAnchor is 'right'
            @chatboxHorizontalAnchor = 'left'
          else
            @chatboxVerticalAnchor = 'top'

      addMessage: (message) ->
        @messages = [ @messages..., message ]
        message
      
      edit: (message) ->
        @editing.message = message
        @editing.input = message.content
    
      sendMessage: ( input = @input, parent = _.last(@thread) or @tree.root, retrying = false ) ->

        console.log {input, parent, retrying}

        # Use slug 'first' if this the first message (i.e. parent is null), otherwise use 'continued' (which will use the previous convo  as context)
        if ( if retrying then @tree.parent(parent) else parent ) isnt @tree.root
          # slug = 'continued'
          continued = true

          # Also combine all the previous messages in the thread as `previousConversation`, in the format "user1:\nmessage1\n\nuser2:\nmessage2\n\n..."
          previousConversation = @tree
            .lineage(
              parent, !retrying
            )
            .map(({ user: { isBot }, content }) -> "#{if isBot then 'Mindy' else 'User'}:\n#{content}")
            .join('\n\n')

          console.log {previousConversation}

        # else
        #   slug = 'first'

        slug = if continued then 'continued' else 'first'

        @try 'sending', 
          =>
            if !retrying

              message = @addMessage @tree.createChild parent,
                user: @user
                content: input
              @input = ''
              @routedMessage = message

              # scroll to bottom
              @$nextTick =>
                @$refs.scrollToBottom?.scrollIntoView()
          
            else
              message = parent

            console.log {message}

            @$nextTick =>

              @try 'generatingReply', 
                =>

                  { choices, generationId } = await @polygon.run slug, { input, previousConversation }, {
                    stop: 'User:'
                    n: if @settings.temperature > 0 then @settings.numGenerations else 1
                  }

                  @input = ''
                  
                  console.log { message, choices }
                  
                  choices.forEach ({ text, generationId }) =>

                    reply = @addMessage @tree.createChild message, {
                      user: @bot
                      content: text
                      generationId
                    }
                    
                    console.log { reply }
                  
                    if @settings.autoBuildContext
                      @mixpanel.track 'Auto context triggered'
                      @$nextTick =>
                        @generateContext(reply)

                  @$nextTick =>
                    # Navigate to the last created message
                    @routedMessage = _.last(@messages)
                    @$refs.scrollToBottom?.scrollIntoView()
                    @focusOnInput()

                mixpanelProps: {
                  retrying
                  @settings
                  lineageLength: @tree.lineage(parent).length
                }

                except: (error) =>
                  console.error error
                  # Remove message (so that it isn't left unresponded to)
                  @messages = _.without @messages, message
                  input = message.content 
          track: false


      focusOnInput: ->

        @$nextTick =>
          observer = new MutationObserver ( mutations ) =>
            if mutation = mutations.find ({ attributeName, target: { disabled } }) -> attributeName is 'disabled' and !disabled
            # (`=` is not a typo; it's an assignment, not a comparison)
              mutation.target?.focus()
              observer.disconnect()
          observer.observe document.querySelector('#input'), { attributes: true }

      getConversation: (messages) ->

        if not _.isArray messages
          messages = @tree.lineage messages, includeSelf: true
        
        messages
          .map(({ user: { isBot }, content }) -> "#{if isBot then 'Mindy' else 'User'}:\n#{content}")
          .join('\n\n')


      generateContext: (message) ->

        @try 'generatingContext',
          =>

            log 'Generating context for', message

            # Find the most recent message that has a context
            previousMessageWithContext = @getMessageWithContext message, includeSelf: false, direction: 'past'

            contextExists = !!previousMessageWithContext

            slug = if contextExists then 'context-rebuild' else 'context'

            log { slug }

            log "Conversation before #{if contextExists then 'previous context' else 'current message'}",
            conversationBeforePreviousContext = @getConversation previousMessageWithContext or message

            if contextExists

              previousContext = previousMessageWithContext.context

              log 'Messages after previous context',
              messagesAfterPreviousContext = @tree.heritage previousMessageWithContext, includeSelf: false

              log 'Conversation after previous context', 
              conversationAfterPreviousContext = @getConversation messagesAfterPreviousContext

            { choices: [{ text }] } = await @polygon.run slug, {
              conversationBeforePreviousContext,
              previousContext,
              conversationAfterPreviousContext,
            }, {
              stop: '```'
              temperature: 0.5
              n: 1
            }

            getIndent = ( line, tabSize = 2) => ( line.length - line.trimLeft().length ) / tabSize
            postProcessContext = (value) ->

              value = value.replace? /```[\s\S]*?/, ''
              value = value.trim()
              lines = value.trim().split '\n'

              # Take the tab size from the second line
              tabSize = getIndent lines[1], 1

              lines = lines.map (line) ->
                indent = getIndent line, tabSize
                line
                # Make the indent of one tab
                  .replace /^\s*/, '\t'.repeat indent
                # Remove any leading bullet points: -, *, •
                  # .replace /(?<=\s*)[-*•]\s*/, ''
                  # rewrite because safari doesn't support lookbehind
                  .replace /(^\s*)[-*•]\s*/, '$1'
              
              lines.join '\n'

            @$set message, 'context', log 'Post-processed context', postProcessContext(text)

          except: (error) =>
            console.error error
      

      cloneAndSend: () ->

        try
          @sendMessage( @editing.input, @tree.parent(@editing.message) )
        finally
          @editing.message = null

    watch: {

      ..._.transform defaultSettings, (result, value, key) ->
        result["settings.#{key}"] = (value) ->
          if !@watchersToIgnore?.includes 'settings'
            @mixpanel.track {
              allowFineTuning: if value then 'Fine tuning enabled' else 'Fine tuning disabled'
              autoBuildContext: if value then 'Auto context enabled' else 'Auto context disabled'
              temperature: 'Temperature changed'
              numGenerations: 'Num generations changed'
            }[key], if !_.isBoolean value then { [key]: value } else undefined

      usdSpent: ( usdSpent, oldUsdSpent ) ->
        if !@watchersToIgnore?.includes 'usdSpent'
          console.log 'USD spent', usdSpent, oldUsdSpent
          @mixpanel.track 'USD spent',
            total: usdSpent
            delta: usdSpent - oldUsdSpent
      
      generatingReply: (generatingReply) ->

        clearInterval @typingInterval
        if generatingReply
          # Scroll to bottom
          @$nextTick =>
            @$refs.scrollToBottom?.scrollIntoView()
          @typingInterval = setInterval =>
            @typingCount = ( @typingCount + 1 ) % 3
          , 500
        else
          @typingCount = 0
      
      routedMessage: (message) ->
        if message
          { id, user: { isBot }} = message
          # Nudge the message
          @tree.nudge message
          if id != parseInt @$route.query?.id
            log "Routing to message ##{id}"
            @$router.push { query: { id: message.id } }
          # Scroll to message
          @$nextTick =>
            document.getElementById("message-#{id}")?.scrollIntoView()
      
      '$route.query.id':
        immediate: true
        handler: (id) ->
          log "Navigating to message ##{id}"
          if id
            await @localLoaded
            if id == 'last'
              { id } = _.last @messages
            message = @tree.find parseInt id
            if message
              @routedMessage = message
            else
              log "Message ##{id} not found"
          if not @routedMessage
            await @localLoaded
            @getSuggestions()
      
      '$route.query.bookmark':
        immediate: true
        handler: (name) ->
          if name
            await @localLoaded
            message = _.find @messages, { bookmark: { name } }
            if message
              @routedMessage = message
            else
              log "Bookmark #{name} not found"
              @routedMessage = null

    }

</script>

<style>

  body {
    font-size: 0.75em;
  }

  /* Remove margin after last child of .message-content */
  .message-content *:last-child {
    margin-bottom: 0;
  }

  label {
    font-weight: bold;
  }

  .footer {
    /* position: sticky;
    bottom: 0;
    z-index: 1; */
    background-color: #f7f7f7;
    border-top: 1px solid #e7e7e7;
  }

  .header {
    /* position: sticky;
    top: 0;
    z-index: 1; */
    background-color: #f7f7f7;
    border-bottom: 1px solid #e7e7e7;
  }

</style>