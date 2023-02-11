# Update code from previously generated code
import _ from 'lodash'

import write from '..'

export default -> _.merge write( 'code', 'code'),
  examples: [
    {
      input: {
        previousExchange: [
          {
            query: 'Write a binary search algorithm'
            reply: """
              Sure, take a look at this JavaScript code snippet. It’s a binary search algorithm, which is a **divide and conquer** algorithm that searches for an element in a **sorted array** by repeatedly **dividing the search interval in half**.
              
              While it’s **fast** and **easy to implement**, it only works on sorted arrays, so if you need to search for an element in an unsorted array, you’ll have to use a different algorithm.
              
              Ping me if you need help with that!
            """
          }, {
            query: 'Can you rewrite it in Python?'
            reply: 'Sure, here you go!'
          }
        ]
        markmap: """
          # Binary search
          ## Principle
          ### Divide and conquer
          ### Sorted array
          ### Dividing the search interval in half
          ## Benefits
          ### Fast
          ### Easy to implement
          ## Drawbacks
          ### Only works on sorted arrays
          ## Python code
        """
      }
    }