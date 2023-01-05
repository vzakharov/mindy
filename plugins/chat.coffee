import TreeLike from '~/plugins/treeLike'

export default ( vm, routedMessage ) ->

  console.debug "Creating Chat for vm", vm, "with routedMessage", routedMessage

  chat = @
  
  @tree = vm.tree

  @routedMessage = routedMessage

  @thread = @tree.thread?( @routedMessage )

  @firstMessage = _.first @thread
  
  @lastMessage = _.last @thread

  @messages = @tree.descendants( @firstMessage )

  @id = @firstMessage?.id

  @title = @firstMessage?.title ? if @id then "Chat ##{@id}" else "New Chat"

  @newMessage = ''

  @lastMessageWithContext = _.findLast @thread, (m) -> m.context

  console.debug "Created Chat with:", @