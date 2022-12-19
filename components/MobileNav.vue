<template lang="pug">

  div
    nav.navbar.navbar-light.bg-light.justify-content-between
      b-row(align-v="center")
        //- Button to toggle sidebar
        b-button.btn-light(
          :variant="visibility.sidebar ? 'outline-secondary' : 'light'"
          @click="visibility.sidebar = !visibility.sidebar"
        )
          span.navbar-toggler-icon
      //- Brand
      div#mobile-brand.lead.d-inline.pl-2
        | {{ brandMessage }}
      b-button(
        :variant="visibility.secondaryPane ? 'outline-secondary' : 'light'"
        @click="visibility.secondaryPane = !visibility.secondaryPane"
      )
        | {{ secondaryPaneCaption }}
    //- 

</template>

<script lang="coffee">

  import syncValueMixin from '~/plugins/mixins/syncValue'

  export default

    props: ['value', 'secondaryPaneCaption', 'brandMessage']

    mixins: [
      syncValueMixin('visibility', deep: true)
    ]

</script>