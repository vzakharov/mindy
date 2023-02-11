# Basic config for writing stuff (code or text) based on a previous exchange and context
import _ from 'lodash'

import { accepts, returns } from '../snippets'

export default ( kindFrom, kindTo) -> 
  {
    previousExchange, markmap, code, text, language, format
  } = accepts

  {
    updatedCode, updatedLanguage, updatedText, updatedFormat
  } = returns

  specs:
    description: "Writes #{kind} based on a previous exchange between the user and Mindy (AI assistant) and the current context."
    accepts: {
      previousExchange
      markmap
      current: switch kindFrom
        when 'code' then { code, language }
        when 'text' then { text, format }
    }
    returns: switch kindTo
      when 'code' then { updatedCode, updatedLanguage }
      when 'text' then { updatedText, updatedFormat }
