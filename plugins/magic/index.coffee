# Computed prop for all magic generators
# Needs this.magicConfig to be defined for the component

import Magic from 'almostmagic'

import firstReply from './configs/reply/first'
import { chatTitle } from './configs/misc'

console.log {
  firstReply
  chatTitle
}

export default ->

  Object.assign (
    window.magic = magic = new Magic @magicConfig
  ), _.mapValues {
    firstReply
    chatTitle
  }, ( config ) -> magic.fork config