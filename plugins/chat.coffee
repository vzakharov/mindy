import TreeLike from '~/plugins/treeLike'
import yaml from 'js-yaml'

export default ( vm, routedMessage ) ->

  # console.debug "Creating Chat for vm", vm, "with routedMessage", routedMessage

  { @tree } = vm

  @routedMessage = routedMessage

  @thread = @tree.thread?( @routedMessage )
  @threadAbove = @tree.thread?( @routedMessage, { includeDescendants: false } )

  getExchanges = (thread) =>
    thread?.filter ({ user: { isBot }, id }) => not isBot and @tree.hasChildren({ id })
    .map (request) => {
      request
      response: thread.find (m) => @tree.parent(m) is request
    }
  
  getConversation = (exchanges) => exchanges?.map ({ request, response }) => {
    query: request?.content
    reply: response?.content
  }

  @conversation = getConversation getExchanges @thread
  @conversationAbove = getConversation getExchanges @threadAbove
  
  @exchanges ?= []

  @firstMessage = _.first @thread

  @lastMessage = _.last @thread

  @messages = @tree.descendants( @firstMessage ) || []

  @id = @firstMessage?.id

  @title = @firstMessage?.title ? if @id then "Chat ##{@id}" else "New Chat"

  @lastMessageWith = (path) -> _.findLast @thread, (message) -> _.has message, path

  @