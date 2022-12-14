<template lang="pug">
  DarkMode(
    v-if="darkmode"
    v-bind="{ polygon, context }"
    :usdSpent.sync="usdSpent"
    @wheres-the-fucking-light-switch=`
      darkmode = false
      mixpanel.track('Dark mode off')
    `
  )
  div(v-else)
    b-container.p-5.vh-100(fluid)
      b-row(
        align-v="center"
        style="height: calc(100vh - 50px);"
      )    
        //- Chatbox
        //- If `chatboxCollapsed` is `false`, the chatbox is pinned to the left of the screen
        //- If `chatboxCollapsed` is `true`, it becomes smaller and floats in the top left corner with a shadow, allowing the user to interact with the mindmap
        b-col.p-0(
          :style=`chatboxCollapsed ? {
            position: 'fixed',
            [chatboxVerticalAnchor]: chatboxVerticalAnchor === 'top' ? '10px' : '60px',
            [chatboxHorizontalAnchor]: '10px',
            width: '64px',
            boxShadow: '0 0 10px 0 rgba(0, 0, 0, 0.5)',
            zIndex: 1000,
          } : {
            height: 'calc(100vh - 50px)',
          }`
          )
          b-spinner(v-if="!messages")
          template(v-else)
          
            div.header.text-center.border-top.border-right.border-left(
              @click="toggleChatboxCollapsed"
              style="cursor: pointer"
            )
              div(
                v-if="!chatboxCollapsed"
              )
                h1.mb-0.display-3(style="font-size: 3rem;") Mindy
                p.lead(style="font-size: 1rem;") Brainstorm with AI
              template(v-else)
                //- //- Switch to change chatbox anchor position
                //- span.text-muted(
                //-   variant="light"
                //-   size="sm"
                //-   @click="rotateChatboxAnchor"
                //-   style="cursor: pointer; position: absolute; top: 0px; right: 10px;"
                //- ) ✢
                
                p.mt-3.lead(style="font-size: 1rem; cursor: pointer;") 💬
            div#messages.border-right.border-left(
              v-if="!chatboxCollapsed"
              :style=`{
                height: chatboxCollapsed ? '150px' : 'calc(100vh - 400px)',
                overflowY: 'scroll',
                fontSize: chatboxCollapsed ? '0.75em' : '1em',
              }`
              )
              div.pt-4.p-2(
                v-for="(message, index) in thread", :key="index", 
                :style=`{
                  'background-color': index % 2 ? '#f7f7f7' : '#fff',
                  'border': message === routedMessage && message !== lastMessage ? '1px solid #ccc' : 'none',
                  'cursor': message !== routedMessage && message.user.isBot ? 'pointer' : 'default',
                }`
                @click="() => { if ( message !== routedMessage && message.user.isBot ) routedMessage = message }"
              )

                template(v-if="message.special")
                  em
                    strong {{ message.user.name }} {{ message.content }}

                //- If the message has siblings, display a switcher looking like "< n / N >" where n is the current sibling index and N is the total number of siblings
                //- Clicking "<" / ">" will switch the current message to the previous / next sibling respectively
                template( v-if="tree.numSiblings(message) > 1")
                  div(style="font-size: 0.8em; color: #aaa; float: right;")
                    //- Switching is done by changing 'id' in the URL query string
                    nuxt-link(:to="{ query: { id: tree.sibling(message, -1).id } }", class="mr-1", style="color: inherit",
                      v-text="`< ${tree.siblingIndex(message) + 1}`"
                    )
                    | /
                    nuxt-link(:to="{ query: { id: tree.sibling(message, 1).id } }", class="ml-1", style="color: inherit",
                      v-text="`${tree.numSiblings(message)} >`"
                    )
                  
                template(v-if="message.user.name === user.name && !editing.message")
                  a(style="font-size: 0.8em; color: #aaa; float: right; cursor: pointer;",
                    :class=`{
                      'mr-1': tree.numSiblings(message) > 1
                    }`,
                    @click="edit(message)"
                    v-text="`🖉`"
                  )

                div(v-text="message.user.name", :class="{ 'text-primary': user && message.user.name === user.name }", :style="{ fontWeight: 'bold' }")

                //- If not editing, display the message content. On double-click, start editing
                div(v-if="editing.message !== message", v-html="$md.render(message.content)", @dblclick="edit(message)")

                div(v-else)
                  //- Send on Enter -- only if this not a bot message, -- cancel on escape 
                  b-textarea(rows="3", max-rows="10",
                    v-model="editing.input",
                    @keydown.enter.exact.prevent="() => { if ( !message.user.isBot ) { cloneAndSend() } }",
                    @keydown.esc="editing.message = null"
                  )
                  //- Save & submit -- if not a bot message
                  b-button.m-1(size="sm", variant="primary"
                    v-if="!message.user.isBot"
                    @click="cloneAndSend"
                  )
                    | Save &amp; submit
                  //- Just save (to edit the message text but not send it)
                  b-button.m-1(size="sm"
                    :variant="message.user.isBot ? 'primary' : 'outline-secondary'"
                    @click="message.content = editing.input; editing.message = null"
                  )
                    | {{ message.user.isBot ? 'Save' : 'Just save' }}
                  //- Cancel
                  b-button(variant="outline-secondary", size="sm", @click="editing.message = null", class="m-1")
                    | Cancel
                  //- Delete (danger, alert, confirm)
                  b-button(variant="outline-danger", size="sm", @click=`
                    if ( window.confirm('Are you sure you want to delete this message and all of its further replies? THERE IS NO UNDO!') ) {
                      messages = tree.delete(message)
                      routedMessage = tree.parent(message)
                      editing.message = null
                    }
                  `, class="m-1")
                    | Delete

                template(v-if="message === routedMessage")

                  div.p-2(v-if="generatingReply", class="text-muted")
                    em mindy is thinking{{ '.'.repeat(typingCount + 1) }}

                  //- Buttons with various message actions
                  div.p-2.text-center(v-if="message.user.isBot")

                    //- Try again
                    b-button.mx-1(
                      variant="outline-secondary", @click="sendMessage(tree.parent(message).content, tree.parent(message), true)", :disabled="sending || generatingReply"
                      :size="chatboxCollapsed ? 'sm' : 'md'"
                    )
                      | ↺ Try again
                    
                    //- Float-right thumbs-up button, grayscaled if not upvoted
                    b-button.mx-1.float-right(
                      @click="upvote(message)"
                      variant="light"
                      :size="chatboxCollapsed ? 'sm' : 'md'"
                      :style="!message.upvoted ? { 'filter': 'grayscale(100%)' } : {}"
                    )
                      | 👍
                    //- Fine-tuning request modal
                    b-modal#fine-tuning-request-modal(
                      title="Can we fine-tune Mindy based on your upvotes?"
                      hide-footer centered
                      )
                      p
                        strong If you upvote a reply, we will send it to our servers and “train” Mindy to generate more replies like this one.&nbsp;
                        | This will also include the entire conversation thread, so that Mindy can understand the context.
                      p In the long run, we hope this will help Mindy generate better replies, and make you a happier user, too.
                      p So we will be grateful if you keep this switch on. :&#41;
                      p
                        | (You can always turn this off in the settings.)
                      b-checkbox.my-4(
                        v-model="settings.allowFineTuning"
                        switch
                      ) {{ settings.allowFineTuning ? 'Yes, ' : 'No, don’t ' }}send my upvotes to your servers to make Mindy better.
                      p Now let’s upvote that message!
                      b-button(variant="primary", size="lg"
                        @click="upvote(message); $bvModal.hide('fine-tuning-request-modal')"
                      )
                        | 👍 {{ settings.allowFineTuning ? 'Upvote and send to servers' : 'Just upvote' }}

              div#scrollToBottom(ref="scrollToBottom")

            div.footer.p-2.border-bottom.border-right.border-left(
              v-if="!chatboxCollapsed"
              )

              template(v-if="!user.name")
                b-form-group(label="Name", label-for="username")
                  b-form-input(
                    id="username",
                    :value="enteredName",
                    @input="enteredName = $event.toLowerCase().replace(/[^a-z0-9-]+/g, '-').replace(/-+/g, '-')",
                    @change="user.name = enteredName",
                    placeholder="Enter your name to start chatting"
                  )
                
              //- Message input & buttons
              b-form(
                @submit.prevent="sendMessage()", class="mb-0"
              )
                b-form-group(:label="user && user.name", label-for="input")
                  b-textarea#input(
                    ref="input"
                    v-model="input"
                    placeholder="Enter to send, Shift+Enter for new line"
                    :disabled="!user || sending || generatingReply"
                    @keydown.enter.exact.prevent="if ( user && !!input && !sending && !generatingReply ) sendMessage()"
                  )

                //- Send button
                b-button(type="submit", :variant="sending ? 'outline-secondary' : 'primary'", :disabled="!input || sending || generatingReply")
                  | {{ sending ? 'Sending...' : 'Send' }}
                  b-spinner(v-if="sending", small)
              
      
        //- Context column
        //- b-col.col-xl-8.col-lg-7.col-sm-6
        b-col(
          :class="chatboxCollapsed ? 'col-12' : 'col-md-8 col-sm-10 col-12'"
          )
          b-row.justify-content-center.text-center
            template(v-if="routedMessage")
              MindyContext(
                v-show="!!routedMessage.context && !generatingContext"
                :key="routedMessage.id"
                v-model="routedMessage.context"
                @rebuild="generateContext(routedMessage)"
              )
              //- Generate context
              b-button.mx-1(
                v-if="!routedMessage.context"
                @click="generateContext(routedMessage)"
                :disabled="sending || generatingReply || generatingContext"
                :variant="generatingReply || generatingContext ? 'light' : 'outline-primary'"
              )
                //- | 丫 Generate context
                | 丫 {{ generatingContext ? 'Building mindmap...' : generatingReply && settings.autoBuildContext ? 'A little patience...' : 'Build mindmap' }}
            div.lead(v-else)
              p Ask Mindy a question, and watch the magic unfold!


      OpenAIKeyModal(v-model="openAIkey" ref="openAIkeyModal")

      //- Footer with various data displayed in a row from right to left
      div.footer.p-2.border-top.border-right.border-left.fixed-bottom
        //- Buy me a beer link
        div.float-right.text-right.text-muted.px-2
          a(
            href="https://vzakharov.github.io/buy-me-a-beer/", target="_blank"
            style="text-decoration: none"
            @click="mixpanel.track('Cheers! 🍺')"
            title="Buy me a beer!"
          ) 🍺
        //- Dark mode switch (place always in top right corner)
        div.float-right.text-right.text-muted.px-2(
          @click=`
            mixpanel.track('Dark mode on')
            darkmode = true
          `
          style="cursor: pointer; position: fixed; top: 5px; right: 5px; z-index: 9999"
          title="Dark mode"
        ) ☾

        //- OpenAI key (masked) + edit button
        div.float-right.text-right.text-muted.px-2(
          @click="$refs.openAIkeyModal.show()"
          style="cursor: pointer"
          title="Change OpenAI key"
        ) {{ openAIkey ? `🔑 sk-...${openAIkey.slice(-4)}` : '🔑 No OpenAI key' }}

        //- USD spent, rounded to 2 decimal places; clear on click (after confirmation)
        div.float-right.text-right.text-muted.px-2(
          @click="() => { if ( window.confirm('Are you sure you want to clear the cost counter?') ) usdSpent = 0 }"
          style="cursor: not-allowed"
          title="Approximate USD spent on OpenAI API calls. Click to clear."
        )
          | 💸 ~${{ parseFloat(usdSpent).toFixed(2) }}
          
        //- Settings buttons
        //- Auto-build context
        span.float-left.text-right.px-2(
          :class="settings.autoBuildContext ? 'text-success' : 'text-muted'"
          @click="settings.autoBuildContext = !settings.autoBuildContext"
          style="cursor: pointer"
          :title="`Auto-build mindmap is ${settings.autoBuildContext ? 'on' : 'off'}`"
        ) 丫
        //- Number of replies
        span.float-left.text-right.text-muted.px-2(
          @click="settings.numGenerations = ( settings.numGenerations % 3 ) + 1"
          style="cursor: pointer"
          :title="`Mindy will generate ${settings.numGenerations} ${settings.numGenerations === 1 ? 'reply' : 'replies'} at once`"
        ) 💬 × {{ settings.numGenerations }}
        //- Temperature
        span.float-left.text-right.text-muted.px-2(
          @click="settings.temperature = Math.floor(( settings.temperature + 0.2 ) * 10) / 10 % 1.2"
          style="cursor: pointer"
          :title="`Mindy will generate replies with a temperature (i.e. “creativity”) of ${ settings.temperature }`"
        ) 
          | {{ settings.temperature == 0 ? '🥱' : settings.temperature <= 0.2 ? '😐': settings.temperature <= 0.4 ? '🤔' : settings.temperature <= 0.6 ? '😉' : settings.temperature <= 0.8 ? '😜' : '🤪' }}
          | t={{ Math.round(settings.temperature * 10) / 10 }}
        //- Settings modal
        div.float-left.text-right.text-muted.px-2(
          @click="$bvModal.show('settings-modal')"
          style="cursor: pointer"
          title="Edit settings"
        ) ...
        b-modal#settings-modal(
          title="Settings"
          hide-footer hide-header centered
          )
          EditSettings(
            v-model="settings"
            :properties=`{
              autoBuildContext: {
                label: 'Auto-build mindmap',
                description: {
                  true: 'Mindy will automatically build a mindmap whenever you navigate to a reply.',
                  false: 'You will have to click the "Mindmap" button to build a mindmap.',
                }
              },
              numGenerations: {
                label: 'Number of replies at once',
                description: 'How many replies to generate at once. Increasing this helps explore more options, but also costs more.'
              },
              temperature: {
                label: 'Temperature',
                description: 'How creative to be. 0 gives deterministic (same) replies, 1 gets... weird. Note that for 0 the number of replies is always 1.'
              },
              allowFineTuning: {
                label: 'Allow fine-tuning',
                description: {
                  true: 'Mindy will be sending your upvoted replies to our servers to fine-tune her. This helps her generate better replies, and makes you a happier user, too.',
                  false: 'Mindy will not be sending your upvoted replies to our servers.',
                }
              },
            }`
          )

          
