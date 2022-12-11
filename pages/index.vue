<template lang="pug">
  b-container.p-5.vh-100(fluid)
    b-row

      b-col.p-0(
        style="height: calc(100vh - 200px);",
      )
        b-spinner(v-if="!messages")
        template(v-else)
        
          div.header.text-center.border-top.border-right.border-left
            h1.display-3(style="font-size: 2.5rem;") Mindy
            p.lede Someone you can talk to

          div#messages.border-right.border-left(
            style="height: calc(100vh - 400px); overflow-y: scroll;"
          )
            div.mt-2.p-2(
              v-for="(message, index) in thread", :key="index", 
              :style=`{
                'background-color': index % 2 ? '#f7f7f7' : '#fff',
                'border': message === routedMessage && message !== lastMessage ? '1px solid #ccc' : 'none',
                'cursor': message !== routedMessage && message.user.isBot ? 'pointer' : 'default',
              }`
              @click="message !== routedMessage && message.user.isBot && $router.push({ query: { id: message.id } })"
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
                    $router.push({ query: { id: tree.parent(message).id } })
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
                  b-button.mx-1(variant="outline-secondary", @click="sendMessage(tree.parent(message).content, tree.parent(message), true)", :disabled="sending || generatingReply")
                    | ↺ Try again
                  
                  //- Generate context
                  b-button.mx-1(variant="outline-primary", @click="generateContext(message)", :disabled="sending || generatingReply || generatingContext")
                    //- | 丫 Generate context
                    | 丫 {{ generatingContext ? 'Generating...' : message.context ? 'Rebuild mindmap' : 'Mindmap' }}

            div(ref="scrollToBottom", class="mt-2")

          div.footer.p-2.border-bottom.border-right.border-left

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
                  v-model="input"
                  placeholder="Enter to send, Shift+Enter for new line"
                  :disabled="!user || sending || generatingReply"
                  @keydown.enter.exact.prevent="if ( user && !!input && !sending && !generatingReply ) sendMessage()"
                )

              //- Submit button
              b-button(type="submit", :variant="sending ? 'outline-secondary' : 'primary'", :disabled="!input || sending || generatingReply")
                | {{ sending ? 'Sending...' : 'Send' }}
                b-spinner(v-if="sending", small)
    
      //- Context column
      b-col.col-xl-8.col-lg-7.col-md-6.col-sm-12.col-12
        div(:style={
          position: 'sticky',
          top: '0',
        })
          MindyContext(
            v-if="routedMessage && routedMessage.context",
            v-model="routedMessage.context",
          )
          b-spinner(
            v-else-if="generatingReply || generatingContext",
          )
          p(v-else, class="text-muted")
            | Start a conversation to see the context

    OpenAIKeyModal(v-model="openAIkey" ref="openAIkeyModal")

    //- Footer with various data displayed in a row from right to left
    div.footer.p-2.border-top.border-right.border-left.fixed-bottom
      //- OpenAI key (masked) + edit button
      div.float-right.text-right.text-muted.px-2(
        @click="$refs.openAIkeyModal.show()"
        style="cursor: pointer"
      ) {{ openAIkey ? `🔑 ${openAIkey.slice(0, 7)}...` : '🔑 No OpenAI key' }}
      //- USD spent, rounded to 2 decimal places; clear on click (after confirmation)
      div.float-right.text-right.text-muted.px-2(
        @click="() => { if ( window.confirm('Are you sure you want to clear the cost counter?') ) usdSpent = 0 }"
        style="cursor: not-allowed"
      )
        | 💸 ~${{ parseFloat(usdSpent).toFixed(2) }}

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

  import PolygonClient from '~/plugins/polygonClient'

  export default

    mixins: [
      syncLocal
        keys: [
          'user', 'messages', 'openAIkey', 'usdSpent'
        ]
        format: 'yaml'
      exposeVM
      tryAction
      windowMixin
    ]


    data: ->
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
        name: null
      }
      messages: []
      openAIkey: null
      typingCount: 0
      typingInterval: null
      usdSpent: 0
      bot:
        name: 'mindy'
        isBot: true
      idsBySlug: null
      previousThread: null

    computed:

      tree: ->
        new TreeLike(@messages)

      routedMessage: ->
        
        # Either message with the id from a query param or the last message
        { $route: { query: { id } } } = @
        message = if id?
          # convert to int
          id = parseInt(id)
          _.find @messages, { id }
        else
          _.last @messages
        
        # If the message is not from bot, user the first child (if any)
        if message?.user?.isBot or !@tree.children(message).length
          message
        else
          _.first @tree.children(message)
        

      thread: ->
        # If the existing thread includes the routed message, use that
        if @previousThread?.includes(@routedMessage)
          @previousThread
        else
          @previousThread = @tree.thread(@routedMessage or @tree.root)
      
      lastMessage: ->
        _.last(@thread)

      polygon: ->
        new PolygonClient({ @openAIkey, defaultParameters: { 
          max_tokens: 300 
          n: 3
        } })

    mounted: ->

      # Show OpenAI key modal if not set
      if !@openAIkey
        console.log "OpenAI key not set; showing modal"
        @$refs.openAIkeyModal.show()
      
    methods:

      addMessage: (message) ->
        @messages = [ @messages..., message ]
        message
      
      edit: (message) ->
        @editing.message = message
        @editing.input = message.content
    
      sendMessage: ( input = @input, parent = _.last(@thread) or @tree.root, retrying = false ) ->

        console.log {input, parent, retrying}

        idsBySlug = await @idsBySlug

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

        @try 'sending', =>

          if !retrying

            message = @addMessage @tree.createChild parent,
              user: @user
              content: input
            @input = ''
            @$router.push { query: { id: message.id } }

            # scroll to bottom
            @$nextTick =>
              @$refs.scrollToBottom.scrollIntoView()
        
          else
            message = parent

          console.log {message}

          @$nextTick =>

            @try 'generatingReply', ( =>

              { choices, approximateCost } = await @polygon.run slug, { input, previousConversation }
              @usdSpent += parseFloat(approximateCost)

              @input = ''
              
              console.log { message, choices }
              
              choices.forEach ({ text }) =>

                reply = @addMessage @tree.createChild message,
                  user: @bot
                  content: text
                
                console.log { reply }

              @$nextTick =>
                # Navigate to the last created message
                @$router.push { query: { id: _.last(@messages).id } }
                @$refs.scrollToBottom.scrollIntoView()
                @$nextTick =>
                  document.querySelector('#input')?.focus()

            ),
            catcher: (error) =>
              console.error error
              # Remove message (so that it isn't left unresponded to)
              @messages = _.without @messages, message
              input = message.content 

      getConversation: (message) ->

        # Map all messages before and including the message to a conversation
        @tree
          .lineage(message, includeSelf: true)
          .map(({ user: { isBot }, content }) -> "#{if isBot then 'Mindy' else 'User'}:\n#{content}")
          .join('\n\n')


      generateContext: (message) ->

        @try 'generatingContext', =>

          # Find the most recent message that has a context (it can be the message itself)
          log 'Previous message with context', 
          previousMessageWithContext = _.findLast @tree.lineage(message, includeSelf: true), (message) -> message.context

          if !previousMessageWithContext
            log 'No previous message with context, using current message', 
            previousMessageWithContext = message
            slug = 'context'
          else
            previousContext = previousMessageWithContext.context
            slug = 'context-rebuild'

          log { slug }

          contextExists = !!previousMessageWithContext.context

          log "Conversation before #{if contextExists then 'previous context' else 'current message'}",
          conversationBeforePreviousContext = @getConversation previousMessageWithContext
          

          if contextExists

            log 'Messages after previous context',
            messagesAfterPreviousContext = @tree
              .lineage(message, includeSelf: true)
              .slice @tree.lineage(previousMessageWithContext, includeSelf: true).length

            log 'Conversation after previous context', 
            conversationAfterPreviousContext = @getConversation previousMessageWithContext

          { choices: [{ text }], approximateCost } = await @polygon.run slug, {
            conversationBeforePreviousContext,
            previousContext,
            conversationAfterPreviousContext,
          }

          @usdSpent += parseFloat(approximateCost)

          getIndent = ( line, tabSize = 2) => ( line.length - line.trimLeft().length ) / tabSize
          postProcessContext = (value) ->

            value = value.replace? /```[\s\S]*?/, ''
            value = value.trim()
            lines = value.trim().split '\n'

            # Take the tab size from the second line
            tabSize = getIndent lines[1], 1

            # Make the indent of two spaces
            lines = lines.map (line) ->
              indent = getIndent line, tabSize
              line.replace /^\s*/, '  '.repeat indent
            
            lines.join '\n'

          @$set message, 'context', postProcessContext(text)
          
      
      cloneAndSend: () ->

        try
          @sendMessage( @editing.input, @tree.parent(@editing.message) )
        finally
          @editing.message = null

    watch:

      generatingReply: (generatingReply) ->

        clearInterval @typingInterval
        if generatingReply
          # Scroll to bottom
          @$nextTick =>
            @$refs.scrollToBottom.scrollIntoView()
          @typingInterval = setInterval =>
            @typingCount = ( @typingCount + 1 ) % 3
          , 500
        else
          @typingCount = 0
      
      '$route.query.id':
        immediate: true
        handler: (id) ->
          console.log {id}

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