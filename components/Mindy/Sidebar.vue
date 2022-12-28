<template lang="pug">
  
  div

    //- New chat button
    button.btn.btn-outline-primary.btn-lg.btn-block(
    )
      b-icon.pr-2(icon="chat")
      | New chat

    div.pt-3

    //- List of chats
    MindyChatList(v-bind="{ chats }")

</template>

<script lang="coffee">

  export default

    props: [ 'chats' ]

</script>