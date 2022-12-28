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
        nuxt-link.list-group-item(
          tag="li"
          v-for="chat in chats" :key="chat.id"
          style="cursor: pointer;"
          :to="{ query: { id: chat.id } }"
          )
          b-icon.pr-2(icon="chat")
          span(v-text="`Chat #${chat.id}`")
          //- Todo: compute chat title
</template>

<script lang="coffee">

  export default

    props: [ 'chats' ]

    data: ->

      expanded: false

      hoveredChat: null

</script>