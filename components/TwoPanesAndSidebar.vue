<template lang="pug">
  div
    style
      | :root {
      |   --navbar-height: {{ width > 1200 ? '0px' : '55px'}};
      |   --sidebar-width: 200px;
      |   --sidebar-height: calc(100vh - var(--navbar-height));
      | }
    MobileNav.d-block.d-xl-none(
      v-bind="{ secondaryPaneIcon, brand, tagline }"
      v-model="show"
    )
    div.vh-minus-navbar
      transition(name="slide-right")
        div#sidebar.vh-minus-navbar.m-0.bg-light.border-right.justify-content-between.overflow-auto(
            v-show="show.sidebar || width > 1200"
          )
          div.p-2
            div.d-none.d-xl-block.text-center(
              style="height: 56.4px;"
            )
              h2.mb-0.display-6(style="font-size: 1.2em")
                | {{ brand }}
              p.lead(style="font-size: 1em")
                | {{ tagline }}
            slot(name="sidebar")
          div.border-top
            slot(name="sidebar-footer")
      div#main.h-100.container-fluid
        div.row.h-100
          div.d-md-block.col-12.p-0.h-100(
              :class="'col-md-' + (12 - secondaryPaneCols)"
            )
            slot(name="primary-pane")
          transition(name="slide-left")
            div#secondary-pane.d-md-block.border-left.p-0.h-100(
                v-show="show.secondaryPane || width > 768"
                :class="'col-' + secondaryPaneCols"
              )
              slot(name="secondary-pane")
      //- 

</template>

<script lang="coffee">

  import checkWidthMixin from '~/plugins/mixins/checkWidth'

  export default

    props: ['secondaryPaneIcon', 'brand', 'tagline', 'sidebarComponent', 'primaryPaneComponent', 'secondaryPaneComponent']

    mixins: [
      checkWidthMixin()
    ]

    data: ->

      show:
        sidebar: false
        secondaryPane: false
      
      secondaryPaneCols: 8

</script>

<style>

  .vh-minus-navbar {
    height: calc(100vh - var(--navbar-height));
  }

  #sidebar {
    display: flex;
    flex-direction: column;
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    width: var(--sidebar-width);
    z-index: 20;
  }

  #main {
    padding-left: calc(var(--sidebar-width) + 15px);
  }

  @media (max-width: 1200px) {

    #sidebar {
      position: fixed;
      top: var(--navbar-height);
      left: 0;
      bottom: 0;
      box-shadow: 0 10px 10px rgba(0, 0, 0, 0.2);
      width: var(--sidebar-width);    
      z-index: 20;
    }

    #main {
      padding-left: 15px;
    }

  }  

  @media (max-width: 768px) {

    #secondary-pane {
      position: fixed;
      top: var(--navbar-height);
      left: auto;
      right: 0;
      bottom: 0;
      background-color: #fff;
      box-shadow: 0 10px 10px rgba(0, 0, 0, 0.2);
      width: 100%;
      max-width: 90vw;
      z-index: 10;
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