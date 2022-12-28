import TreeLike from '~/plugins/treeLike'

export default ( messages, routedMessage, vm ) ->

  @routedMessage = routedMessage

  @tree = new TreeLike messages, { vm }

  @thread = @tree.thread?( @routedMessage )

  @rootMessage = @thread?[0]

  @firstMessageWithContext = @thread?.find (m) -> m.context

  @id = @rootMessage?.id

  @title = @firstMessageWithContext?.context.split('\n')[0]?.trim() ? "Chat #{ @id }"

  return @