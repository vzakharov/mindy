import axios from 'axios'
import _ from 'lodash'
import syncLocal from '~/plugins/syncLocal'
import QRCode from 'qrcode'

mindy = axios.create
  baseURL: process.env.MINDY_API_URL

export default

  mixins: [syncLocal]

  data: ->
    messages: null
    message: ''
    lastMessageTime: null
    sending: false
    generatingReply: false
    enteredName: ''
    checkingName: false
    nameUnavailable: false
    settings:
      mindy:
        token: null
    user: null
    typingCount: 0
    typingInterval: null

  mounted: ->
    # Load token from query
    { token } = this.$route.query
    if token
      console.log 'token', token
      this.settings.mindy.token = token

    this.checkMessages()
    
  methods:
  
    checkMessages: (lastChecked) ->
      checkedAt = new Date()

      try
        { data: { messages } } = await mindy.post '/fetchMessages',
          lastChecked

        this.messages = messages
        this.generatingReply = false
      catch e
        console.error e
        # Wait 5 seconds before trying again
        await new Promise (resolve) => setTimeout resolve, 5000
      finally
        this.$nextTick =>
          this.checkMessages checkedAt

    createUser: ->
      { enteredName } = this
      this.checkingName = true
      this.nameUnavailable = false

      try
        { data: token } = await mindy.post '/users',
          name: enteredName
        this.settings.mindy.token = token

        # Download an html with login info
        # Link is /mindy?token=<token>
        { origin } = window.location
        url = "#{origin}/mindy?token=#{token}"
        # let text = `Use the below link if you want to login to Mindy as “${enteredName}” from another device:\n\n${url}\n\nNOTE THAT LOST LOGIN INFORMATION CANNOT BE RECOVERED AS WE DO NOT STORE IT.`
        html = String.raw"""
          <!DOCTYPE html>
          <html lang="en">
            <head>
              <meta charset="utf-8">
              <title>Mindy credentials</title>
              <!-- import bootstrap -->
              <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
              <!-- link to favicon -->
              <link rel="icon" type="image/png" href="#{origin}/favicon.png">
              <!-- style, add margin to h2 -->
              <style>
                h2 {
                  margin-top: 1rem;
                }
              </style>
            </head>
            <body>
              <!-- center text -->
              <div class="container mt-4 text-center">
                <h1>Mindy login credentials for #{enteredName}</h1>
                <!-- warning that login info is not stored -->
                <p class="text-danger">NOTE THAT LOST LOGIN INFORMATION CANNOT BE RECOVERED AS WE DO NOT STORE IT.</p>
                <h2>Login token</h2>
                <p>Here is your login token to log in as <code>#{enteredName}</code>:</p>
                <pre>#{token}</pre>
                <!-- Button to copy token -->
                <button id="copy-token" class="btn btn-outline-secondary"
                  onclick="navigator.clipboard.writeText('#{token}'); Object.assign(document.querySelector('#copy-token'), { disabled: true, innerText: 'Copied!'}); setTimeout(() => Object.assign(document.querySelector('#copy-token'), { disabled: false, innerText: 'Copy token' }), 1000);"
                >
                  Copy token
                </button>
                <h2>Login link</h2>
                <p>Use this link to login from another device:</p>
                <p><a href="#{url}">#{url}</a></p>
                <!-- QR code -->
                <h2>QR code</h2>
                <p>Scan this QR code to login from e.g. a mobile device:</p>
                <img src="#{await QRCode.toDataURL(url)}" />
              </div>
            </body>
          </html>
        """
        filename = "Mindy credentials for #{enteredName}.html"
        blob = new Blob [html],
          type: 'text/html'
        link = document.createElement 'a'
        link.href = window.URL.createObjectURL blob
        link.download = filename
        link.click()
      catch error
        if error.response?.status is 409
          this.nameUnavailable = true
        else
          throw error
      finally
        this.checkingName = false

    sendMessage: ->
      this.sending = true
      try
        {
          data: { message, botWillStartReplyingIn }
        } = await mindy.post '/postMessage',
          content: this.message,
          headers:
            Authorization: "Bearer #{this.settings.mindy.token}"

        setTimeout =>
          this.generatingReply = true
        , botWillStartReplyingIn

        this.messages.push message

        this.message = ''

        # Focus on the message input
        this.$nextTick =>
          document.querySelector('#message').focus()
      catch error
        console.error error
        this.$bvToast.toast 'Something went wrong, please try again.',
          title: 'Error'
          variant: 'danger'
          solid: true
          autoHideDelay: 5000
      finally
        this.sending = false

  watch:
    'settings.mindy.token':
      immediate: true
      handler: (token) ->
        if not token then return
        mindy.defaults.headers.Authorization = "Bearer #{token}"
        try
          this.user = (await mindy.get '/me').data
          this.nameUnavailable = false
        catch error
          this.settings.mindy.token = null
          # If it's a 401, show a toast
          if error.response?.status is 401
            this.$bvToast.toast 'Invalid Mindy token. Please double-check your Mindy credentials. Unfortunately, lost tokens cannot be recovered as we do not store them.',
              title: 'Mindy'
              variant: 'danger'
              solid: true
          else
            throw error

    messages: (messages) ->
      # If there are new messages, scroll to 'scroll-to-bottom'
      { time } = messages[messages.length - 1]
      if this.lastMessageTime isnt time
        this.$nextTick =>
          document.getElementById('scroll-to-bottom')?.scrollIntoView()
        this.lastMessageTime = time

    generatingReply: (generatingReply) ->
      clearInterval this.typingInterval
      if generatingReply
        this.typingInterval = setInterval =>
          this.typingCount = ( this.typingCount + 1 ) % 3
        , 500
      else
        this.typingCount = 0