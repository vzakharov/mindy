<template lang="pug">
  div.btn.btn-block.btn-light.text-left.pl-4(
    type="button"
  )
    //- Glyph
    slot(name="glyph" v-if="$slots.glyph")
    b-icon(v-if="icon" v-bind="{ icon }")
    //- Caption
    div.lead.d-inline-block(
      :style="`left: 1em; position: relative; ${captionStyle}`"
    )
      slot(name="caption" v-if="$slots.caption")
      span(v-else) {{ caption }}
    //- Expandable arrow
    b-icon.float-right.pt-2(v-if="expandable" :icon="expanded ? 'chevron-up' : 'chevron-down'")
</template>

<script lang="coffee">

  export default

    props: ['icon', 'caption', 'expandable', 'expanded', 'captionStyle']

</script>