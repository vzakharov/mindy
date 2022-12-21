# Exports:
#  log: (args...) -> logs the args and returns the last arg, using console.debug
#  log.log: (args...) -> same, but using console.log
#  log.breakpoint: (args...) -> same as log, but adds a breakpoint (debugger statement) right after logging 

disable = false

_log = ({ args, callback, method = 'debug' } = {}) =>

  if not disable
    console[method] ...args
    callback?()
  args[args.length - 1]

log = (...args) =>

  _log({ args })

log.breakpoint = (...args) =>

  _log({ args, callback: => debugger })

[ 'log', 'warn', 'debug', 'error' ].forEach ( method ) ->

  log[method] = (...args) =>

    _log({ args, method })

log.disable = -> disable = true

export default log