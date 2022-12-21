<template lang="pug">

  div.h-100
    //- Chat space header
    div.bg-light.border-bottom.px-3.py-2.py-md-4.d-flex.justify-content-between
      div.d-flex
        //- Chat space title
        h4.mb-0 {{ title }}
        //- Edit icon, gray
        button.btn.btn-light.btn-sm.lightgray
          b-icon-pencil.icon-sm
      div.d-flex
        //- Bookmark button
        button.btn.btn-outline-secondary.btn-sm(
        )
          b-icon.pr-2(icon="bookmark")
          | Save
        //- Settings button (no caption)
        button.btn.btn-light.btn-sm.ml-2.lightgray
          b-icon(icon="gear")
    //- 

    //- Messages
    div#messages(
      ref="messages"
      style="overflow-y: auto; height: 100%;"
      )
      div.message(
        :id="`message-${message.id}`"
        v-for="(message, index) in thread", :key="`${index}-${routedMessage.id}`"
        :style=`{
          'background-color': index % 2 ? '#f7f7f7' : '#fff',
          'border': '1px solid ' + (message === routedMessage ? '#007bff' : '#fff'),
          'cursor': 'pointer'
        }`
        @click="updated.routedMessage = message"
      )
        div.px-3.pb-2.pt-1
          strong {{ message.user.name }}
          | : {{ message.content }}
    //- 

    //- Message input
    div.input-group.p-3.bg-light.border-top(ref="input")
      b-textarea.form-control(
        type="text"
        placeholder="Shift+Enter for new line"
        v-model="newMessage"
        rows="1"
        max-rows="10"
        :style=`{
          overflow: 'auto',
          ...isMultiline ? {
            fontSize: '1em',
          } : {
            height: '2.5em'
          },
        }`
      )
      div.input-group-append
        button.btn.btn-primary(
          type="button"
        )
          SendIcon
    //- 

  //- 

</template>

<script lang="coffee">

  import axios from 'axios'
  import _ from 'lodash'
  import QRCode from 'qrcode'

  import TreeLike from '~/plugins/treeLike'
  import log from '~/plugins/log'

  import updatePropsMixin from '~/plugins/mixins/updateProps'
  import tryAction from '~/plugins/mixins/tryAction'
  import windowMixin from '~/plugins/mixins/window'
  import mixpanelMixin from '~/plugins/mixins/mixpanel'
  import autoHeightMixin from '~/plugins/mixins/autoHeight'

  import PolygonClient from '~/plugins/polygonClient'


  defaultSettings =
    allowFineTuning: true
    autoBuildContext: true
    numGenerations: 3
    temperature: 0.6

  export default

    props: [ 'messages', 'routedMessage', 'title' ]

    mixins: [
      updatePropsMixin
      tryAction
      windowMixin
      mixpanelMixin
      autoHeightMixin 'messages', footerRef: 'input'
    ]

    data: ->
      previousThread: null
      newMessage: ''

    computed:

      tree: ->
        new TreeLike(@messages, vm: @)
      
      isMultiline: ->
        @newMessage.includes('\n')

      thread: ->
        # If the existing thread includes the routed message, use that
        if not @routedMessage
          []
        else
          if @previousThread?.includes(@routedMessage)
            @previousThread
          else
            @previousThread = @tree.thread(@routedMessage or @tree.root)

</script>

<style>

  body {
    font-size: 0.75em;
  }

  .lightgray {
    color: #bbb;
  }

  .icon-sm {
    font-size: 100%!important;
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