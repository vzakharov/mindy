import _ from 'lodash'

import { seed } from '~/plugins/magic/utils'

# import examples from './backbone'
import configs from '../skeleton'

# # export firstCodeReplyExample =
# examples.reply.code.firstTime = firstCodeReplyExample =
# _.set configs, 'reply.code.firstTime.examples', [ firstCodeReplyExample =
configs.reply.firstTime.examples.push firstCodeReplyExample =
  input: {
    ...seed()
    query: "Write a binary search algorithm"
  }
  output:
    thoughts: "Binary search? Pff, easy. I’ll generate a code snippet and a mindmap to help memorize the basic concepts. I’ll use vanilla JavaScript so that it can be run right in the browser."
    mindmap: {
      root: 'Binary search'
      branches: [
        'Principle'
        'Benefits'
        'Drawbacks'
      ]
      subbranches: [
        [
          'Divide and conquer'
          'Sorted array'
          'Dividing the search interval in half'
        ]
        [
          'Fast'
          'Easy to implement'
        ]
        [
          'Only works on sorted arrays'
        ]
      ]
    }
    # (Note that the mindmap is first generated in a different format, and then converted to markmap.)
    content:
      type: 'code'
      language: 'javascript'
      title: 'Binary search algorithm (JavaScript)'
    reply: """
      Sure, take a look at this JavaScript code snippet. It’s a binary search algorithm, which is a **divide and conquer** algorithm that searches for an element in a **sorted array** by repeatedly **dividing the search interval in half**.
      
      While it’s **fast** and **easy to implement**, it only works on sorted arrays, so if you need to search for an element in an unsorted array, you’ll have to use a different algorithm.
      
      Ping me if you need help with that!
    """

# # export firstCodeExample =
# examples.generate.code.firstTime = firstCodeExample =
# _.set configs, 'generate.code.firstTime.examples', [ firstCodeExample =
configs.generate.code.firstTime.examples.push firstCodeExample =
  input:
    conversation: [{
      query: firstCodeReplyExample.input.query
      reply: firstCodeReplyExample.output.reply
    }]
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
    """
    requestedContent: firstCodeReplyExample.output.content
  output:
    code: """
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
    # (Note that we're using tabs as they take fewer tokens than spaces. This can add up when you have a lot of code.)

# # export plainToCodeReplyExample =
# examples.reply.code.continued = plainToCodeReplyExample =
# _.set configs, 'reply.code.continued.examples', [ plainToCodeReplyExample =
configs.reply.continued.examples.push plainToCodeReplyExample =
  input: {
    ...seed()
    precedingConversation: [
      query: "ELI5 binary search"
      reply: """
        Sure! Imagine you have a **sorted list** of words, say, the Oxford English Dictionary. You can find a word you need by **opening the middle page** first. If the word you see is before the one you’re looking for, you can throw away the first half of the book and **open the middle page of the second half**. You can repeat this process until you find the word you’re looking for.
      """
    ]
    markmap: """
      # Binary search
      ## ELI5
      ### Look in the middle
      ### Throw away half
      ### Look in the middle of the remaining half
      ### Repeat until you find the word
    """
    currentContent: null
    query: "Convert to code"
  }
  output:
    thoughts: "Let me come up with a really simple JavaScript code snippet that can be run in any js sandbox."
    markmap: """
      #{plainToCodeReplyExample.input.markmap}
      ## Code
    """
    content: firstCodeExample.output.content
    reply: "Sure, here’s the code in JavaScript. You can try it out in any JavaScript sandbox, for example, [JSFiddle](https://jsfiddle.net/)."

# # export plainToCodeExample =
# examples.generate.code.continued = plainToCodeExample =
# _.set configs, 'generate.code.continued.examples', [ plainToCodeExample =
configs.generate.code.continued.examples.push plainToCodeExample =
  input:
    conversation: [
      ...plainToCodeReplyExample.input.precedingConversation
      {
        query: plainToCodeReplyExample.input.query
        reply: plainToCodeReplyExample.output.reply
      }
    ]
    markmap: plainToCodeReplyExample.input.markmap
    currentContent: null
    requestedContent: plainToCodeReplyExample.output.content
  output:
    code: firstCodeExample.output.code

# # export codeToCodeReplyExample =
# examples.reply.code.fromCode = codeToCodeReplyExample =
# _.set configs, 'reply.code.fromCode.examples', [ codeToCodeReplyExample =
configs.reply.fromCode.examples.push codeToCodeReplyExample =
  input: {
    ...seed()
    precedingConversation: firstCodeExample.input.conversation
    markmap: firstCodeExample.input.markmap
    currentContent: firstCodeExample.input.requestedContent
    code: firstCodeExample.output.code
    query: "Convert to Python"
  }
  output:
    thoughts: "Easy-peasy. I’ll convert the code to Python and add a funny remark."
    markmap: """
      #{firstCodeExample.input.markmap}
      ## Python code
    """
    content:
      type: 'code'
      language: 'python'
      title: 'Binary search algorithm (Python)'
    reply: "Too many curly braces? I get that ;-) Here’s the code in Python."

