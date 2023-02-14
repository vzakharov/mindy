import { seed } from '~/plugins/magic/utils'
import markmap from '~/plugins/markmap'
import { rbsToMindmap } from '~/plugins/mindmapUtils'
import _ from 'lodash'

# import examples from './backbone'
import configs from '../shared'

# # # export firstTextReplyExample =
# # examples.reply.text.firstTime = firstTextReplyExample =
# _.set configs, 'reply.text.firstTime.examples', [ firstTextReplyExample =
configs.reply.firstTime.examples.push firstTextReplyExample =
  input: {
    ...seed()
    query: 'Write a blog post about bootstrapping a startup'
  }
  output:
    thoughts: 'A blog post, huh? Let me generate a text and a mindmap to help the user get started.'
    mindmap:
      root: 'Bootstrapping a startup'
      branches: [
        'Advantages'
        'Challenges'
        'Tips'
      ]
      subbranches: [
        [
          'Be your own boss'
          'No stress from investors'
          'Learn a lot'
        ]
        [
          'Need some money'
          'Can’t 100% focus on the product'
          'Can feel lonely'
        ]
        [
          'Start small'
          'Focus on one thing'
          'Don’t give up'
        ]
      ]
    content:
      type: 'text'
      language: 'markdown'        
      title: 'Bootstrapping a startup (a blog post)'
    reply: "Oh, about to start **something amazing** are we?\n\nSure, here’s some intro and outline to get you started — click on corresponding **Expand** buttons if you want me to go into more detail.\n\nOh, and I also made a **mindmap** to help you organize your thoughts."

# # # export firstTextExample =
# # examples.generate.text.firstTime = firstTextExample =
# _.set configs, 'generate.text.firstTime.examples', [ firstTextExample =
configs.generate.text.firstTime.examples.push firstTextExample =
  input:
    conversation: [{
      query: firstTextReplyExample.input.query
      reply: firstTextReplyExample.output.reply
    }]
    markmap: markmap.dump rbsToMindmap firstTextReplyExample.output.mindmap
    requestedContent: firstTextReplyExample.output.content
  output:
    text: """
      # To bootstrap or not to bootstrap: Building a startup from scratch in #{new Date().getFullYear()}

      *Starting a business from scratch can be a daunting task, especially in today's fast-paced, highly competitive economy. One of the biggest decisions entrepreneurs must make is whether to bootstrap their startup or seek out outside funding. In this article, we'll explore the pros and cons of bootstrapping a startup, and give you some tips on how to bootstrap your own business.*

      ## Advantages of bootstrapping a startup

      [...advantages]

      ## Challenges of bootstrapping a startup

      [...challenges]

      ## Tips for bootstrapping a startup

      [...tips]

      ## Takeaways

      [...takeaways]
    """

# # # export plainToTextReplyExample =
# # examples.reply.text.continued= plainToTextReplyExample =
# _.set configs, 'reply.text.continued.examples', [ plainToTextReplyExample = 
configs.reply.continued.examples.push plainToTextReplyExample =
  input: {
    ...seed()
    precedingConversation: [{
      query: 'Bootstrapping a startup'
      reply: """
        Oh, about to start **something amazing** are we? Bootstrapping a startup has its advantages and challenges, let me quickly summarize them for you:

        * **Advantages**:
          * You can **be your own boss**.
          * There’s **no stress from investors**.
          * You can **learn a lot**.

        * **Challenges**:
          * You’ll **need some money** to start.
          * You **can’t 100% focus on the product**.
          * Bootstrapping **can feel lonely**.

        If I were to give you some **tips** on how to bootstrap a startup, I’d suggest that you **start small**, **focus on one thing** and **don’t give up**.
      """
    }]
    markmap: firstTextExample.input.markmap
    currentContent: null
    query: 'Can you turn this into a blog post?'
  }
  output:
    thoughts: 'With the mindmap at hand, I can easily turn this into a blog post. No need to update the mindmap itself.'
    markmap: firstTextExample.input.markmap
    content: firstTextExample.input.requestedContent
    reply: """
      Sure, I can turn this into a blog post based on the mindmap. Give me a second.
    """

