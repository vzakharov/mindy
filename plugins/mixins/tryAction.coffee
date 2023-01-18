# A simpre "this.try" wrapper to execute some async code while setting a certain key to true while executing, setting it back to false when done, and showing an error message if the code throws an error
import _ from 'lodash'

export default

  data: ->

    whilst: {}

  methods:

    actionPromise: (statePath) -> _.get @whilst, statePath, Promise.resolve()

    try: ( statePath, action, { oneAtATime, errorMessage, except, track = true, mixpanelProps } = {} ) ->

      if oneAtATime and _.get(@whilst, statePath)
        console.warn "Already #{statePath}; skipping"
        return _.get(@whilst, statePath)
      
      if track
        { mixpanel } = @

      _.set @, statePath, true
      resolve = null
      reject = null
      _.set @, statePath, new Promise (res, rej) ->
        resolve = res
        reject = rej
      try
        console.log "Started #{statePath}"
        mixpanel?.track "#{statePath} started", mixpanelProps
        resolve result = await action.call(@)
        mixpanel?.track "#{statePath} succeeded", mixpanelProps
        return result
      catch error
        console.error "Error while #{statePath}: #{error}"
        mixpanel?.track "#{statePath} failed", { error: error.message, ...mixpanelProps }
        # If errorMessage is a function, call it with the error as argument
        if typeof errorMessage is 'function'
          errorMessage = errorMessage(error)
        @alert errorMessage
        except? error
        reject error
      finally
        _.set @, statePath, false
        _.unset @, statePath
        console.log "Finished #{statePath}"

    alert: (errorMessage='Something went wrong.') ->
      @$bvToast.toast 'See console for error details.',
        title: errorMessage
        variant: 'danger'
        solid: true
        autoHideDelay: 5000