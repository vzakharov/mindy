# Config for further replies of the bot, if there was text generated so far

import _ from 'lodash'
import { plainWithoutExamples } from './plain'
import { seed } from '~/plugins/magic/utils'
import { markmap as codeMarkmap } from './withCode'

export default -> _.merge plainWithoutExamples(),
  specs:
    accepts:
      text: "Currently generated text."
  examples: [{
      # First example, text to text
      input: {
        ...seed()
        previousExchange: [
          query: 'Write a blog post about bootstrapping a startup'
          reply: 'Oh, about to start **something amazing** are we?\n\nSure, here’s some intro and outline to get you started — click the **Expand button** if you want me to go into more detail.\n\nOh, and I also made a **mindmap** to help you organize your thoughts.'
        ]
        markmap: """
          # Bootstrapping a startup
          ## Advantages
          ### Be your own boss
          ### No stress from investors
          ### Learn a lot
          ## Challenges
          ### Need some money
          ### Can’t 100% focus on the product
          ### Can feel lonely
          ## Tips
          ### Start small
          ### Focus on one thing
          ### Don’t give up
        """
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
      }
      output: {
        thoughts: "Okay, so being your own boss, having no stress from investors and learning a lot; let’s fill in the blanks."
        content:
          type: 'text'
          language: 'markdown'
          title: 'Bootstrapping a startup (a blog post)'
        reply: "Sure, let’s dive into the **advantages**, i.e.:\n\n* Being your **own boss**\n* **No stress** from investors\n* **Learning** a lot. I will add some details to each of those points."
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
      }
  }, {
    # Second example, text to code
    input: {
      ...seed()
      previousExchange: [
        query: 'Cheatsheet on binary search'
        reply: 'Sure, here’s a quick cheatsheet to get you started!'
      ]
      markmap: markmap = """
        # Binary search
        ## Basic idea
        ### Sorted array
        ### Compare target to middle element
        ### Eliminate half
        ### Repeat
        ## Advantages
        ### Fast
        ### Easy to implement
        ## Disadvantages
        ### Only works on sorted arrays
        ### Can be slow on large arrays
      """
      text: """
        # Binary search

        **Binary search** is a search algorithm that finds the position of a target value within a **sorted array**. Binary search **compares the target value to the middle element** of the array. If they are not equal, the half in which the target cannot lie is eliminated and the **search continues on the remaining half**, again taking the middle element to compare to the target value, and **repeating this until the target value is found**.

        ## Advantages

        [...advantages]

        ## Disadvantages

        [...disadvantages]

        ## See also

        [...see also]
      """
      query: 'Can you write this in JavaScript?'
    }
    output: {
      thoughts: "I think I can do that."
      content:
        type: 'code'
        language: 'javascript'
        title: 'Binary search algorithm (JavaScript)'
      reply: "Sure, here’s the code."
      markmap: """
        #{markmap}
        ## JavaScript code
      """
    }
  }]
