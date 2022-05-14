<template>
  <b-container>
    <b-row>
      <b-col>
        <!-- Chat box -->
        <b-card>
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
                  <strong v-text="message.user"/> {{ message.special.name }}
                </em>
              </template>
              <template v-else>
                <strong
                  v-text="message.user"
                  :class="{ 'text-primary': message.user === user }"
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
                  v-model="user.name"
                  lazy
                  placeholder="Enter your name to start chatting"
                  :state="user.name ? 'success' : 'danger'"
                />
              </b-form-group>
            </template>
            <b-form-group
              :label="user.name"
              label-for="message"
            >
              <b-form-input
                id="message"
                v-model="message"
                lazy
                placeholder="Enter your message"
                :disabled="!user.name"
              />
            </b-form-group>
          </b-card-footer>
        </b-card>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>

  import Notion from '~/plugins/notion'

  export default {

    data() {

      return {
        // Some sample messages to start with
        messages: null,
        message: '',
        user: {}

      }

    },

    async mounted() {

      this.messages = await Notion.anon.queryDatabase(process.env.NOTION_DATABASE_ID, {
        sorts: [
          {
            property: 'Time',
            direction: 'descending'
          }
        ],
      })

    }

  }

</script>

<style>
  label {
    font-weight: bold;
  }
</style>
