<template lang="pug">
  a.btn.btn-block.btn-light.text-left.pl-4(
    type="button"
    :class="expandable ? 'dropdown-toggle' : ''"
    :data-toggle="expandable ? 'dropdown' : ''"
  )
    //- Icon
    b-icon(v-if="icon" v-bind="{ icon }")
    //- Caption
    div.lead.d-inline-block(
      style="left: 1em; position: relative;"
    )
      | {{ caption }}
</template>

<script lang="coffee">

  export default

    props: ['icon', 'caption', 'expandable', 'expanded']

</script>