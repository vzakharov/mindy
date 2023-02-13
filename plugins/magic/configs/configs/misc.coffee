import _ from 'lodash'

import configs from '../shared'
import { seed } from '../../utils'

configs.chatTitle = {
  specs:
    returns:
      title: 'Succint (max 4 words) title summarizing the content. Required.'
      isGibberish: 'Whether the content is gibberish. Required.'
}

configs.freeAssociations = {
  parameters:
    temperature: 1
  specs:
    description: 'Generates a list of words or phrases related to the input in a quirky, funny, and unexpected way.'
    returns:
      associations: 'An array of at least 10 words or phrases, the first one related to the input and each subsequent one more and more absurd.'
  examples: [
    input: concept: 'object-oriented programming'
    output:
      associations: [
        'objects and classes'
        'class inheritance'
        'inherited money'
        'wish I had a rich uncle'
        'can an AI have a rich uncle?'
        'would he be an... AI-ncle?'
        'dad jokes'
        'am I a dad?'
        'am I a joke?'
        'am I a dead joke?'
      ]
  ]
}

configs.randomQuery = -> {
  parameters:
    temperature: 1
  specs:
    description: 'Generates a random query to ask an AI assistant.'
    returns: 'query'
  examples:
    _.sampleSize(
      if @chats.length > 5
        @chats
      else [
        "Startup ideas for someone who is not a programmer"
        "What is the meaning of life?"
        "I want to go on a vacation somewhere warm but not too expensive"
        "JavaScript vs TypeScript"
        "Top 5 movies of all time"
        "I'm just bored, what should I do?"
      ]
    , 2).map (item) =>
      input: seed()
      output: { query: item.firstMessage?.content || item }
}