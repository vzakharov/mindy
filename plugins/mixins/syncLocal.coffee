import yaml from 'js-yaml'
import log from '~/plugins/log'
import _ from 'lodash'

export default ({ prefix, keys, format = 'json' } = {}) ->

  log "Exporting syncLocal mixin with arguments: #{JSON.stringify(arguments[0])}"

  # parsing/dumping; format can be 'json' or 'yaml'
  if format is 'yaml'
    parse = yaml.load
    dump = yaml.dump
  else
    parse = JSON.parse
    dump = JSON.stringify

  resolve = null

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
  
  pathify = ( ...args ) -> args.filter(_.identity).join('.')

  log 'Using data paths:',
  dataPaths = keys.reduce ( paths, key ) ->

      if _.isArray(key)
        [ key, { dataPath } ] = key
      
      Object.assign paths, { [key]: pathify(dataPath, key) }

    , {}
  # (we'll be using this to understand where to put the data synced from local storage, and what to watch)

  log 'Converted keys back to plain strings:',
  keys = keys.map ( key ) -> if _.isArray(key) then key[0] else key
  # (converting keys to plain string after we've parsed all the options)

  log 'Using local keys:',
  localKeys = keys.reduce ( keys, key ) ->
      Object.assign keys, { [key]: pathify(prefix, key) }
    , {}

  data: ->

    syncLocal:
      promise: new Promise ( res ) -> resolve = res
      values: null
      loaded: false
      ignoreWatchers: []

  mounted: ->

    keys.forEach ( key ) =>

      log "Syncing key #{key} from local storage for component #{@$options.name}"

      log 'Local value:',
      localValue = window.localStorage.getItem(localKeys[key])
      dataPath = dataPaths[key]
      defaultValue = _.get( @, dataPath )
      if defaultValue is undefined then throw new Error "Default value for key `#{key}` does not exist at `#{dataPath}`"

      console.log key: key, localValue: localValue, defaultValue: defaultValue

      localValue = asSameTypeAs localValue, defaultValue

      _.set @, dataPath,
      log "Setting #{key} at #{dataPath} to:",
      if _.isObject(defaultValue) and not _.isArray(defaultValue)
        {...defaultValue, ...localValue}
      else
        localValue or defaultValue

    @$nextTick =>
      Object.assign @syncLocal,
        values: _.mapValues dataPaths, ( dataPath ) => _.get @, dataPath
        loaded: true
      resolve @syncLocal.values

  watch: {

    ...keys.reduce ( watch, key ) ->

      Object.assign watch,
        [key]:
          deep: true
          handler: (value) ->
            if !@syncLocal.loaded
              @syncLocal.ignoreWatchers.push key
            else
              localKey = localKeys[key]
              window.localStorage.setItem(localKey, if typeof value is 'object' then dump(value) else value)
              log "Saved #{key} to local storage as #{localKey}"
              @syncLocal.ignoreWatchers = _.without @syncLocal.ignoreWatchers, key

    , {}

  }