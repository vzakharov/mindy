# A simpre "this.try" wrapper to execute some async code while setting a certain key to true while executing, setting it back to false when done, and showing an error message if the code throws an error

export default

  methods:

    try: ( stateKey, action, { errorMessage, catcher } = {} ) ->
      @[stateKey] = true
      try
        console.log "Started #{stateKey}"
        await action()
      catch error
        console.error "Error while #{stateKey}: #{error}"
        # If errorMessage is a function, call it with the error as argument
        if typeof errorMessage is 'function'
          errorMessage = errorMessage(error)
        @alert error, errorMessage
        catcher?(error)
      finally
        @[stateKey] = false
        console.log "Finished #{stateKey}"

    alert: (error, errorMessage='Something went wrong, please try again.') ->
      @$bvToast.toast 'See console for error details.',
        title: errorMessage
        variant: 'danger'
        solid: true
        autoHideDelay: 5000