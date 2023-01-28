<template lang="pug">
  
  div.p-2

    //- Ideas
    MenuItem(
      icon="lightbulb"
      caption="Ideas"
    )
    //- Usage
    MenuItem(
      icon="bar-chart"
      caption="Usage"
    )
    //- Profile
    MenuItem(
      :icon="!user && 'emoji-smile'"
      :caption="user ? user.slug : busy.authenticating || busy.gettingUser ? 'Loading...' : 'Profile'"
    )
      template(#glyph
        v-if="user"
      )
        span(v-html="toSvg(user.slug, 21)")
      b-spinner(v-else small type="grow")
      template(#caption
        v-if="user"
      )
        strong {{ user.slug }}

</template>

<script lang="coffee">

  import { toSvg } from 'jdenticon'

  export default

    props: [ 'user', 'busy' ]

    methods: { toSvg }

</script>