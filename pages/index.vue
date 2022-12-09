<template lang="pug">
  b-container.pt-5
    b-row
      b-col.border.p-0(style="max-width: 800px; margin: 0 auto;")
        b-spinner(v-if="!messages")
        template(v-else)
          div.header.p-3.text-center
            h1.display-3 Mindy
            p.lede Someone you can talk to

          div

            div.mt-2.p-2(v-for="(message, index) in thread", :key="index", :style=`{
              'background-color': index % 2 ? '#f7f7f7' : '#fff',
            }`)

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
                    //- Add right border if there are siblings
                    'mr-1': tree.numSiblings(message) > 1
                  }`,
                  @click="edit(message)"
                  v-text="`🖉`"
                )

              template
                div(v-text="message.user.name", :class="{ 'text-primary': user && message.user.name === user.name }", :style="{ fontWeight: 'bold' }")

                //- If not editing, display the message content. On double-click, start editing
                div(v-if="editing.message !== message", v-html="$md.render(message.content)", @dblclick="edit(message)")

                div(v-else)
                  //- Send on shift+enter, cancel on escape
                  b-form-textarea(rows="3", max-rows="10",
                    v-model="editing.input",
                    @keydown.shift.enter="cloneAndSend",
                    @keydown.esc="editing.message = null"
                  )
                  //- Save & submit
                  b-button(variant="primary", size="sm", @click="cloneAndSend", class="m-1")
                    | Save &amp; submit
                  //- Just save (to edit the message text but not send it)
                  b-button(variant="outline-secondary", size="sm", @click="message.content = editing.input; editing.message = null", class="m-1")
                    | Just save
                  //- Cancel
                  b-button(variant="outline-secondary", size="sm", @click="editing.message = null", class="m-1")
                    | Cancel

            div.p-2(v-if="generatingReply", class="text-muted")
              em mindy is thinking{{ '.'.repeat(typingCount + 1) }}

            //- If the last message is from the bot, display a centered 'Try again' button
            div.p-2.text-center(v-if="lastMessage && lastMessage.user.isBot")
              b-button(variant="outline-secondary", @click="sendMessage(tree.parent(lastMessage).content, tree.parent(lastMessage), true)", :disabled="sending || generatingReply")
                | ↺ Try again

            div(ref="scrollToBottom", class="mt-2")

          div(class="footer p-3")

            template(v-if="!user.name")
              b-form-group(label="Name", label-for="username")
                b-form-input(
                  id="username",
                  :value="enteredName",
                  @input="enteredName = $event.toLowerCase().replace(/[^a-z0-9-]+/g, '-').replace(/-+/g, '-')",
                  @change="user.name = enteredName",
                  placeholder="Enter your name to start chatting"
                )
              
            b-form(@submit.prevent="sendMessage()", class="mb-0")
              b-form-group(:label="user && user.name", label-for="input")
                b-form-input(id="input", v-model="input", placeholder="Enter your message", :disabled="!user || sending || generatingReply")
              b-button(type="submit", :variant="sending ? 'outline-secondary' : 'primary'", :disabled="!input || sending || generatingReply")
                | {{ sending ? 'Sending...' : 'Send' }}
                b-spinner(v-if="sending", small)
    
      //- Context column
      b-col.col-7(
        v-if="lastMessage && lastMessage.context",
      )
        MindyContext(
          v-model="lastMessage.context",
        )

    OpenAIKeyModal(v-model="openAIkey" ref="openAIkeyModal")

</template>

<script lang="coffee">

  import axios from 'axios'
  import _ from 'lodash'
  import QRCode from 'qrcode'

  import syncLocal from '~/plugins/syncLocal'
  import TreeLike from '~/plugins/treeLike'
  import exposeVM from '~/plugins/exposeVM'
  import tryAction from '~/plugins/tryAction'

  import PolygonClient from '~/plugins/polygonClient'

  export default

    mixins: [
      syncLocal
        keys: [
          'user', 'messages', 'openAIkey'
        ]
        format: 'yaml'
      exposeVM
      tryAction
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
      bot:
        name: 'mindy'
        isBot: true
      idsBySlug: null

    computed:

      tree: ->
        new TreeLike(@messages)

      routedMessage: ->
        
        # Either message with the id from a query param or the last message
        { $route: { query: { id } } } = @
        if id?
          # convert to int
          id = parseInt(id)
          _.find @messages, { id }
        else
          _.last @messages
        

      thread: ->
        @tree.thread(@routedMessage or @tree.root)
      
      lastMessage: ->
        _.last(@thread)

      polygon: ->
        new PolygonClient({ @openAIkey, defaultParameters: { max_tokens: 300 } })

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
          slug = 'continued'

          # Also combine all the previous messages in the thread as `previousConversation`, in the format "user1:\nmessage1\n\nuser2:\nmessage2\n\n..."
          previousConversation = @tree
            .lineage(
              parent, !retrying
            )
            .map(({ user: { isBot }, content }) -> "#{if isBot then 'Mindy' else 'User'}:\n#{content}")
            .join('\n\n')

          console.log {previousConversation}

        else
          slug = 'first'

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

            @try 'generatingReply', =>

              { choices } = await @polygon.run slug, { input, previousConversation }

              @input = ''
              
              console.log { message, choices }
              
              choices.forEach ({ text }) =>

                reply = @addMessage @tree.createChild message,
                  user: @bot
                  content: text
                
                console.log { reply }

                # Generate the context
                @try 'generatingContext', =>
                  { choices: [{ text }] } = await @polygon.run "context-#{slug}", { input, previousConversation, reply: text }
                  @$set reply, 'context', text

              @$nextTick =>
                # Navigate to the last created message
                @$router.push { query: { id: _.last(@messages).id } }
                @$refs.scrollToBottom.scrollIntoView()
                document.querySelector('#input').focus()

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
    position: sticky;
    bottom: 0;
    z-index: 1;
    background-color: #f7f7f7;
    border-top: 1px solid #e7e7e7;
  }

  .header {
    position: sticky;
    top: 0;
    z-index: 1;
    background-color: #f7f7f7;
    border-bottom: 1px solid #e7e7e7;
  }

</style>