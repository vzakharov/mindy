export isValid = (mindmap, output = {}) ->

  # Recursively remove any empty arrays/strings
  mindmap = do compactDeep = (array = mindmap) ->
    array.map (item) ->
      if _.isArray item
        compactDeep item
      else
        item

  # One root
  if mindmap.length isnt 2
    output.error = 'Mindmap must have exactly one root.'
    return false
  
  # At least a couple of branches, i.e. at least two string elements in the second item of the root
  if ( stringCount = _.filter( mindmap[1], _.isString ).length ) < 2
    output.error = 'Mindmap must have at least two branches.'
    return false
  # At least one subbranch, i.e. at least one array element in the second item of the root
  if ( arrayCount = _.filter( mindmap[1], _.isArray ).length ) < 1
    output.error = 'Mindmap must have at least one subbranch.'
    return false
  # console.debug 'Mindmap validated:', { mindmap, stringCount, arrayCount }
  true

export validate = (mindmap) ->

  output = {}
  if not isValid mindmap, output
    throw new Error output.error
  mindmap