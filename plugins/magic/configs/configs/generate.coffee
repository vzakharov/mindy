import { deepMap } from '../utils'
import configs from './skeleton'

getConfig = ( kind, modifier ) ->

  kindFrom = if modifier.startsWith 'from' then _.lowerFirst modifier.replace 'from', ''

  specs:
    description: """
      Generates #{kind} content based on a conversation between the user and an AI assistant#{
        if kindFrom then ", existing #{kindFrom} content," else ''
      } and requested content type/title.
    """
  returns: kind
  examples: []

deepMap configs.generate, -> getConfig ...arguments