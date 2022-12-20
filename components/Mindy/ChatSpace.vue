<template lang="pug">
  div(v-text="JSON.stringify(messages)")
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
      syncValueMixin('messages')      
      tryAction
      windowMixin
      mixpanelMixin
    ]

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