<template lang="pug">

  div
    nav.navbar.navbar-light.bg-light.justify-content-between.align-items-center
      //- Button to toggle sidebar
      b-button.btn-light(
        :variant="show.sidebar ? 'outline-secondary' : 'light'"
        @click="show.sidebar = !show.sidebar"
      )
        span.navbar-toggler-icon
      //- Brand
      div#mobile-brand.lead.d-inline.pl-2(style="font-size: 1em;")
        strong {{ brand }}  
        | · {{ tagline }}
      b-button.d-md-none(
        :variant="show.secondaryPane ? 'outline-secondary' : 'light'"
        @click="show.secondaryPane = !show.secondaryPane"
      )
        | {{ secondaryPaneCaption }}
    //- 

</template>

<script lang="coffee">

  import syncValueMixin from '~/plugins/mixins/syncValue'

  export default

    props: ['value', 'secondaryPaneCaption', 'brand', 'tagline']

    mixins: [
      syncValueMixin('show', deep: true)
    ]

</script>