<template lang="pug">
  //- Palette picker: a list of several themes, each with a name and a list of colors
  div.d-flex.flex-column
    div.d-flex.flex-row.align-items-stretch.mb-2(v-for="theme in themes")
      //- Theme name
      div.flex-grow-1
        b-button(variant="outline-secondary" size="sm" block
          @click="emitTheme(theme)"
        )
          | {{ theme.name }}
      //- Theme colors
      div.d-flex.flex-row.flex-wrap.justify-content-center
        div(
          v-for="color in theme.colors"
          :style="{ backgroundColor: color, width: '2em', height: '100%' }"
        )
</template>

<script lang="coffee">

  export default

    data: ->
    
      themes: [{ 
        name: 'flat'
        colors: ['#1abc9c', '#2ecc71', '#3498db', '#9b59b6', '#34495e', '#f1c40f', '#e67e22', '#e74c3c', '#ecf0f1', '#95a5a6', '#f39c12', '#d35400']
      }, {
        name: 'material'
        colors: ['#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4', '#009688', '#4CAF50', '#8BC34A', '#CDDC39']
      }, {
        name: 'metro'
        colors: ['#8E8E8E', '#00ABA9', '#F09609', '#7CBB00', '#F17601', '#F8C300', '#F05D23', '#E00122', '#68768A', '#CA5010', '#8E8E93', '#5E7C85']
      }, {
        name: 'office'
        colors: ['#D11C24', '#F68E1E', '#FFC800', '#0B6E48', '#00A4A7', '#2D1F90', '#95B9C7', '#7E57C2', '#FFBE2E', '#BC9C30', '#BCD8C3', '#DAE5E1']
      }, {
        name: 'grayscale'
        colors: ['#222222', '#4D4D4D', '#666666', '#808080', '#999999', '#B3B3B3', '#CCCCCC', '#E6E6E6', '#EEEEEE', '#F5F5F5', '#FFFFFF', '#BFBFBF']
      }, {
        name: 'pastel'
        colors: ['#F49AC2', '#FFD1DC', '#F5D0CC', '#F5F4C1', '#D0F5CC', '#D0F5F5', '#D0D0F5', '#F5D0F5', '#F5D0D0', '#F9F9F9', '#CCCCCC', '#D3D3D3']
      }]

    methods:
      
      emitTheme: (theme) ->
        @$emit('input', theme)
    
</script>
