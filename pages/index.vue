<template lang="pug">
  b-container
    b-row
      b-col(class="border p-0")
        b-spinner(v-if="!messages")
        template(v-else)
          div(class="header p-3")
            h1 Chat

          div

            div(v-for="(message, index) in thread", :key="index", class="mt-2 p-2", :style=`{
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
                  @click="edit(message)"
                  v-text="`🖉`"
                )

              template
                div(v-text="message.user.name", :class="{ 'text-primary': user && message.user.name === user.name }", :style="{ fontWeight: 'bold' }")

                //- If not editing, display the message content. On double-click, start editing
                div(v-if="editing.message !== message", v-html="$md.render(message.content)", @dblclick="edit(message)")

                div(v-else)
                  b-form-textarea(v-model="editing.input", rows="3", max-rows="10")
                  b-button(variant="primary", size="sm", @click="resendMessage", class="m-1")
                    | Save &amp; submit
                  b-button(variant="secondary", size="sm", @click="editing.message = null", class="m-1")
                    | Cancel
              
                
            div(v-if="generatingReply", class="mt-2 text-muted")
              em mindy is typing{{ '.'.repeat(typingCount + 1) }}
            div(id="scroll-to-bottom", class="mt-2")

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
              
            b-form(@submit.prevent="sendMessage", class="mb-0")
              b-form-group(:label="user && user.name", label-for="input")
                b-form-input(id="input", v-model="input", placeholder="Enter your message", :disabled="!user || sending")
              b-button(type="submit", :variant="sending ? 'outline-secondary' : 'primary'", :disabled="!input || sending")
                | {{ sending ? 'Sending...' : 'Send' }}
                b-spinner(v-if="sending", small)
                
</template>

<script lang="coffee">

  import axios from 'axios'
  import _ from 'lodash'
  import syncLocal from '~/plugins/syncLocal.coffee'
  import QRCode from 'qrcode'
  import TreeLike from '~/plugins/treeLike.coffee'

  polygon = axios.create
    baseURL: process.env.POLYGON_API_URL

  export default


    data: ->
      input: ''
      lastMessageTime: null
      sending: false
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
      typingCount: 0
      typingInterval: null
      bot:
        name: 'mindy'
        isBot: true
      idsBySlug: null

    mixins: [
      syncLocal keys: [
        'user', 'messages'
      ]
    ]

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
        if @routedMessage then @tree.thread(@routedMessage) else []
      
    mounted: ->
      
      @idsBySlug = new Promise (resolve, reject) =>

        { NOTION_PROMPTS_DB_ID } = process.env

        polygon.get("/prompt-ids/#{NOTION_PROMPTS_DB_ID}")
          .then ({ data }) -> resolve data
          .catch reject

    methods:

      addMessage: (message) ->
        @messages = [ @messages..., message ]
        message
      
      edit: (message) ->
        @editing.message = message
        @editing.input = message.content
    
      sendMessage: ->

        idsBySlug = await @idsBySlug

        # Use slug mindy-first if there are no messages, mindy-continued otherwise
        if @messages.length
          slug = 'mindy-continued'

          # Also combine all the previous messages in the thread as `previousConversation`, in the format "user1:\nmessage1\n\nuser2:\nmessage2\n\n..."
          previousConversation = @thread.map(({ user: { name }, content }) -> "#{name}:\n#{content}").join('\n\n')
          console.log {previousConversation}

        else
          slug = 'mindy-first'

        promptId = idsBySlug[slug]
        
        try

          @sending = true
          message = @addMessage @tree.createChild _.last(@thread), {
            @user
            content: @input
          }
          @sending = false

          @$nextTick =>

            @generatingReply = true

            { data: {
              choices
            } } = await polygon.post "/run", {
              promptId,
              variables: {
                @input,
                previousConversation
              },
              parameters:
                n: 3
                max_tokens: 100
            }

            @input = ''
            
            console.log {choices}
            choices.forEach (choice) =>
              console.log {choice}
              @addMessage @tree.createChild message,
                user: @bot
                content: choice.text

            @$nextTick =>
              @$router.push { query: { id: choices[0].id } }
              document.querySelector('#input').focus()

        catch error

          console.error error
          @$bvToast.toast 'Something went wrong, please try again.',
            title: 'Error'
            variant: 'danger'
            solid: true
            autoHideDelay: 5000

        finally
          @sending = false
          @generatingReply = false

      resendMessage: () ->

        # Route to the editing.message's parent
        parent = @tree.parent(@editing.message)
        id = parent?.id ? 0
        console.log {id}
        @$router.push { query: { id } }
        @input = @editing.input
        @$nextTick =>
          debugger
          try
            @sendMessage()
          finally
            @editing.message = null

    watch:

      generatingReply: (generatingReply) ->
        clearInterval @typingInterval
        if generatingReply
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