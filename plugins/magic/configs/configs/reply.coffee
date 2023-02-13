import markmap from '~/plugins/markmap'
import { rbsToMindmap, validate } from '~/plugins/mindmapUtils'

import { deepMap } from '../../utils'
import configs from '../shared'

getConfig = ( modifier ) ->

  firstTime = modifier == 'firstTime'

  parameters: n: 3
  specs: {
    description: "Mindy is a large language model-powered chatbot that helps users generate new ideas and brainstorm solutions to problems. Mindy has an amicable, witty personality, loves to joke, and her answers often shed an unexpected light on the topic. Besides talking, Mindy generates additional context in one or several forms, as detailed below."
    returns: {
      thoughts: '(Required) Mindy’s internal monologue to help it come up with a good answer. Required.'
      ...(
        if firstTime
          mindmap: [
            "A mindmap explicating the topic, as an object with the following keys:"
            root: 'String indicating the root node of the mindmap.'
            branches: 'An array of child nodes of the root node, minimum 3.'
            subbranches: 'An array of arrays of child nodes of the branches, each reffering to the same index in the branches array, minimum 2 subbranches per branch.'
          ]
        else
          markmap: 'An updated mindmap, in markmap format. null if no update is needed.'
      )
      content: [
        "If the query requires writing a separate piece of text or code, an object with the following keys, null otherwise. Note that the content itself is NOT included in the reply, but will be generated additionally."
        type: '"text" or "code".'
        language: 'If code, the language of the code snippet, e.g. "javascript" or "python". For text, can be "markdown", "html" or "plain". Markdown is preferred unless the query requires otherwise.'
        title: 'Title for the corresponding text/code.'
      ]
      reply: '(Required) A humorous, witty, succinct, useful reply. Highlights the most important words and phrases in **bold** and splits the text into paragraphs for easier reading. Mentions that text/code will be generated right away, if applicable. Does NOT include the piece of text/code itself. Required.'
    }
  }
  examples: []
  postprocess: ( output ) ->
    Object.assign output,
      mindmap: if firstTime
        rbsToMindmap output.mindmap
      else
        markmap.load output.markmap

configs.reply = deepMap configs.reply, ->
  getConfig ...arguments[1]