# # # export plainToTextExample =
# # examples.generate.text.continued = plainToTextExample =
# _.set configs, 'generate.text.continued.examples', [ plainToTextExample =
configs.generate.text.continued.examples.push plainToTextExample =
  input:
    conversation: [
      ...firstTextExample.input.conversation
      {
        query: plainToTextReplyExample.input.query
        reply: plainToTextReplyExample.output.reply
      }
    ]
    markmap: plainToTextReplyExample.output.markmap
    currentContent: null
    requestedContent: plainToTextReplyExample.output.content
  output:
    text: firstTextExample.output.text

# # # export textToTextReplyExample =
# # examples.reply.text.fromText = textToTextReplyExample =
# _.set configs, 'reply.text.fromText.examples', [ textToTextReplyExample =
configs.reply.fromText.examples.push textToTextReplyExample =
  input: {
    ...seed()
    precedingConversation: firstTextExample.input.conversation
    markmap: firstTextExample.input.markmap
    currentContent: firstTextExample.input.requestedContent
    text: firstTextExample.output.text
    query: 'Expand advantages'
  }
  output:
    thoughts: 'Okay, so being your own boss, having no stress from investors and learning a lot; let’s fill in the blanks.'
    markmap: """
      # Bootstrapping a startup
      ## Advantages
      ### Be your own boss
      #### Freedom to do what you want
      #### No corporate politics
      #### Flexibility
      ### No stress from investors
      #### No pressure to grow fast
      #### Focus on the product
      #### What you earn is yours
      ### Learn a lot
      #### Marketing
      #### Sales
      #### Customer support
      ## Challenges
      ### Need some money
      ### Can’t 100% focus on the product
      ### Can feel lonely
      ## Tips
      ### Start small
      ### Focus on one thing
      ### Don’t give up
    """
    content:
      type: 'text'
      language: 'markdown'
      title: 'Bootstrapping a startup (a blog post)'
    reply: """
      Sure, let’s dive into the **advantages**, i.e.:

      * Being your **own boss**
      * **No stress** from investors
      * **Learning** a lot.

      I will add some details to each of those points.
    """

# # # export textToTextExample =
# # examples.generate.text.fromText = textToTextExample =
# _.set configs, 'generate.text.fromText.examples', [ textToTextExample =
configs.generate.text.fromText.examples.push textToTextExample =
  input:
    conversation: [
      ...firstTextExample.input.conversation
      {
        query: textToTextReplyExample.input.query
        reply: textToTextReplyExample.output.reply
      }
    ]
    markmap: textToTextReplyExample.output.markmap
    currentContent: textToTextReplyExample.input.currentContent
    currentText: textToTextReplyExample.input.text
    requestedContent: textToTextReplyExample.output.content
  output:
    text: """
      # To bootstrap or not to bootstrap: Building a startup from scratch in #{new Date().getFullYear()}

      *Starting a business from scratch can be a daunting task, especially in today's fast-paced, highly competitive economy. One of the biggest decisions entrepreneurs must make is whether to bootstrap their startup or seek out outside funding. In this article, we'll explore the pros and cons of bootstrapping a startup, and give you some tips on how to bootstrap your own business.*

      ## Advantages of bootstrapping a startup

      ### Be your own boss

      Unlike working for a company, you are your own boss when you start a business. This means:

      * You have **freedom** to do what you want, when you want.

      * You don’t have to deal with **corporate politics**.

      * You have **flexibility** to work from home, take time off, or work on other projects.

      [...be your own boss]

      ### No stress from investors

      Pleasing investors is a huge stress for many startups. When you bootstrap your business, you don’t have to worry about investors. So:

      * You don’t have to **grow fast** to please investors.

      * You can **focus** on the product, not on raising money.

      * What you earn is **yours**.

      [...no stress from investors]

      ### Learn a lot

      When you bootstrap your business, you learn a lot about:

      * **Marketing**, from creating a website to running ads.

      * **Sales**, from cold calling to closing deals.

      * **Customer support**, from answering emails to fixing bugs.

      [...learn a lot]

      ## Challenges of bootstrapping a startup

      [...challenges]

      ## Tips for bootstrapping a startup

      [...tips]

      ## Takeaways

      [...takeaways]
    """