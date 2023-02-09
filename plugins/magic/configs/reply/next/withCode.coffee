# Config for further replies of the bot, if there was code generated so far

import _ from 'lodash'
import { plainWithoutExamples } from './plain'
import { seed } from '~/plugins/magic/utils'

previousExchange = [{
  query: 'Write a binary search algorithm'
  reply: 'Binary search? Pff, easy. I’ll generate a code snippet and a mindmap to help memorize the basic concepts. I’ll use vanilla JavaScript so that it can be run right in the browser.'
}]

markmap = """
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
"""

code = """
  // A function that searches for a target value in a sorted array
  function binarySearch(arr, target) {
  \tlet left = 0;
  \tlet right = arr.length - 1;
  \twhile (left <= right) {
  \t\tconst mid = Math.floor((left + right) / 2);
  \t\tif (arr[mid] === target) {
  \t\t\treturn mid;
  \t\t} else if (arr[mid] < target) {
  \t\t\tleft = mid + 1;
  \t\t} else {
  \t\t\tright = mid - 1;
  \t\t}
  \t}
  \treturn -1;
  }
"""

input = (query) ->
  input: {
    ...seed()
    previousExchange
    markmap
    code
    query
  }

export default -> _.merge plainWithoutExamples(),
  specs:
    accepts:
      code: "Currently generated code."
  examples: [{
    # First example, code to code
    ...input 'Convert to Python'
    output: {
      thoughts: 'Easy-peasy. I’ll convert the code to Python and add a funny remark.'
      content:
        type: 'code'
        language: 'python'
        title: 'Binary search (Python)'
      reply: 'Too many curly braces? I get that ;-) Here’s the code in Python.'
      markmap: """
        #{markmap}
        ## Python code
      """
    }
  }, {
    # Second example, code to text
    ...input 'Can you write a tweet explaining this?'
    output: {
      thoughts: 'Oh, fitting it all in 280 characters is going to be a challenge, but I’ll give it a shot.'
      content:
        type: 'text'
        language: 'plain'
      reply: 'Let’s win over some new followers! Here’s the tweet.'
      markmap: """
        #{markmap}
        ## Tweet
      """
    }
  }]