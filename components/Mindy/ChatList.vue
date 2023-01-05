<template lang="pug">
    div
      MenuItem(
        icon="chat"
        caption="Chats"
        :expandable="true"
        :expanded="expanded"
        @click.native="expanded = !expanded"
      )
      div.border(v-if="expanded" style="height: 300px; overflow: auto;")
        b-button.d-block.text-left(
          v-for="chat in chats" :key="chat.id"
          :variant="chat.messages.includes(routedMessage) ? 'outline-secondary' : 'light'"
          :disabled="chat.messages.includes(routedMessage)"
          :to="{ query: { id: chat.id } }"
        )
          b-icon.pr-2(icon="chat")
          span.lead(:style="{ fontWeight: chat.messages.includes(routedMessage) ? 'bold' : 'normal', fontSize: '0.9em', color: 'black' }")
            | {{ chat.title }}
</template>

<script lang="coffee">

  export default

    props: [ 'chats', 'routedMessage' ]

    data: ->

      expanded: true

      hoveredChat: null

</script>