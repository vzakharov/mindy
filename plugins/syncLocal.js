export default {

  mounted() {
    // Load all settings from localStorage and watch them afterwards
    for ( let key in this.settings ) {

      let localValue = localStorage.getItem( key )
      let defaultValue = this.settings[key]

      console.log({ key, localValue, defaultValue })
      
      // If the existing value is an object, we need to parse the localStorage value
      let isObject = typeof defaultValue === 'object'
      let isArray = Array.isArray( defaultValue )
      if ( isObject ) {
        localValue = JSON.parse( localValue || null )
      }

      this.settings[key] = 
        isObject && !isArray ?
          { ...defaultValue, ...localValue }
          : localValue || defaultValue

      this.$watch( 'settings.' + key, { deep: true, handler: value => {
        localStorage.setItem(key, isObject ? JSON.stringify(value) : value)
      }})
    }
  }

}