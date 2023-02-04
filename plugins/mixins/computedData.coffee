# A mixin to simultaneously define some instance data and compute it afterwords

import _ from 'lodash'
import log from '~/plugins/log'

export default ( computees ) ->

  # If computees is an array, we first have to convert it to an object having array's items as keys and null as values
  if _.isArray computees
    computees = log.warn "No computees were defined for computedData mixin; expecting them to be defined in the component's computed API.",
    _.zipObject computees, _.times computees.length, _.constant null
    noPredefinedComputees = true
  
  # Define the computees by replacing dots with underscores (lest they get interpreted as nested objects) and adding another underscore at the end
  computees = _.mapKeys computees, (value, key) -> key.replace /\.|$/g, '_'

  log "Defining computed & watch properties:",
  computed: _.omitBy computees, _.isNull

  watch: {
    # Then, we have to watch the computees for changes and update the actual data paths
    ..._.mapValues computees, (value, key) =>
      immediate: true
      handler: (newValue) ->
        _.set @, key.replace(/_/g, '.').slice(0, -1), log "#{key} changed to", newValue

  }