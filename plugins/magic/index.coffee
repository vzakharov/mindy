# Computed prop for all magic generators
# Needs this.magicConfig to be defined for the component

import Magic from 'almostmagic'

import firstReply from './configs/reply/first'
import { chatTitle, freeAssociations } from './configs/misc'

export default ->

  Object.assign (
    window.magic = magic = new Magic @magicConfig
  ), _.mapValues {
    firstReply
    chatTitle
    freeAssociations
  }, ( config, descriptor ) -> magic.fork {
    descriptor
    ...config
  }