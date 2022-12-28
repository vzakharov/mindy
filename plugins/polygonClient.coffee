# Client for Polygon, a GPT-3 prompt management framework
import Axios from 'axios'
import _ from 'lodash'

import log from '~/plugins/log'

export default ({
  polygonAPIurl = process.env.POLYGON_API_URL
  templatesDatabaseId = process.env.POLYGON_TEMPLATES_DB_ID
  upvotesDatabaseId = process.env.POLYGON_UPVOTES_DB_ID
  openAIkey = process.env.OPENAI_KEY
  defaultParameters = {}
  spent, vm, vmKey
} = {}) ->

  axios = Axios.create baseURL: polygonAPIurl

  console.log 'Polygon client initialized', { polygonAPIurl, templatesDatabaseId, upvotesDatabaseId, openAIkey, defaultParameters }

  {

    spent
  
    run: ( slug, variables = {}, parameters = {} ) ->

      console.log 'Running', slug, { variables, parameters}

      axios.post '/run', {
        databaseId: templatesDatabaseId
        slug
        openAIkey
        variables
        parameters: { ...defaultParameters, ...parameters }
      }
      .then ({ data }) =>
        log 'USD spent',
        @spent += data.approximateCost
        if vm
          vm[vmKey] = @spent
        data
    
    generate: ( outputKeys, input ) ->

      console.log 'Generating', outputKeys, input

      if not _.isArray(outputKeys)
        outputKeys = [ outputKeys ]

      { data } = await axios.post '/generate', {
        outputKeys
        input
        openAIkey
      }

      log 'Generated:',
      data

    upvote: ( generationId ) ->

      console.log 'Upvoting', generationId

      axios.post '/upvote', {
        databaseId: upvotesDatabaseId
        generationId
      }
      .then ({ data }) -> data

  }