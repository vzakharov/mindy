<template lang="pug">
  div This is chat space
</template>

<script lang="coffee">

  import axios from 'axios'
  import _ from 'lodash'

  import TreeLike from '~/plugins/treeLike'
  import log from '~/plugins/log'

  import syncLocal from '~/plugins/mixins/syncLocal'
  import exposeVM from '~/plugins/exposeVM'
  import tryAction from '~/plugins/tryAction'
  import windowMixin from '~/plugins/mixins/window'
  import mixpanelMixin from '~/plugins/mixins/mixpanel'
  import checkWidthMixin from '~/plugins/mixins/checkWidth'

  import PolygonClient from '~/plugins/polygonClient'

  defaultSettings =
    allowFineTuning: true
    autoBuildContext: true
    numGenerations: 3
    temperature: 0.6

  export default

    props: [ 'value' ]

    mixins: [
      exposeVM
      tryAction
      windowMixin
      mixpanelMixin
    ]

</script>
