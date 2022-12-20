<template lang="pug">

  div#messages.vh-minus-navbar(
    style="overflow-y: scroll;"
    )
    div.message(
      :id="`message-${message.id}`"
      :ref="`message-${message.id}`"
      v-for="(message, index) in messages", :key="index", 
      :style=`{
        'background-color': index % 2 ? '#f7f7f7' : '#fff',
        'border': message === routedMessage && message !== lastMessage ? '1px solid #ccc' : 'none',
        'cursor': message !== routedMessage && message.user.isBot ? 'pointer' : 'default',
      }`
      @click="routedMessage = message"
    )
      div.px-3.pb-2.pt-1 {{ message.user.name }}: {{ message.content }}

  //- 

</template>

<script lang="coffee">

  import axios from 'axios'
  import _ from 'lodash'
  import QRCode from 'qrcode'

  import TreeLike from '~/plugins/treeLike'
  import log from '~/plugins/log'

  import syncValueMixin from '~/plugins/mixins/syncValue'
  import tryAction from '~/plugins/tryAction'
  import windowMixin from '~/plugins/mixins/window'
  import mixpanelMixin from '~/plugins/mixins/mixpanel'

  import PolygonClient from '~/plugins/polygonClient'


  defaultSettings =
    allowFineTuning: true
    autoBuildContext: true
    numGenerations: 3
    temperature: 0.6

  export default

    props: [ 'value' ]

    mixins: [
      syncValueMixin( 'chat', unfold: true )
      tryAction
      windowMixin
      mixpanelMixin
    ]

    data: ->
      messages: []
      messageId: null

    computed:

      routedMessage:
        get: -> _.find @messages, { id: @messageId }
        set: (message) -> @messageId = message?.id


</script>

<style>

  body {
    font-size: 0.75em;
  }

  /* Remove margin after last child of .message-content */
  .message-content *:last-child {
    margin-bottom: 0;
  }

  label {
    font-weight: bold;
  }

  .footer {
    /* position: sticky;
    bottom: 0;
    z-index: 1; */
    background-color: #f7f7f7;
    border-top: 1px solid #e7e7e7;
  }

  .header {
    /* position: sticky;
    top: 0;
    z-index: 1; */
    background-color: #f7f7f7;
    border-bottom: 1px solid #e7e7e7;
  }

</style>