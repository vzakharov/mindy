<template lang="pug">

  //- The form
  b-form(
    style="width: 100%;"
  )
    //- The input
    EditSettingsInput(
      v-for="( setting, key ) in settings"
      :key="key"
      :properties="properties[key]"
      v-model="settings[key]"
    )

</template>

<script lang="coffee">

  import syncValueMixin from '~/plugins/mixins/syncValue'

  export default

    mixins: [
      syncValueMixin 'settings', deep: true
    ]

    props:
      title:
        type: String
        default: "Edit settings"
      okTitle:
        type: String
        default: "Save"
      cancelTitle:
        type: String
        default: "Cancel"
      value:
        type: Object
        required: true
      properties:
        type: Object
        default: -> {}

</script>