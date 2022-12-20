import yaml from 'js-yaml'
import log from '~/plugins/log'
import _ from 'lodash'

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

  asSameTypeAs = ( value, defaultValue ) ->

    if typeof defaultValue is 'object' and defaultValue isnt null
      # localValue = JSON.parse(localValue or null)
      parse(value or null)
    else if typeof defaultValue is 'number'
      parseFloat(value or null)
    # if boolean, parse as boolean, unless it already is a boolean
    else if typeof defaultValue is 'boolean'
      if typeof value is 'boolean' then value else value is 'true'
    else
      value or null

  data: ->

    localLoaded: new Promise ( res ) -> resolve = res
    watchersToIgnore: []

  mounted: ->

    keys.forEach ( key ) =>

      localValue = localStorage.getItem(getLocalKey(key))
      defaultValue = @[key]

      console.log key: key, localValue: localValue, defaultValue: defaultValue

      localValue = asSameTypeAs localValue, defaultValue

      @[key] = if _.isObject(defaultValue) and not _.isArray(defaultValue)
        {...defaultValue, ...localValue}
      else
        localValue or defaultValue

      console.log @[key]

    @$nextTick =>
      loaded = true
      resolve keys.reduce ( obj, key ) => Object.assign obj, [key]: @[key], {}

  watch: {

    ...keys.reduce ( watch, key ) ->

      Object.assign watch,
        [key]:
          deep: true
          handler: (value) ->
            if !loaded
              @watchersToIgnore.push key
            else
              localKey = getLocalKey(key)
              localStorage.setItem(localKey, if typeof value is 'object' then dump(value) else value)
              log "Saved #{key} to local storage as #{localKey}"
              @watchersToIgnore = _.without @watchersToIgnore, key

    , {}

  }