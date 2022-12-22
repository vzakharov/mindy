<template lang="pug">
  DarkMode(
    v-if="darkmode"
    v-bind="{ polygon, context }"
    @wheres-the-fucking-light-switch="turnOffDarkmode"
  )
  div(v-else)
    b-container.px-4(
        fluid
      )
      b-row(
        align-v="center"
        style="height: calc(100vh - 80px);"
      )    
        //- Fixed small shadow div if chatbox collapsed
        div.m-1.p-2.shadow-sm.rounded-lg(
          v-if="chatboxCollapsed"
          @click="toggleChatboxCollapsed"
          style="font-size: 1em; cursor: pointer; position: absolute; top: 10px; left: 10px; z-index: 1000; background-color: rgba(0, 0, 0, 0.1)"
        ) 💬
        //- Chatbox
        b-col.pt-4(
          v-else
          :style=`chatboxCollapsed ? {
            position: 'fixed',
            [chatboxVerticalAnchor]: chatboxVerticalAnchor === 'top' ? '10px' : '60px',
            [chatboxHorizontalAnchor]: '10px',
            width: '64px',
            boxShadow: '0 0 10px 0 rgba(0, 0, 0, 0.5)',
            zIndex: 1000,
          } : {
            height: wide ? 'calc(100vh - 50px)' : '55vh',
          }`
          )
          b-spinner(v-if="!messages")
          template(v-else)
            div.header.text-center.border-top.border-right.border-left
              div.px-2.float-right.text-muted(
                @click="toggleChatboxCollapsed"
                style="cursor: pointer; position: absolute; top: 25px; left: 15px; z-index: 1000; font-size: 1.5em;"
              ) ⤣
              div(v-if="wide")
                //- Fixed (top left) glyph to collapse the chatbox
                h1.mb-0.display-3(style="font-size: 3em;") Mindy
                p.lead(style="font-size: 1em;") Brainstorm with AI
              div.lead(
                v-else
                style="font-size: 1.5em;"
                ) Mindy · Brainstorm with AI
            div#messages.border-right.border-left(
              v-if="!chatboxCollapsed"
              :style=`{
                height: wide ? 'calc(100vh - 300px)' : 'calc(55vh - 170px)',
                overflowY: 'scroll',
              }`
              )
              div.message.p-2(
                :id="`message-${message.id}`"
                :ref="`message-${message.id}`"
                v-for="(message, index) in thread", :key="index", 
                :style=`{
                  'background-color': index % 2 ? '#f7f7f7' : '#fff',
                  'border': message === routedMessage && message !== lastMessage ? '1px solid #ccc' : 'none',
                  'cursor': message !== routedMessage && message.user.isBot ? 'pointer' : 'default',
                }`
                @click="routedMessage = message"
              )
                //- @mouseover="hoveredMessage = message"

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
                div.message-content(
                  v-if="editing.message !== message", v-html="$md.render(message.content)", @dblclick="edit(message)"
                )

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

                //- Buttons with various messagem shown either if this is the routed message, if it has bookmarks, or if the user hovers over it
                b-row.pt-2(
                  v-if="message === routedMessage || message.bookmark || hoveredMessage === message",
                  align-h="between"
                )

                  b-col
                    //- Try again
                    b-button(
                      v-if="message.user.isBot"
                      variant="outline-secondary", @click="sendMessage(tree.parent(message).content, tree.parent(message), true)", :disabled="sending || generatingReply"
                      size="sm"
                      style="font-size: 0.8em;"
                    )
                      | ↺ Try again
                  
                  //- Right-aligned div for additional buttons
                  b-col.text-right
                    
                    //- Thumbs-up button, grayscaled if not upvoted
                    b-button.mx-1(
                      v-if="message.user.isBot"
                      @click="upvote(message)"
                      variant="light"
                      size="sm"
                      :style="!message.upvoted ? { 'filter': 'grayscale(100%)' } : {}"
                    )
                      | 👍
                    
                    //- Bookmark button
                    b-button.mx-1(
                      @click="bookmark(message)"
                      variant="light"
                      size="sm"
                      :style="message.bookmark ? { cursor: 'not-allowed'} : { filter: 'grayscale(100%)' }"
                    )
                      | 🔖
                      span.text-muted(
                        v-if="message.bookmark && message.bookmark.name"
                        v-text="message.bookmark.name"
                      )


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
            //- 
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
                id="messageInputForm"
                @submit.prevent="sendMessage()", class="mb-0"
              )
                b-form-group(:label="user && user.name", label-for="input")
                  b-textarea#input(
                    ref="input"
                    v-model="input"
                    placeholder="Enter to send, Shift+Enter for new line"
                    :disabled="!user || sending || generatingReply"
                    @keydown.enter.exact.prevent="if ( user && !!input && !sending && !generatingReply ) sendMessage()"
                    style="font-size: 1em;"
                  )

                //- Send button
                b-button(
                  id="sendButton"
                  type="submit"
                  :variant="sending ? 'outline-secondary' : 'primary'"
                  :disabled="!input || sending || generatingReply"
                  size="sm"
                )
                  | {{ sending ? 'Sending...' : 'Send' }}
                  b-spinner(v-if="sending", small)
              

        //- Context column
        b-col.px-4(
          :class="chatboxCollapsed ? 'col-12' : 'col-lg-8 col-md-7 col-sm-12 col-12'"
          )
          template(
            v-if="routedMessage || messageForContext"
            )
            b-row.justify-content-center.text-center(
              v-if="messageForContext"
              :style="narrow && 'height: calc(45vh - 50px)'"
              align-v="center"
            )
              MindyContext(
                v-if="messageForContext.context"
                :key="messageForContext.id"
                :readonly="routedMessage !== messageForContext || generating"
                v-model="messageForContext.context"
                @rebuild="generateContext(messageForContext)"
                @node-clicked="input = $event; $nextTick(sendMessage)"
                :style=`{
                  filter: routedMessage && routedMessage !== messageForContext || generating ? 'grayscale(25%) opacity(0.75)' : 'none',
                }`
              )
            b-row.justify-content-center.mt-2
              //- Generate context
              b-button.mx-1(
                v-if="routedMessage && !routedMessage.context && routedMessage.user.isBot",
                @click="generateContext(routedMessage)"
                :disabled="sending || generating"
                :variant="generating ? 'light' : 'outline-primary'"
              )
                //- | 丫 Generate context
                | 丫 {{ generatingContext ? 'Building mindmap...' : generatingReply && settings.autoBuildContext ? 'A little patience...' : 'Build mindmap' }}
              //- Jump to the message with context or add more suggestions
              b-button.mx-1(
                v-if="messageForContext && messageForContext.id && routedMessage !== messageForContext && !generating",
                variant="light"
                size="sm"
                :to="{ query: { id: messageForContext.id } }"
                style="text-decoration: none; color: inherit; font-size: 1.2em"
                title="Go to message for this mindmap"
                )
                | {{ tree.lineage(messageForContext).includes(routedMessage) ? '»' : '«' }}

          b-row.text-muted(v-else, align-h="center", justify="center")
            b-spinner.text-muted(type="grow")
            p.mx-2.lead Unwrapping the 🪄...


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
          @click="() => { if ( window.confirm('Are you sure you want to clear the cost counter?') ) polygon.spent = 0 }"
          style="cursor: not-allowed"
          title="Approximate USD spent on OpenAI API calls. Click to clear."
        )
          | 💸 ~${{ parseFloat(polygon.spent).toFixed(2) }}
          
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

  import syncLocal from '~/plugins/mixins/syncLocal'
  import exposeVM from '~/plugins/exposeVM'
  import tryAction from '~/plugins/mixins/tryAction'
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
              messagesAfterPreviousContext = @tree.lineage(message, includeSelf: true,  breakAt: previousMessageWithContext)

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
          if !@syncLocal.ignoreWatchers?.includes 'settings'
            @mixpanel.track {
              allowFineTuning: if value then 'Fine tuning enabled' else 'Fine tuning disabled'
              autoBuildContext: if value then 'Auto context enabled' else 'Auto context disabled'
              temperature: 'Temperature changed'
              numGenerations: 'Num generations changed'
            }[key], if !_.isBoolean value then { [key]: value } else undefined

      usdSpent: ( usdSpent, oldUsdSpent ) ->
        if !@syncLocal.ignoreWatchers?.includes 'usdSpent'
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
            await @syncLocal.promise
            if id == 'last'
              { id } = _.last @messages
            message = @tree.find parseInt id
            if message
              @routedMessage = message
            else
              log "Message ##{id} not found"
          if not @routedMessage
            await @syncLocal.promise
            @getSuggestions()
      
      '$route.query.bookmark':
        immediate: true
        handler: (name) ->
          if name
            await @syncLocal.promise
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