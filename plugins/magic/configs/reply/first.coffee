# Config for the first reply of the bot

import _ from 'lodash'
import { validate } from '~/plugins/mindmapAsNestedArray'
import { seed } from '~/plugins/magic/utils'
import base from '.' # The base config

export default -> _.merge base(), {
  specs:
    returns:
      mindmap: [
        "A mindmap explicating the topic, as an object with the following keys:"
        root: 'String indicating the root node of the mindmap.'
        branches: 'An array of child nodes of the root node, minimum 3.'
        subbranches: 'An array of arrays of child nodes of the branches, each reffering to the same index in the branches array, minimum 2 subbranches per branch.'
      ]
  examples: [
    {
      input: {
        ...seed()
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
    }, {
      input: {
        ...seed()
        query: 'Write a binary search algorithm'
      }
      output:
        thoughts: 'Binary search? Pff, easy. I’ll generate a code snippet and a mindmap to help memorize the basic concepts. I’ll use vanilla JavaScript so that it can be run right in the browser.'
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
        content:
          type: 'code'
          language: 'javascript'
          title: 'Binary search algorithm'
        reply: "Sure, take a look at this JavaScript code snippet. It’s a binary search algorithm, which is a **divide and conquer** algorithm that searches for an element in a **sorted array** by repeatedly **dividing the search interval in half**.\n\nWhile it’s **fast** and **easy to implement**, it only works on sorted arrays, so if you need to search for an element in an unsorted array, you’ll have to use a different algorithm.\n\nPing me if you need help with that!"
    }, {
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
        reply: "Oh, about to start **something amazing** are we?\n\nSure, here’s some intro and outline to get you started — click the **Expand button** if you want me to go into more detail.\n\nOh, and I also made a **mindmap** to help you organize your thoughts."
    }
  ]
  postprocess: (output) ->
    { mindmap, mindmap: { root, branches, subbranches } } = output
    mindmap = validate [
      root
      _.flatten _.map branches, (branch, index) ->
        [ branch, ...if subbranches[index]?.length then [ subbranches[index] ] else [] ]
    ]
    Object.assign output, {
      context: { mindmap }
    }
}
