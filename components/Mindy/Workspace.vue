<template lang="pug">
  div.d-flex.flex-column.vh-minus-navbar.justify-content-between
    //- Header: buttons to edit in plain text, pick colors, settings, ideas, etc.
    div.bg-light.border-bottom.px-3.py-2.py-md-4.d-flex.justify-content-end
      //- Ideas
      button.btn.btn-light.btn-sm.mx-1.lightgray
        b-icon-lightbulb(
          @click="show.ideas = !show.ideas"
          :class="show.ideas ? 'text-primary' : ''"
        )
      //- Theme
      button.btn.btn-light.btn-sm.mx-1.lightgray(
        v-b-modal.theme-modal
      )
        b-icon-palette
      b-modal#theme-modal(
        ref="themeModal"
        title="Pick a theme"
        centered
      )
        ThemePicker(
          @input="pickTheme"
        )
        b-icon-palette
      //- Settings
      button.btn.btn-light.btn-sm.mx-1.lightgray
        b-icon-gear
      //- Download
      button.btn.btn-outline-secondary.btn-sm.mx-1.px-2
        b-icon-download.mr-2
        | Download
      //- Help
      button.btn.btn-light.btn-sm.mx-1.lightgray
        b-icon-question-circle
    //- 

    //- Mindmap
    div.d-flex.justify-content-center(ref="mindmap")
      MermaidMindmap.overflow-auto(
        v-show="code"
        :code="code"
      )

    //- Footer: ideas, if enabled
    div.pt-2.p-2.p-md-4(ref="footer")
      div.border.p-3.d-flex.justify-content-between.align-items-center(
        v-if="show.ideas"
        style="font-size: 1.5em;"
      )
        div
        div
          b-icon-lightbulb.text-primary.mr-2
          | Click on a box to expand it further
        div
          //- Next idea
          button.btn.btn-light.btn-sm.lightgray
            b-icon-arrow-right
    
</template>

<script lang="coffee">

  import updatePropsMixin from '~/plugins/mixins/updateProps'
  import autoHeightMixin from '~/plugins/mixins/autoHeight'

  export default

    props: ['code']

    mixins: [
      updatePropsMixin
      autoHeightMixin "mindmap", footerRef: "footer"
    ]

    data: ->

      show:
        ideas: false

    methods:

      pickTheme: (theme) ->
        console.log theme
        # hide the modal
        @$refs.themeModal.hide()


</script>