import TreeLike from '~/plugins/treeLike'
import yaml from 'js-yaml'

export default ( vm, routedMessage ) ->

  # console.debug "Creating Chat for vm", vm, "with routedMessage", routedMessage

  { @tree, @bot } = vm

  @routedMessage = routedMessage

  @thread = @tree.thread?( @routedMessage )

  # Like thread, but has an "input" from the user and an "output" from the bot
  # Do not include "bare" messages, i.e. ones without a response yet
  @exchanges = @thread?.filter ({ user: { isBot }, id }) => not isBot and @tree.hasChildren({ id })
    .map (message) =>
      response = @thread?.find (m) => @tree.parent(m) is message

      input: { query: message.content }
      output:
        thoughts: response?.context?.thoughts
        reply: response?.content
        mindmap: yaml.dump response?.context?.mindmap ? response?.context
  
  @exchanges ?= []

  @firstMessage = _.first @thread

  @lastMessage = _.last @thread

  @messages = @tree.descendants( @firstMessage ) || []

  @id = @firstMessage?.id

  @title = @firstMessage?.title ? if @id then "Chat ##{@id}" else "New Chat"

  @lastMessageWithContext = _.findLast @thread, (m) -> m.context

  @