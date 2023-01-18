<template lang="pug">

  div.h-100
    //- Chat space header
    div.bg-light.border-bottom.px-3.py-2.py-md-4.d-flex.justify-content-between.align-items-center
      div.d-flex
        //- Chat space title
        h4.mb-0 {{ title }}
        //- Edit icon, gray
        button.btn.btn-light.btn-sm.pl-2.lightgray(v-if="id")
          b-icon-pencil.icon-sm.pb-1
      div.d-flex
        //- Bookmark button
        button.btn.btn-outline-secondary.btn-sm.mx-1.px-2(
        )
          b-icon.px-1(icon="bookmark")
          | Save
        //- Settings button (no caption)
        button.btn.btn-light.btn-sm.mx-1.lightgray
          b-icon(icon="gear")
    //- 

    //- Messages
    div#messages(
      ref="messages"
      style="overflow-y: auto; height: 100%;"
      )
      nuxt-link.message.px-2(
        tag="div"
        :id="`message-${message.id}`"
        v-for="(message, index) in thread", :key="`${index}-${routedMessage.id}`"
        :style=`{
          'background-color': index % 2 ? '#f7f7f7' : '#fff',
          'border': '1px solid ' + (message === routedMessage && routedMessage != thread[thread.length - 1] ? '#007bff' : '#fff'),
          'cursor': 'pointer'
        }`
        :to="{ query: { id: message.id } }"
      )
          //- If the message has siblings, and unless it is the first message of the thread, display a switcher looking like "< n / N >"
          //- where n is the current sibling index and N is the total number of siblings
          template( v-if="tree.numSiblings(message) > 1 && message !== thread[0]" )
            div(style="font-size: 0.8em; color: #aaa; float: right;")
              //- Switching is done by changing 'id' in the URL query string
              nuxt-link(:to="{ query: { id: tree.sibling(message, -1).id } }", class="mr-1", style="color: inherit",
                v-text="`< ${tree.siblingIndex(message) + 1}`"
              )
              | /
              nuxt-link(:to="{ query: { id: tree.sibling(message, 1).id } }", class="ml-1", style="color: inherit",
                v-text="`${tree.numSiblings(message)} >`"
              )
          strong {{ message.user.name || message.user.isBot ? 'mindy' : 'you' }}
          | :
          div(
            v-html="$md.render(message.content)"
            :title="message.context && message.context.thoughts ? `💭 ${message.context.thoughts}` : ''"
            @dblclick="editMessage(message)"
          )
      //- 

      div.p-2(v-if="bot.replying", class="text-muted")
        em mindy is thinking
          MovingDots

    //- 

    //- Message input
    MovingDots(v-if="bot.generatingRandomQuery" @refresh="dots = $event" v-show="false")
    b-form( @submit.prevent="$emit('query', { content: query, parent: lastMessage })" )
      div.input-group.p-3.bg-light.border-top(ref="input")
        TextareaAutosize.form-control(
          ref="input"
          type="text"
          :placeholder="bot.generatingRandomQuery ? `Generating random query${dots}` : 'Shift+Enter for new line'"
          v-model="query"
          rows="1"
          :max-height="300"
          :font-size-if-multiline="'1em'"
          @keydown.enter.native.exact.prevent="$emit('query', { content: query, parent: lastMessage })"
        )
        div.input-group-append
          button.btn.btn-primary(
            type="submit"
          )
            Icon(icon="send")
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

    props: [ 'id', 'messages', 'routedMessage', 'title', 'tree', 'thread', 'rootMessage', 'lastMessage', 'bot', 'query' ]

    mixins: [
      updatePropsMixin
      tryAction
      windowMixin
      mixpanelMixin
      autoHeightMixin 'messages', footerRef: 'input'
    ]

    data: ->
      previousThread: null
      dots: ''

    computed:

      isMultiline: ->
        @query.includes('\n')
      
    
    methods:
    
      editMessage: (message) ->
        if content = window.prompt('Edit message:', message.content)
          if message.user.isBot
            # Just change the message content
            @$emit 'editMessage', { message, content }
          else
            # Send a new message with the same parent
            @$emit 'query', { content, parent: @tree.parent(message) }

    
    # watch:

    #   query: ->
    #     log 'query', @query
    #     { input } = @$refs
    #     { scrollHeight } = input
    #     height = parseInt window.getComputedStyle(input).height.replace 'px', ''
    #     log 'scrollHeight', scrollHeight, 'height', height
    #     if scrollHeight > height
    #       @inputHeight = "#{scrollHeight}px"
    #     else
    #       @inputHeight = '2.5em'

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