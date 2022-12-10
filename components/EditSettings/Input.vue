<template lang="pug">

  //- A template for a single input within the EditSettingsModal
  b-form-group(
    v-bind="{ label }"
    :label-for="`edit-settings-modal-${id}`"
  )
    //- The input
    component(
      :is="inputTag"
      :id="`edit-settings-input-${id}`"
      v-model="setting"
      v-bind="inputProps"
    )

</template>

<script lang="coffee">

  import syncValueMixin from '~/plugins/mixins/syncValue'

  export default

    mixins: [
      syncValueMixin('setting')
    ]

    props: [ 'value', 'properties' ]

    computed:

      id: -> @$vnode.key

      label: -> @properties.label || @id

      inputTagAndProps: ->
        
        mapping =
          multiline: 
            tag: 'b-textarea'
            props:
              rows: Math.max( 10, Math.min( 20, @setting.split('\n').length ) )
              style: if @properties.monospace then 'font-family: monospace' else ''
              placeholder: @properties.placeholder or 'Enter text here'
          text:
            tag: 'b-input'
            props:
              type: 'text'
              placeholder: @properties.placeholder or 'Enter text here'
          number:
            tag: 'b-input'
            props:
              type: 'number'
              placeholder: @properties.placeholder or 'Enter a number here'
          boolean:
            tag: 'b-checkbox'
            props:
              switch: true

        if @properties.type
          mapping[ @properties.type ]
        else
          # If none, guess from the value type
          switch typeof @value
            when 'number'
              mapping.number
            when 'boolean'
              mapping.boolean
            else
              mapping.text
        
      inputTag: -> @inputTagAndProps.tag

      inputProps: -> @inputTagAndProps.props

</script>
