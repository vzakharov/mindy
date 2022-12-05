# Plugin for handling any tree-likes data structures

import _ from 'lodash'

TreeLike = ( items, childOrder = [[ 'createdAt', 'desc' ]] ) ->
# childOrder takes the same format as _.orderBy starting from the second argument (see https://lodash.com/docs#orderBy)

  Object.assign this,

    items

    # Functions to get various items

    parent: (item) ->
      items.find (i) -> i.id is item.parentId

    children: (item) ->
      items.filter (child) -> child.parentId is item.id
    
    siblings: (item, includeSelf = true) ->
      _.orderBy(
        items.filter (sibling) -> sibling.parentId is item.parentId and (includeSelf or sibling isnt item),
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
    
    lineage: (item) ->
      [ item, ...@ancestors(item) ].reverse()
    
    heir: (item) ->
      # the first among children (sorted by ...childOrder), and so on recursively
      if @children(item).length
        @heir(_.orderBy(@children(item), ...childOrder)[0])
      else
        item

    thread: (item) ->
      # i.e. lineage of the ultimate heir
      @lineage(@heir(item))
    
    # Functions to manipulate the tree

    addChild: (item, child) ->
      items.push Object.assign child,
        parentId: item?.id
        # Id is the maximum id + 1
        id: _(items).map('id').max() + 1 or 1
        createdAt: new Date()
      items
      # ( We return items so that the caller can do `this.items = treeLike.addChild(...)`. This is useful if the caller is using Vue.js and wants to update the items in the Vue data. )

# export the TreeLike function
export default TreeLike