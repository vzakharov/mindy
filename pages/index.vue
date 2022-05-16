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
            <template v-if="!user.name">
              <b-form-group
                label="Name"
                label-for="username"
              >
                <b-form-input
                  id="username"
                  :value="enteredName"
                  @input="enteredName = $event.toLowerCase().replace(/[^a-z0-9-]+/g, '-')"
                  @change="checkName"
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

            <b-form-group
              :label="user.name"
              label-for="message"
            >
              <b-form-input
                id="message"
                v-model="message"
                lazy
                placeholder="Enter your message"
              />
            </b-form-group>
          </b-card-footer>
        </b-card>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>

  import axios from 'axios'
  import _ from 'lodash'
  
  const mindy = axios.create({
    baseURL: process.env.MINDY_API_URL,
  })

  export default {

    data() {

      return {

        messages: null,
        message: '',
        user: {
          name: ''
        },
        enteredName: '',
        checkingName: false,
        nameUnavailable: false,

      }

    },

    async mounted() {

      let { data: messages } = await mindy.get('/messages')
      _.assign(this, { messages })

    },

    methods: {

      async checkName() {

        let { enteredName } = this
        this.checkingName = true
        this.nameUnavailable = false

        let { data: user } = await mindy.get(`/u/${enteredName}/check`)
        if ( user.available ) {
          this.user.name = enteredName
          await mindy.post(`/u/${enteredName}/`)
        } else {
          this.nameUnavailable = true
        }

        this.checkingName = false

      }

    }

  }

</script>

<style>
  label {
    font-weight: bold;
  }
</style>
