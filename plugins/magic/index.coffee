# Computed prop for all magic generators
# Needs this.magicConfig to be defined for the component

import Magic from 'almostmagic'

import { deepMap } from './utils'
import configs, { skeleton } from './configs'

export default magic = ->

  Object.assign (
    window.magic = magic = new Magic @magicConfig
  ), deepMap skeleton, ( $, path ) =>
    config = _.get configs, path
    descriptor = _.camelCase path.join ' '
    if !_.isFunction config
      magic.fork {
        descriptor: _.camelCase path.join ' '
        ...config
      }
    else
      => magic.fork {
        descriptor
        ...config.call @
      }