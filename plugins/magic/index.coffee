# Computed prop for all magic generators
# Needs this.magicConfig to be defined for the component

import Magic from 'almostmagic'

# import firstReply from './configs/reply/first'
import { chatTitle, freeAssociations } from './configs/misc'
import first from './configs/reply/first'
import plain from './configs/reply/next/plain'
import withCode from './configs/reply/next/withCode'
import withText from './configs/reply/next/withText'

export default ->

  path = []
  Object.assign (
    window.magic = magic = new Magic @magicConfig
  ), _.mapValues {
    reply: {
      first,
      next: {
        plain,
        withCode,
        withText
      }
    }
    chatTitle
    freeAssociations
  }, parse = ( value, key ) ->
    # If function, fork; otherwise, map further
    if _.isFunction value
      magic.fork {
        descriptor: [...path, key].join '.'
        ...value()
      }
    else
      path.push key
      result = _.mapValues value, parse
      path.pop()
      result