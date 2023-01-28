<template lang="pug">
  //- A span that looks like an <a> tag but doesn't have a target
  span(
    @click="$emit('click')"
    @keydown.enter="$emit('click')"
    style="cursor: pointer; text-decoration: underline;"
  )
    slot
</template>