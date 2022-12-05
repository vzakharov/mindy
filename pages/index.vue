<template lang="pug">
  b-container
    b-row
      b-col(class="border p-0")
        b-spinner(v-if="!messages")
        template(v-else)
          div(class="header p-3")
            h1 Chat

          div(class="p-3")

            div(v-for="(message, index) in thread", :key="index", class="mt-2")

              template(v-if="message.special")
                em
                  strong {{ message.user.name }} {{ message.content }}

              template
                div(v-text="message.user.name", :class="{ 'text-primary': user && message.user.name === user.name }", :style="{ fontWeight: 'bold' }")
                div(v-html="$md.render(message.content)")
              
              //- If the message has siblings, display a switcher looking like "< n / N >" where n is the current sibling index and N is the total number of siblings
              //- Clicking "<" / ">" will switch the current message to the previous / next sibling respectively
              template( v-if="tree.numSiblings(message) > 1")
                div(class="text-muted")
                  //- Switching is done by changing 'id' in the URL query string
                  nuxt-link(:to="{ query: { id: tree.sibling(message, -1).id } }", class="mr-2",
                    v-text="`< ${tree.siblingIndex(message) + 1}`"
                  )
                  | /
                  nuxt-link(:to="{ query: { id: tree.sibling(message, 1).id } }",
                    v-text="`${tree.numSiblings(message)} >`"
                  )
                
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

      anchorMessage: ->
        
        # Either message with the id from a query param or the last message
        { $route: { query: { id } } } = @
        if id
          # convert to int
          id = parseInt(id)
          _.find @messages, { id }
        else
          _.last @messages
        

      thread: ->
        if @anchorMessage then @tree.thread(@anchorMessage) else []
      
    mounted: ->
      
      @idsBySlug = new Promise (resolve, reject) =>

        { NOTION_PROMPTS_DB_ID } = process.env

        polygon.get("/prompt-ids/#{NOTION_PROMPTS_DB_ID}")
          .then ({ data }) -> resolve data
          .catch reject

    methods:
    
      sendMessage: ->

        idsBySlug = await @idsBySlug

        promptId = idsBySlug['mindy-first']
        
        try

          @sending = true
          @messages = @tree.addChild @tree.parent(@anchorMessage), message = {
            @user
            content: @input
          }
          @sending = false


          @generatingReply = true

          { data: {
            choices
          } } = await polygon.post "/run", {
            promptId,
            variables: {
              @input
            },
            parameters:
              n: 3
              max_tokens: 100
          }

          @input = ''
          
          choices.forEach (choice) =>
            @messages = @tree.addChild message,
              user: @bot
              content: choice.text

          # Focus on the input
          @$nextTick =>
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

    watch:

      generatingReply: (generatingReply) ->
        clearInterval @typingInterval
        if generatingReply
          @typingInterval = setInterval =>
            @typingCount = ( @typingCount + 1 ) % 3
          , 500
        else
          @typingCount = 0

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