# Client for Polygon, a GPT-3 prompt management framework

import Axios from 'axios'

export default ({ polygonAPIurl = process.env.POLYGON_API_URL, databaseId = process.env.POLYGON_DATABASE_ID, openAIkey = process.env.OPENAI_KEY, defaultParameters } = {}) ->

  axios = Axios.create
    baseURL: polygonAPIurl
  
  run: ( slug, variables = {}, parameters = {} ) ->

    axios.post '/run', {
      databaseId
      slug
      openAIkey
      variables
      parameters: { ...defaultParameters, ...parameters }
    }.then ( { data } ) -> data