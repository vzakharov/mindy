<template lang="pug">
  b-container
    b-row
      b-col(class="border p-0")
        b-spinner(v-if="!messages")
        template(v-else)
          div(class="header p-3")
            h1 Chat

          div(class="p-3")
            div(v-for="(message, index) in messages", :key="index", class="mt-2")
              template(v-if="message.special")
                em
                  strong {{ message.user.name }} {{ message.content }}
              template
                div(v-text="message.user.name", :class="{ 'text-primary': user && message.user.name === user.name }", :style="{ fontWeight: 'bold' }")
                div(v-text="message.content")
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
              b-form-group(:label="user && user.name", label-for="message")
                b-form-input(id="message", v-model="message", placeholder="Enter your message", :disabled="!user || sending")
              b-button(type="submit", :variant="sending ? 'outline-secondary' : 'primary'", :disabled="!message || sending")
                | {{ sending ? 'Sending...' : 'Send' }}
                b-spinner(v-if="sending", small)
                
</template>

<script lang="coffee">
import axios from 'axios'
import _ from 'lodash'
import syncLocal from '~/plugins/syncLocal.coffee'
import QRCode from 'qrcode'

mindy = axios.create
  baseURL: process.env.MINDY_API_URL

export default


  data: ->
    message: ''
    lastMessageTime: null
    sending: false
    generatingReply: false
    enteredName: ''
    checkingName: false
    nameUnavailable: false
    user: {}
    messages: []
    typingCount: 0
    typingInterval: null

  mixins: [
    syncLocal keys: [
      'user', 'messages'
    ]
  ]


  methods:
  

    sendMessage: ->
      @sending = true
      try
        {
          data: { message, botWillStartReplyingIn }
        } = await mindy.post '/postMessage',
          content: @message,
          headers:
            Authorization: "Bearer #{@settings.mindy.token}"

        setTimeout =>
          @generatingReply = true
        , botWillStartReplyingIn

        @messages.push message

        @message = ''

        # Focus on the message input
        @$nextTick =>
          document.querySelector('#message').focus()
      catch error
        console.error error
        @$bvToast.toast 'Something went wrong, please try again.',
          title: 'Error'
          variant: 'danger'
          solid: true
          autoHideDelay: 5000
      finally
        @sending = false

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

<style
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
  } */

</style>
