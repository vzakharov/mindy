<template>
  <b-container>
    <b-row>
      <b-col class="border p-0">
        <b-spinner v-if="!messages"/>
        <!-- Chat box -->
        <template v-else>
          <div class="header p-3">
            <h1>Chat</h1>
          </div>
          <div class="p-3">
            <div
              v-for="(message, index) in messages"
              :key="index"
              class="mt-2"
            >
              <template v-if="message.special">
                <em>
                  <strong v-text="message.user.name"/> {{ message.special }}
                </em>
              </template>
              <template v-else>
                <div
                  v-text="message.user.name"
                  :class="{ 'text-primary': user && message.user.name === user.name }"
                  :style="{
                    fontWeight: 'bold'
                  }"
                />
                <div 
                  v-text="message.content"
                />
              </template>
            </div>
          </div>
          <div
            class="footer p-3"
          >
            <!-- Enter user name -->
            <template v-if="!settings.mindy.token">
              <b-form-group
                label="Name"
                label-for="username"
              >
                <b-form-input
                  id="username"
                  :value="enteredName"
                  @input="enteredName = $event.toLowerCase().replace(/[^a-z0-9-]+/g, '-').replace(/-+/g, '-')"
                  @change="createUser"
                  placeholder="Enter your name to start chatting"
                />
              </b-form-group>
            </template>
            <b-spinner v-if="checkingName" label="Checking name..." small />
            <b-alert :show="nameUnavailable"
              variant="danger"
              dismissible              
            >
              This name is already taken. If that’s you, paste your token below:
              <b-input
                v-model="settings.mindy.token"
                placeholder="mindy-..."
              />
            </b-alert>

            <!-- Enter message -->
            <b-form
              @submit.prevent="sendMessage"
              class="mb-0"
            >
              <b-form-group
                :label="user && user.name"
                label-for="message"
              >
                <b-form-input
                  id="message"
                  v-model="message"
                  placeholder="Enter your message"
                />
              </b-form-group>
              <b-button
                type="submit"
                variant="primary"
                :disabled="!message || !settings.mindy.token"
              >
                Send
              </b-button>
            </b-form>
          </div>
        </template>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>

  import axios from 'axios'
  import _ from 'lodash'
  import syncLocal from '~/plugins/syncLocal'
  import QRCode from 'qrcode'
  
  const mindy = axios.create({
    baseURL: process.env.MINDY_API_URL,
  })

  export default {

    mixins: [syncLocal],

    data() {

      return {

        messages: null,
        message: '',
        enteredName: '',
        checkingName: false,
        nameUnavailable: false,
        settings: {
          mindy: {
            token: null,
          },
        },
        user: null

      }

    },

    mounted() {

      const checkMessages = async () => {

        await this.checkMessages()
        setTimeout(checkMessages, 5000)
        
      }

      checkMessages()

    },

    methods: {

      async checkMessages() {

        let messages

        while ( !messages ) {

          try {

            ( { data: messages } = await mindy.get('/messages') )
            _.assign(this, { messages })

          } catch (e) {

            console.error(e)
            // If it's a timeout, try again
            if ( e.code === 'ETIMEDOUT' ) {
              continue
            } else {
              // Otherwise, stop trying
              break
            }
            
          }

        }
        
      },

      async createUser() {

        let { enteredName } = this
        this.checkingName = true
        this.nameUnavailable = false

        try {

          let { data: token } = await mindy.post('/users', { name: enteredName })
          this.settings.mindy.token = token          

          // Download an html with login info
          // Link is /mindy?token=<token>
          let { origin } = window.location
          let url = `${origin}/mindy?token=${token}`
          // let text = `Use the below link if you want to login to Mindy as “${enteredName}” from another device:\n\n${url}\n\nNOTE THAT LOST LOGIN INFORMATION CANNOT BE RECOVERED AS WE DO NOT STORE IT.`
          let html = String.raw`
            <!DOCTYPE html>
            <html lang="en">
              <head>
                <meta charset="utf-8">
                <title>Mindy credentials</title>
                <!-- import bootstrap -->
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
                <!-- link to favicon -->
                <link rel="icon" type="image/png" href="${origin}/favicon.png">
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
                  <h1>Mindy login credentials for ${enteredName}</h1>
                  <!-- warning that login info is not stored -->
                  <p class="text-danger">NOTE THAT LOST LOGIN INFORMATION CANNOT BE RECOVERED AS WE DO NOT STORE IT.</p>
                  <h2>Login token</h2>
                  <p>Here is your login token to log in as <code>${enteredName}</code>:</p>
                  <pre>${token}</pre>
                  <!-- Button to copy token -->
                  <button id="copy-token" class="btn btn-outline-secondary"
                    onclick="navigator.clipboard.writeText('${token}'); Object.assign(document.querySelector('#copy-token'), { disabled: true, innerText: 'Copied!'}); setTimeout(() => Object.assign(document.querySelector('#copy-token'), { disabled: false, innerText: 'Copy token' }), 1000);"
                  >
                    Copy token
                  </button>
                  <h2>Login link</h2>
                  <p>Use this link to login from another device:</p>
                  <p><a href="${url}">${url}</a></p>
                  <!-- QR code -->
                  <h2>QR code</h2>
                  <p>Scan this QR code to login from e.g. a mobile device:</p>
                  <img src="${await QRCode.toDataURL(url)}" />
                </div>
              </body>
            </html>
          `
          let filename = `Mindy credentials for ${enteredName}.html`
          let blob = new Blob([html], { type: 'text/html' })
          let link = document.createElement('a')
          link.href = window.URL.createObjectURL(blob)
          link.download = filename
          link.click()

        } catch (error) {

          if (error.response?.status === 409) {

            this.nameUnavailable = true

          } else {
            throw error
          }

        } finally {

          this.checkingName = false

        }

      },

      async sendMessage() {

        let { message } = this
        this.message = ''

        await mindy.post('/messages', { content: message }, {
          headers: {
            Authorization: `Bearer ${this.settings.mindy.token}`,
          },
        })

        this.messages.push({
          user: this.user,
          content: message,
        })

      },

    },

    watch: {

      '$route.query.token': {
        immediate: true,
        async handler(token) {
          if ( !token ) return
          this.settings.mindy.token = token
        },
      },

      'settings.mindy.token': {
        immediate: true,
        async handler(token) {
          if ( !token ) return
          mindy.defaults.headers.Authorization = `Bearer ${token}`
          try {

            this.user = (
              await mindy.get('/me')
            ).data
            this.nameUnavailable = false


          } catch (error) {
            this.settings.mindy.token = null
            // If it's a 401, show a toast
            if (error.response?.status === 401) {
              this.$bvToast.toast(
                'Invalid Mindy token. Please double-check your Mindy credentials. Unfortunately, lost tokens cannot be recovered as we do not store them.',
                {
                  title: 'Mindy',
                  variant: 'danger',
                  solid: true
                }
              )
            }
          }
        },
      },

    }

  }

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
