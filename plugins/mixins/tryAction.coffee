# A simpre "this.try" wrapper to execute some async code while setting a certain key to true while executing, setting it back to false when done, and showing an error message if the code throws an error
import _ from 'lodash'

export default

  data: ->

    busy: {}
    whilst: {}

  methods:

    actionPromise: (gerund) -> _.get @whilst, gerund, Promise.resolve()

    try: ( gerund, action, { oneAtATime, errorMessage, except, track = true, mixpanelProps } = {} ) ->

      if oneAtATime and _.get(@whilst, gerund)
        console.warn "Already #{gerund}; skipping"
        return _.get(@whilst, gerund)
      
      if track
        { mixpanel } = @

      @$set @busy, gerund, true
      resolve = null
      reject = null
      _.set @whilst, gerund, new Promise (res, rej) ->
        resolve = res
        reject = rej
      try
        console.log "Started #{gerund}"
        mixpanel?.track "#{gerund} started", mixpanelProps
        resolve result = await action.call(@)
        mixpanel?.track "#{gerund} succeeded", mixpanelProps
        return result
      catch error
        console.error "Error while #{gerund}: #{error}"
        mixpanel?.track "#{gerund} failed", { error: error.message, ...mixpanelProps }
        # If errorMessage is a function, call it with the error as argument
        if typeof errorMessage is 'function'
          errorMessage = errorMessage(error)
        @alert errorMessage
        except? error
        reject error
      finally
        @$set @busy, gerund, false
        _.unset @whilst, gerund
        console.log "Finished #{gerund}"

    alert: (errorMessage='Something went wrong.') ->
      @$bvToast.toast 'See console for error details.',
        title: errorMessage
        variant: 'danger'
        solid: true
        autoHideDelay: 5000