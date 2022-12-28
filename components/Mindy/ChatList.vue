<template lang="pug">
    div
      MenuItem(
        icon="chat"
        caption="Chats"
        :expandable="true"
        :expanded="expanded"
        @click.native="expanded = !expanded"
      )
      ul.list-group(v-show="expanded")
        li.list-group-item(
            v-for="chat in chats" :key="chat.id"
            :style="{ fontWeight: chat.thread.includes(routedMessage) ? 'bold' : 'normal' }"
          )
          nuxt-link.d-block(
            :to="{ query: { id: chat.id } }"
            style="color: inherit;"
          )
            b-icon.mr-2(icon="chat")
            | {{ chat.title }}
</template>

<script lang="coffee">

  export default

    props: [ 'chats', 'routedMessage' ]

    data: ->

      expanded: true

      hoveredChat: null

</script>