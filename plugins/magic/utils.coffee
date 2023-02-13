export seed = ->
  { seed: _.random(100, 999) }

export lineMapper = (mapper) ->
  (text) ->
    text
    .split('\n')
    .map mapper
    .join '\n'

export addLineNumbers = lineMapper (line, index) ->
  "$#{index + 1} #{line}"

export removeLineNumbers = lineMapper (line) ->
  line.replace /^\$[0-9]+ /, ''

export newObject = () -> {}

export combinedMap = (generateCombinees, callback = newObject, path = []) ->
# Creates all possible combinations of the given arrays as a nested object and returns the result of calling the callback with each combination.
  if generateCombinees.length is 0
    callback( ...path )
  else
    options = generateCombinees[0]
    if not _.isArray options then options = [ options ] 
    _.mapValues (_.keyBy options, _.identity ),
      (option) -> combinedMap ...generateCombinees[1..], callback, [ ...path, option ]

export deepMap = (object, callback, path = []) ->
# Recursively maps the given object and returns the result of calling the callback with each value.
  _.mapValues object,
    (value, key) ->
      if _.isObject value
        deepMap value, callback, [ ...path, key ]
      else
        callback value, [ ...path, key ], object
