# Plugin for handling any tree-likes data structures

import _ from 'lodash'
import log from './log'

TreeLike = ( items, childOrder = [[ 'createdAt', 'desc' ]] ) ->
# childOrder takes the same format as _.orderBy starting from the second argument (see https://lodash.com/docs#orderBy)

  Object.assign @,

    items: items
    root: { id: 0 }
    # Note that root is not part of the items array, but acts as a parent for all items that have no parent id

    # Functions to get various items

    parent: (item) ->
      ( items.find (i) -> i.id is item.parentId ) or @root

    children: (item) ->
      items.filter (child) -> child.parentId is item.id
    
    siblings: (item, includeSelf = true) ->
      _.orderBy(
        items.filter (sibling) => @parent(sibling) is @parent(item) and ( includeSelf or sibling isnt item ),
        childOrder
      )
    
    numSiblings: (item, includeSelf = true) ->
      @siblings(item, includeSelf).length
    
    siblingIndex: (item) ->
      @siblings(item).indexOf(item)
    
    sibling: (item, increment = 1) ->
      index = @siblingIndex(item)
      index = (index + increment) % @numSiblings(item)
      while index < 0
        index += @numSiblings(item)
      @siblings(item)[index]
    
    nextSibling: (item) ->
      @sibling(item, 1)

    prevSibling: (item) ->
      @sibling(item, -1)

    ancestors: (item) ->
      if item.parentId
        [ @parent(item), ...@ancestors(@parent(item)) ]
      else
        []
    
    lineage: (item, includeSelf = true) ->
      lineage = [ ...@ancestors(item) ].reverse()
      lineage.push(item) if includeSelf
      # remove root
      if lineage[0] is @root
        lineage.shift()
      console.log { item, includeSelf, lineage }
      lineage
    
    heir: (item) ->
      # the first among children (sorted by ...childOrder), and so on recursively
      if @children(item).length
        @heir(_.orderBy(@children(item), ...childOrder)[0])
      else
        item

    thread: (item, includeDescendants = true) ->
      # i.e. lineage of the ultimate heir
      @lineage( if includeDescendants then @heir(item) else item )
    
    # Functions to manipulate the tree

    createChild: (item, child) ->
      # Note that this does NOT add the child to the items array, it just creates a child object:
      log { item }, Object.assign child,
        parentId: item?.id
        # Id is the maximum id + 1
        id: _(items).map('id').max() + 1 or 1
        createdAt: new Date()
    
    clone: (item) ->
      # Clone the item (without children) and add it as a child of the item's parent
      @createChild @parent(item), _.omit(item, 'id', 'createdAt')

# export the TreeLike function
export default TreeLike