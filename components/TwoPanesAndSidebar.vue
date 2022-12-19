<template lang="pug">
  div
    style
      | :root {
      |   --navbar-height: {{ width > 1200 ? '0px' : '56.4px'}};
      |   --sidebar-width: 200px;
      |   --sidebar-height: calc(100vh - var(--navbar-height));
      | }
    MobileNav.d-block.d-xl-none(
      v-bind="{ secondaryPaneCaption, brand, tagline }"
      v-model="show"
    )
    transition(name="slide-right")
      div#sidebar.m-0.vh-minus-navbar.bg-light.border-right.p-2.justify-content-between(
          v-show="show.sidebar || width > 1200"
        )
        div
          div.d-none.d-xl-block.text-center(
            style="height: 56.4px;"
          )
            h2.mb-0.display-6(style="font-size: 1.2em")
              | {{ brand }}
            p.lead(style="font-size: 1em")
              | {{ tagline }}
          slot(name="sidebar")
        div.border-top.d-flex
          slot(name="sidebar-footer")
    div#main.container-fluid
      div.row.vh-minus-navbar
        div.p-2.d-md-block.border-right(
            :class="'col-' + primaryPaneCols"
          )
          slot(name="primary-pane")
        transition(name="slide-left")
          div#secondary-pane.p-2.col-auto.d-md-block(
              v-show="show.secondaryPane || width > 768"
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

      show:
        sidebar: true
        secondaryPane: true
      
      primaryPaneCols: 4

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
    z-index: 2;
  }

  #main {
    padding-left: calc(var(--sidebar-width) + 15px);
  }

  @media (max-width: 1200px) {

    #sidebar {
      position: fixed;
      top: 56px;
      left: 0;
      bottom: 0;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
      width: var(--sidebar-width);    
      z-index: 2;
    }

    #main {
      padding-left: 15px;
    }

  }  

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