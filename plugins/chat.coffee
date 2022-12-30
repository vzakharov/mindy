import TreeLike from '~/plugins/treeLike'

export default ( tree, routedMessage ) ->

  console.debug "Creating Chat with tree:", tree, "and routedMessage:", routedMessage
  @tree = tree

  @routedMessage = routedMessage

  @thread = @tree.thread?( @routedMessage )

  @rootMessage = @thread?[0]

  @messages = @tree.descendants( @rootMessage )

  @lastMessageWithContext = _.findLast @thread, (m) -> m.context

  @id = @rootMessage?.id

  @title = @lastMessageWithContext?.context.split('\n')[0]?.trim() ? "Chat #{ @id }"

  console.debug "Created Chat with:", @