</template>

<script lang="coffee">

  import axios from 'axios'
  import _ from 'lodash'
  import QRCode from 'qrcode'

  import TreeLike from '~/plugins/treeLike'
  import log from '~/plugins/log'

  import syncLocal from '~/plugins/syncLocal'
  import exposeVM from '~/plugins/exposeVM'
  import tryAction from '~/plugins/tryAction'
  import windowMixin from '~/plugins/mixins/window'
  import mixpanelMixin from '~/plugins/mixins/mixpanel'

  import PolygonClient from '~/plugins/polygonClient'

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
    ]

    head: ->

      title: if @routedMessage then "#{@routedMessage.content} · Mindy" else 'Mindy · Brainstorm with AI'

      meta:
        name: 'viewport'
        content: 'width=device-width, initial-scale=1, user-scalable=no'

    data: ->
      fineTuningRequested: false
      chatboxCollapsed: false
      chatboxVerticalAnchor: 'top'
      chatboxHorizontalAnchor: 'left'
      darkmode: false
      settings:
        allowFineTuning: true
        autoBuildContext: true
        numGenerations: 3
        temperature: 0.6
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

      context: ->
        # Take the first line of the context, if any
        @routedMessage?.context

      tree: ->
        new TreeLike(@messages)

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
        new PolygonClient({ @openAIkey, defaultParameters: { 
          max_tokens: 300 
          n: @settings.numGenerations
          temperature: @settings.temperature
        } })

    mounted: ->

      # If window width is less than 768px, collapse chatbox

      @mixpanel.track 'Started'

      # Show OpenAI key modal if not set
      if !@openAIkey
        console.log "OpenAI key not set; showing modal"
        @$refs.openAIkeyModal.show()
      else
        @$refs.input.focus()

    methods:

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

                  { choices, approximateCost, generationId } = await @polygon.run slug, { input, previousConversation }, {
                    stop: 'User:'
                    n: if @settings.temperature > 0 then @settings.numGenerations else 1
                  }
                  @usdSpent += parseFloat(approximateCost)

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
              mutation.target.focus()
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
            log 'Previous message with context', 
            previousMessageWithContext = _.findLast @tree.lineage(message, includeSelf: false), (message) -> message.context

            contextExists = !!previousMessageWithContext

            slug = if contextExists then 'context-rebuild' else 'context'

            log { slug }

            log "Conversation before #{if contextExists then 'previous context' else 'current message'}",
            conversationBeforePreviousContext = @getConversation previousMessageWithContext or message

            if contextExists

              previousContext = previousMessageWithContext.context

              log 'Messages after previous context',
              messagesAfterPreviousContext = @tree\
                .lineage(message, includeSelf: true)\
                .slice @tree.lineage(previousMessageWithContext, includeSelf: true).length

              log 'Conversation after previous context', 
              conversationAfterPreviousContext = @getConversation messagesAfterPreviousContext

            { choices: [{ text }], approximateCost } = await @polygon.run slug, {
              conversationBeforePreviousContext,
              previousContext,
              conversationAfterPreviousContext,
            }, {
              stop: '```'
              temperature: 0.5
            }

            @usdSpent += parseFloat(approximateCost)

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

    watch:

      'settings.allowFineTuning': (allowFineTuning) ->
        if allowFineTuning
          @mixpanel.track 'Fine tuning enabled'
        else
          @mixpanel.track 'Fine tuning disabled'
      
      'settings.autoBuildContext': (autoBuildContext) ->
        if autoBuildContext
          @mixpanel.track 'Auto context enabled'
        else
          @mixpanel.track 'Auto context disabled'
      
      'settings.temperature': (temperature) ->
        @mixpanel.track 'Temperature changed', { temperature }

      'settings.numGenerations': (numGenerations) ->
        @mixpanel.track 'Num generations changed', { numGenerations }

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
        flush: 'post'
        if message
          { id } = message
          if id == parseInt @$route.query.id
            return
          log "Routing to message ##{id}"
          @$router.push { query: { id: message.id } }
      
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
              @routedMessage = null
          else
            @routedMessage = null

      usdSpent: ( usdSpent, oldUsdSpent ) ->
        if oldUsdSpent
        # (Making sure it's not just initializing the value from localStorage)
          @mixpanel.track 'USD spent',
            total: usdSpent
            delta: usdSpent - oldUsdSpent

</script>

<style>

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