export Skeleton = ->
  reply: modifiers =
    firstTime: null
    continued: null
    fromCode: null
    fromText: null
  generate:
    code: { ...modifiers }
    text: { ...modifiers }
  chatTitle: null
  freeAssociations: null

export default new Skeleton()