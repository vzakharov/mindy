import configs from './skeleton'

configs.chatTitle = -> {
  specs:
    returns:
      title: 'Succint (max 4 words) title summarizing the content. Required.'
      isGibberish: 'Whether the content is gibberish. Required.'
}

configs.freeAssociations = -> {
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