# Exports:
#  log: (args...) -> logs the args and returns the last arg, using console.debug
#  log.always: (args...) -> same, but using console.log
#  log.breakpoint: (args...) -> same as log, but adds a breakpoint (debugger statement) right after logging 


_log = ({ args, callback, logOrDebug = 'debug' } = {}) =>

  console[logOrDebug] ...args
  callback?()
  args[args.length - 1]

log = (...args) =>

  _log({ args })

log.breakpoint = (...args) =>

  _log({ args, callback: => debugger })

log.always = (...args) =>

  _log({ args, logOrDebug: 'log' })


export default log