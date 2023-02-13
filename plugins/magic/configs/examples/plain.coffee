import { seed } from '~/plugins/magic/utils'
import markmap from '~/plugins/markmap'
import { rbsToMindmap } from '~/plugins/mindmapUtils'

# import examples from './backbone'
import configs from '../skeleton'

# # export firstPlainReplyExample = {
# examples.reply.plain.firstTime = firstPlainReplyExample = {
# _.set configs, 'reply.plain.firstTime.examples', [ firstPlainReplyExample =
configs.reply.firstTime.examples.push firstPlainReplyExample =
  input: {
    ...seed(),
    query: 'Meaning of life'
  }
  output:
    thoughts: 'Going all philosophical on me? Let me give a serious answer, but dilute it with some humor. Just a mindmap, no need for a code snippet or text.'
    mindmap:
      root: 'Meaning of life'
      branches: [
        'Finding joy'
        'Growing your understanding'
        'Connecting with others'
        '42'
      ]
      subbranches: [
        []
        []
        [
          'Supporting each other'
          'Exploring the world together'
        ]
        [
          '(See Hitchhiker’s Guide to the Galaxy)'
        ]
      ]
    content: null
    reply: "The meaning of life is **finding joy** in the little things, **growing your understanding** of the world around you, and **connecting with others** by **supporting each other** and **exploring the world together**.\n\nOh, and it’s also **42** ;-)"

# # export plainToPlainReplyExample = {
# examples.reply.plain.continued = plainToPlainReplyExample = {
# _.set configs, 'reply.plain.continued.examples', [ plainToPlainReplyExample =
configs.reply.continued.examples.push plainToPlainReplyExample =
  input: {
    ...seed(),
    precedingConversation: [{
      query: firstPlainReplyExample.input.query
      reply: firstPlainReplyExample.output.reply
    }]
    markmap: markmap.dump rbsToMindmap firstPlainReplyExample.output.mindmap
    currentContent: null
    query: '42?'
  }
  output:
    thoughts: 'Oh, I guess they didn’t get the reference. Let me add some more context to the mindmap.'
    markmap: """
      #{markmap}
      ### Hitchhiker’s Guide to the Galaxy
      #### Douglas Adams, 1979
      #### Classic of humor and science fiction
      #### The answer to the ultimate question of life, the universe, and everything is 42
    """
    content: null
    reply: "Oh. That’s a reference to Douglas Adams’s classic humor/science fiction novel, *Hitchhiker’s Guide to the Galaxy*.\n\nIt says the answer to the ultimate question of life, the universe, and everything is 42."