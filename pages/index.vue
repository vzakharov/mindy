<template>
  <b-container>
    <b-row>
      <b-col>
        <b-spinner v-if="!messages"/>
        <!-- Chat box -->
        <b-card v-else>
          <b-card-header>
            <b-card-title>Chat</b-card-title>
          </b-card-header>
          <b-card-body>
            <div
              v-for="(message, index) in messages"
              :key="index"
              class="d-flex justify-content-start mb-2"
            >
              <template v-if="message.special">
                <em>
                  <strong v-text="message.user.name"/> {{ message.special }}
                </em>
              </template>
              <template v-else>
                <strong
                  v-text="message.user.name"
                  :class="{ 'text-primary': message.user.name === user.name }"
                />:&nbsp;
                <span v-text="message.content" />
              </template>
            </div>
          </b-card-body>
          <b-card-footer>
            <!-- Enter user name -->
            <template v-if="!settings.mindy.token">
              <b-form-group
                label="Name"
                label-for="username"
              >
                <b-form-input
                  id="username"
                  :value="enteredName"
                  @input="enteredName = $event.toLowerCase().replace(/[^a-z0-9-]+/g, '-')"
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
              Name unavailable. Please choose another.
            </b-alert>

            <!-- Enter message -->
            <b-form
              @submit.prevent="sendMessage"
              class="mb-0"
            >
              <b-form-group
                :label="user.name"
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
          </b-card-footer>
        </b-card>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>

  import axios from 'axios'
  import _ from 'lodash'
  import syncLocal from '~/plugins/syncLocal'
  
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
            user: {
              name: null,
            },
            token: null,
          },
        }

      }

    },

    computed: {

      user: {
        get() {
          return this.settings.mindy.user
        },
        set(value) {
          this.settings.mindy.user = value
        }
      },

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

        let { data: messages } = await mindy.get('/messages')
        _.assign(this, { messages })
        
      },

      async createUser() {

        let { enteredName } = this
        this.checkingName = true
        this.nameUnavailable = false

        try {

          let { data: token } = await mindy.post('/users', { name: enteredName })
          this.user.name = enteredName
          _.assign(this.settings.mindy, { token })

        } catch (error) {

          if (error.response.status === 409) {

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

    }

  }

</script>

<style>
  label {
    font-weight: bold;
  }
</style>
