<template lang="pug">
    b-dropdown.d-block(
      variant="light"
      text="Saved chats"
      block split
    )
      template(slot="button-content")
        b-icon.pr-2(icon="bookmark")
        | Saved
      b-dropdown-item(v-for="chat in chats" :key="chat.id")
        b-icon.pr-2(icon="chat")
        | {{ chat.name }}
</template>

<script lang="coffee">

  export default

    data: ->

      # Dummy chats for now
      chats: [
        { id: 1, name: 'Mindy tutorial' }
        { id: 2, name: 'BMX' }
        { id: 3, name: 'Cats' }
      ]

      hoveredChat: null

</script>