# # export codeToCodeExample =
# examples.generate.code.fromCode = codeToCodeExample =
# _.set configs, 'generate.code.fromCode.examples', [ codeToCodeExample =
configs.generate.code.fromCode.examples.push codeToCodeExample =
  input:
    conversation: [
      ...firstCodeExample.input.conversation
      {
        query: codeToCodeReplyExample.input.query
        reply: codeToCodeReplyExample.output.reply
      }
    ]
    markmap: codeToCodeReplyExample.input.markmap
    currentContent: codeToCodeReplyExample.input.currentContent
    currentCode: codeToCodeReplyExample.input.code
    requestedContent: codeToCodeReplyExample.output.content
  output:
    code: """
      # A function that searches for a target value in a sorted array
      def binary_search(arr, target):
      \tleft = 0
      \tright = len(arr) - 1
      \twhile left <= right:
      \t\tmid = (left + right) // 2
      \t\tif arr[mid] == target:
      \t\t\treturn mid
      \t\telif arr[mid] < target:
      \t\t\tleft = mid + 1
      \t\telse:
      \t\t\tright = mid - 1
      \treturn -1
    """

# # export textToCodeReplyExample =
# examples.reply.code.fromText = textToCodeReplyExample =
# _.set configs, 'reply.code.fromText.examples', [ textToCodeReplyExample =
configs.reply.fromText.examples.push textToCodeReplyExample =
  input: {
    ...seed()
    precedingConversation: [{
      query: 'Cheatsheet on binary search'
      reply: 'Sure, here’s a quick cheatsheet to get you started!'
    }]
    markmap: firstCodeExample.input.markmap
    currentContent:
      type: 'text'
      format: 'markdown'
      title: 'Binary search cheatsheet'
    text: """
      # Binary search

      **Binary search** is a search algorithm that finds the position of a target value within a **sorted array**. Binary search **compares the target value to the middle element** of the array and then iteratively **divides the search interval in half** until the target value is found. 

      ## Advantages

      [...advantages]

      ## Disadvantages

      [...disadvantages]

      ## See also

      [...see also]
    """ 
    query: 'Can you write this in JavaScript?'
  }
  output:
    thoughts: "Let me keep it short and simple and add comments afterwards if requested."
    markmap: """
      #{firstCodeExample.input.markmap}
      ## JavaScript code
    """
    content: firstCodeExample.output.content
    reply: "Sure, here’s the code in JavaScript. Let me know if you need help understanding it."

# # export textToCodeExample =
# examples.generate.code.fromText = textToCodeExample =
# _.set configs, 'generate.code.fromText.examples', [ textToCodeExample =
configs.generate.code.fromText.examples.push textToCodeExample =
  input:
    conversation: [
      ...firstCodeExample.input.conversation
      {
        query: textToCodeReplyExample.input.query
        reply: textToCodeReplyExample.output.reply
      }
    ]
    markmap: textToCodeReplyExample.input.markmap
    currentContent: textToCodeReplyExample.input.currentContent
    text: textToCodeReplyExample.input.text
    requestedContent: textToCodeReplyExample.output.content
  output:
    code: firstCodeExample.output.code

# # export codeToTextReplyExample =
# examples.reply.text.fromCode = codeToTextReplyExample =
# _.set configs, 'reply.text.fromCode.examples', [ codeToTextReplyExample =
configs.reply.fromCode.examples.push codeToTextReplyExample =
  input: {
    ...seed()
    precedingConversation: firstCodeExample.input.conversation
    markmap: firstCodeExample.input.markmap
    currentContent: firstCodeExample.output.content
    query: "Can you make a cheatsheet out of this?"
  }
  output:
    thoughts: "Sure, I’ll convert the code to a cheatsheet."
    markmap: """
      #{firstCodeExample.input.markmap}
      ## Cheatsheet
    """
    content: textToCodeReplyExample.input.currentContent
    reply: "Okey-dokey, give me a sec."

# # export codeToTextExample =
# examples.generate.text.fromCode = codeToTextExample =
# _.set configs, 'generate.text.fromCode.examples', [ codeToTextExample =
configs.generate.text.fromCode.examples.push codeToTextExample =
  input:
    conversation: [
      ...firstCodeExample.input.conversation
      {
        query: codeToTextReplyExample.input.query
        reply: codeToTextReplyExample.output.reply
      }
    ]
    markmap: codeToTextReplyExample.input.markmap
    currentContent: codeToTextReplyExample.input.currentContent
    code: firstCodeExample.output.code
    requestedContent: codeToTextReplyExample.output.content
  output:
    text: textToCodeReplyExample.input.text