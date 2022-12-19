<template lang="pug">

  div
    MobileNav.d-block.d-md-none(
      v-bind="{ secondaryPaneCaption, brand, tagline }"
      v-model="visibility"
    )
    div.container-fluid.p-0
      div.row
        transition(name="slide-right")
          div#sidebar.col-2.d-md-block.m-0.vh-100.bg-light.border-right.p-2.px-md-4(
              v-show="visibility.sidebar || width > 768"
            )
            div.d-none.d-md-block.text-center
              h2.mb-0.display-6
                | {{ brand }}
              p.lead(style="font-size: 1.2em")
                | {{ tagline }}
            slot(name="sidebar")
        div.d-md-block.border-right(
            :class="'col-' + primaryPaneCols"
          )
          slot(name="primary-pane")
        transition(name="slide-left")
          div#secondary-pane.col-auto.d-md-block(
              v-show="visibility.secondaryPane || width > 768"
            )
            slot(name="secondary-pane")
    //- 

</template>

<script lang="coffee">

  import checkWidthMixin from '~/plugins/mixins/checkWidth'

  export default

    props: ['secondaryPaneCaption', 'brand', 'tagline', 'sidebarComponent', 'primaryPaneComponent', 'secondaryPaneComponent']

    mixins: [
      checkWidthMixin()
    ]

    data: ->

      visibility:
        sidebar: true
        secondaryPane: true
      
      primaryPaneCols: 4

</script>

<style>
  
  @media (max-width: 768px) {

    #secondary-pane {
      position: fixed;
      top: 56px;
      left: auto;
      right: 0;
      bottom: 0;
      background-color: #fff;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
      width: 100%;
      max-width: 90vw;
      z-index: 1;
    }

    #sidebar {
      position: fixed;
      top: 56px;
      left: 0;
      right: auto;
      bottom: 0;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
      width: 200px;      
      max-width: 50vw;
      z-index: 2;
    }

  }  

  .slide-left-enter-active, .slide-left-leave-active, .slide-right-enter-active, .slide-right-leave-active {
    transition: transform 0.3s;
  }

  .slide-left-enter, .slide-left-leave-to {
    transform: translateX(100%);
  }

  .slide-right-enter, .slide-right-leave-to {
    transform: translateX(-100%);
  }


</style>