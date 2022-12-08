# Expose VM as window.vm1/2/3 at mounting

export default

  mounted: ->

    # console.log "exposeVM: key=#{key}, noIndexForFirstVM=#{noIndexForFirstVM}"
    if not window.vm
      window.vm = @
    else
      # Find the first available index for the VM
      index = 1
      while window["vm#{index}"]
        index++
      window["vm#{index}"] = @