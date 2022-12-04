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
            template(v-if="!settings.mindy.token")
              b-form-group(label="Name", label-for="username")
                b-form-input(id="username", :value="enteredName", @input="enteredName = $event.toLowerCase().replace(/[^a-z0-9-]+/g, '-').replace(/-+/g, '-')", @change="createUser", placeholder="Enter your name to start chatting")
            b-spinner(v-if="checkingName", label="Checking name...", small)
            b-alert(:show="nameUnavailable", variant="danger", dismissible)
              | This name is already taken. If that’s you, paste your token below:
              b-input(v-model="settings.mindy.token", placeholder="mindy-...")
            b-form(@submit.prevent="sendMessage", class="mb-0")
              b-form-group(:label="user && user.name", label-for="message")
                b-form-input(id="message", v-model="message", placeholder="Enter your message", :disabled="!user || sending")
              b-button(type="submit", :variant="sending ? 'outline-secondary' : 'primary'", :disabled="!message || !settings.mindy.token || sending")
                | {{ sending ? 'Sending...' : 'Send' }}
                b-spinner(v-if="sending", small)
</template>

<script lang="coffee" src="./index.coffee"></script>

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
