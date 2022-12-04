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