<template lang="pug">
  div.d-flex.flex-column.h-100.justify-content-center.align-items-center
    MermaidMindmap(
      v-if="code"
      :code="code"
    )
</template>

<script lang="coffee">

  import updatePropsMixin from '~/plugins/mixins/updateProps'

  export default

    props: ['code']

    mixins: [ updatePropsMixin ]

</script>