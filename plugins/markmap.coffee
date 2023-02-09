# Converts markmap to/from a nested array of strings
import { validate } from '~/plugins/mindmapAsNestedArray'

export default

  dump: ( array ) ->

    # At the input, we have the following nested array (for the above example):
    # ['Root', ['Child 1', 'Child 2', ['Grandchild 1'], 'Child 3']]
    # 
    # At the output, we want a string of the following form:
    # ```
    # # Root
    # ## Child 1
    # ## Child 2
    # ### Grandchild 1
    # ## Child 3
    # ```
    # etc., i.e. a tree of markdown-style headings

    do convert = ( array, level = 1 ) ->
      array.map ( item ) ->
        if typeof item is 'string'
          "#{'#'.repeat level} #{item}"
        else
          convert item, level + 1
      .join '\n'
  # 

  load: ( string ) ->

    console.debug 'Markmap loading\n', string

    prefixForLevel = ( level ) -> "#{'#'.repeat level} "

    do convert = ( lines = string.split('\n'), level = 1 ) ->

      console.debug 'Converting\n', lines, level

      array = []
      index = 0
      while line = lines[index]
        if not line.startsWith '#'
          throw new Error "Line #{index} does not start with a hash: #{string}"
        else
          if line.startsWith(prefixForLevel level)
            array.push line.slice level + 1
          else if line.startsWith(prefixForLevel level + 1)
            array.push subarray = convert lines.slice(index), level + 1
            index += subarray.flat(Infinity).length - 1
          else
            break
        index++
      
      console.debug 'Converted\n', array, level

      array
  # 

  validate: (mindmap) ->

    # Recursively remove any empty arrays/strings
    mindmap = do compactDeep = (array = mindmap) ->
      array.map (item) ->
        if _.isArray item
          compactDeep item
        else
          item

    # One root
    if mindmap.length isnt 2
      throw new Error 'Mindmap must have exactly one root.'

  
    # At least a couple of branches, i.e. at least two string elements in the second item of the root
    if ( stringCount = _.filter( mindmap[1], _.isString ).length ) < 2
      throw new Error 'Mindmap must have at least two branches.'
    # At least one subbranch, i.e. at least one array element in the second item of the root
    if ( arrayCount = _.filter( mindmap[1], _.isArray ).length ) < 1
      throw new Error 'Mindmap must have at least one subbranch.'
    console.debug 'Mindmap validated:', { mindmap, stringCount, arrayCount }
    mindmap
