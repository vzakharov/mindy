# Computed prop for all magic generators
# Needs this.magicConfig to be defined for the component

import Magic from 'almostmagic'

import { deepMap } from './utils'
import configs, { skeleton } from './configs'

export default ->

  Object.assign (
    window.magic = magic = new Magic @magicConfig
  ), deepMap skeleton, ( $, path ) ->
    magic.fork {
      descriptor: _.camelCase path.join ' '
      ..._.get configs, path
    }