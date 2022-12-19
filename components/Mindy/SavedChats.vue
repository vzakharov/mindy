<template lang="pug">
    div
      MenuItem(
        icon="bookmark"
        caption="Saved"
        :expandable="true"
        :expanded="expanded"
        @click.native="expanded = !expanded"
      )
      ul.list-group(v-show="expanded")
        li.list-group-item(
          v-for="chat in chats" :key="chat.id"
          style="cursor: pointer;"
          )
          b-icon.pr-2(icon="chat")
          | {{ chat.name }}
</template>

<script lang="coffee">

  export default

    data: ->

      expanded: false

      # Dummy chats for now
      chats: [
        { id: 1, name: 'Mindy tutorial' }
        { id: 2, name: 'BMX' }
        { id: 3, name: 'Cats' }
      ]

      hoveredChat: null

</script>