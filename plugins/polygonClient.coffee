# Client for Polygon, a GPT-3 prompt management framework
import Axios from 'axios'

export default ({
  polygonAPIurl = process.env.POLYGON_API_URL
  templatesDatabaseId = process.env.POLYGON_TEMPLATES_DB_ID
  upvotesDatabaseId = process.env.POLYGON_UPVOTES_DB_ID
  openAIkey = process.env.OPENAI_KEY
  defaultParameters = {}
} = {}) ->

  axios = Axios.create baseURL: polygonAPIurl

  console.log 'Polygon client initialized', { polygonAPIurl, templatesDatabaseId, upvotesDatabaseId, openAIkey, defaultParameters }
  
  run: ( slug, variables = {}, parameters = {} ) ->

    console.log 'Running', slug, { variables, parameters}

    axios.post '/run', {
      databaseId: templatesDatabaseId
      slug
      openAIkey
      variables
      parameters: { ...defaultParameters, ...parameters }
    }
    .then ({ data }) -> data
  
  upvote: ( generationId ) ->

    console.log 'Upvoting', generationId

    axios.post '/upvote', {
      databaseId: upvotesDatabaseId
      generationId
    }
    .then ({ data }) -> data