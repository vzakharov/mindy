import yaml from 'js-yaml'

export default ({ prefix, keys, format = 'json' } = {}) ->

  # parsing/dumping; format can be 'json' or 'yaml'
  if format is 'yaml'
    parse = yaml.load
    dump = yaml.dump
  else
    parse = JSON.parse
    dump = JSON.stringify

  loaded = false
  resolve = null

  getLocalKey = (key) -> if prefix then "#{prefix}.#{key}" else key

  data: ->

    localLoaded: new Promise ( res ) -> resolve = res

  mounted: ->

    keys.forEach ( key ) =>

      localValue = localStorage.getItem(getLocalKey(key))
      defaultValue = @[key]

      console.log key: key, localValue: localValue, defaultValue: defaultValue

      isObject = typeof defaultValue is 'object' and defaultValue isnt null
      isArray = Array.isArray defaultValue
      isNumber = typeof defaultValue is 'number'
      if isObject
        # localValue = JSON.parse(localValue or null)
        localValue = parse(localValue or null)
      else if isNumber
        localValue = parseFloat(localValue or null)
      else
        localValue = localValue or null

      @[key] = if isObject and not isArray
        {...defaultValue, ...localValue}
      else
        localValue or defaultValue

    @$nextTick ->
      loaded = true
      resolve()
  
  watch: {

    ...keys.reduce ( watch, key ) ->

      Object.assign watch,
        [key]:
          deep: true
          handler: (value) ->
            if loaded
              localKey = getLocalKey(key)
              console.log "Syncing #{key} to local storage key #{localKey}"
              localStorage.setItem(localKey, if typeof value is 'object' then dump(value) else value)

    , {}

  }