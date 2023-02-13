import TreeLike from '~/plugins/treeLike'
import yaml from 'js-yaml'

export default ( vm, routedMessage ) ->

  # console.debug "Creating Chat for vm", vm, "with routedMessage", routedMessage

  { @tree } = vm

  @routedMessage = routedMessage

  @thread = @tree.thread?( @routedMessage )

  # Like thread, but has an "input" from the user and an "output" from the bot
  # Do not include "bare" messages, i.e. ones without a response yet
  @exchanges = @thread?.filter ({ user: { isBot }, id }) => not isBot and @tree.hasChildren({ id })
    .map (request) => {
      request
      response: @thread?.find (m) => @tree.parent(m) is request
    }
  
  @conversation = @exchanges?.map ({ request, response }) => {
    query: request?.content
    reply: response?.content
  }
  
  @exchanges ?= []

  @firstMessage = _.first @thread

  @lastMessage = _.last @thread

  @messages = @tree.descendants( @firstMessage ) || []

  @id = @firstMessage?.id

  @title = @firstMessage?.title ? if @id then "Chat ##{@id}" else "New Chat"

  @lastMessageWith = (path) -> _.findLast @thread, (message) -> _.has message, path

  @