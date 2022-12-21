# A simpre "this.try" wrapper to execute some async code while setting a certain key to true while executing, setting it back to false when done, and showing an error message if the code throws an error
export default

  data: ->

    whilst: {}

  methods:

    actionPromise: (stateKey) -> @whilst[stateKey] ? Promise.resolve()

    try: ( stateKey, action, { errorMessage, except, track = true, mixpanelProps } = {} ) ->
      
      if track
        { mixpanel } = @

      @[stateKey] = true
      resolve = null
      reject = null
      @whilst[stateKey] = new Promise (res, rej) ->
        resolve = res
        reject = rej
      try
        console.log "Started #{stateKey}"
        mixpanel?.track "#{stateKey} started", mixpanelProps
        resolve result = await action.call(@)
        mixpanel?.track "#{stateKey} succeeded", mixpanelProps
        return result
      catch error
        console.error "Error while #{stateKey}: #{error}"
        mixpanel?.track "#{stateKey} failed", { error: error.message, ...mixpanelProps }
        # If errorMessage is a function, call it with the error as argument
        if typeof errorMessage is 'function'
          errorMessage = errorMessage(error)
        @alert errorMessage
        except? error
        reject error
      finally
        @[stateKey] = false
        console.log "Finished #{stateKey}"

    alert: (errorMessage='Something went wrong.') ->
      @$bvToast.toast 'See console for error details.',
        title: errorMessage
        variant: 'danger'
        solid: true
        autoHideDelay: 5000