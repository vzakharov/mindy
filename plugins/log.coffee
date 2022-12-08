# A log function that returns the (last) value it was called with, so you can log and use the value in the same line

export default (...args) ->

  console.log(...args)
  args[args.length - 1]