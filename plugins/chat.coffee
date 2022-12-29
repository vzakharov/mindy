import TreeLike from '~/plugins/treeLike'

export default ( messages, routedMessage, vm ) ->

  @routedMessage = routedMessage

  @tree = new TreeLike messages, { vm }

  @thread = @tree.thread?( @routedMessage )

  @rootMessage = @thread?[0]

  @messages = @tree.descendants( @rootMessage )

  @lastMessageWithContext = _.findLast @thread, (m) -> m.context

  @id = @rootMessage?.id

  @title = @lastMessageWithContext?.context.split('\n')[0]?.trim() ? "Chat #{ @id }"

  console.debug "Created Chat with:", @