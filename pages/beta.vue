<template lang="pug">

  TwoPanesAndSidebar(
    brand="Mindy"
    tagline="Brainstorm with AI"
    secondaryPaneCaption="丫"
  )
    template(v-slot:sidebar)
      MindySidebar
    template(v-slot:sidebar-footer)
      MindySidebarFooter
    template(v-slot:primary-pane)
      MindyChatSpace
    template(v-slot:secondary-pane)
      MindyMindmapSpace

</template>