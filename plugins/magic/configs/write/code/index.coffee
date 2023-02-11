# Write code based on no previous content
import _ from 'lodash'

import write from '..'

export default -> _.merge write( 'code', 'code'),
  examples: [
    {
      input: {
        previousExchange: [
          query: 'Write a binary search algorithm'
          reply: "Sure, take a look at this JavaScript code snippet. It’s a binary search algorithm, which is a **divide and conquer** algorithm that searches for an element in a **sorted array** by repeatedly **dividing the search interval in half**.\n\nWhile it’s **fast** and **easy to implement**, it only works on sorted arrays, so if you need to search for an element in an unsorted array, you’ll have to use a different algorithm.\n\nPing me if you need help with that!"
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
        """
        current:
          code: null
          language: 'javascript'
      },
      output: {
        updatedCode: """
          // Binary search algorithm.
          // Returns the index of the target element in the array, or -1 if it’s not found. 
          function binarySearch(array, target) {
          \tlet start = 0;
          \tlet end = array.length - 1;
          \twhile ( start <= end ) {
          \t\tconst mid = Math.floor( (start + end) / 2 );
          \t\tif ( array[mid] === target ) {
          \t\t\treturn mid;
          \t\t} else if ( array[mid] < target ) {
          \t\t\tstart = mid + 1;
          \t\t} else {
          \t\t\tend = mid - 1;
          \t\t}
          \t}
          \treturn -1;
          }
        """
        updatedLanguage: 'javascript'
      }
    }
  ]