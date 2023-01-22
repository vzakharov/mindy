// Plugin to "talk" to Bubble, which is currently used as the DB
// The most important thing to note here is that Bubble can't store objects. Tiw I store them as strings (JSON) and parse on the receiving end. I'm considering using YAML instead (todo)

import Axios from 'axios'
import { camelCase, forEach, isArray, isObject, keys, map, mapValues, omit, sortBy } from 'lodash'
import { singular } from 'pluralize'

function Bubble({$auth, token } = {}) {

  if ( $auth )
    token = $auth.strategy.token.get()

  let axios = Axios.create({ 
    baseURL: process.env.NUXT_ENV_BUBBLE_URL,
    ...token ? {
      headers: {Authorization: token }
    } : {}
  })

  Object.assign(this, {


    // Get thing by id or slug, or a list of things by filter
    async get( type, idOrQuery, options = {}) {
      let id = typeof idOrQuery === 'string' && idOrQuery
      let query = !id && idOrQuery || {}
      let slug = id && !id.match(/^\d/) && id
      if ( slug )
        id = undefined
      let fetchMany = !id & !slug
      if ( fetchMany )
        type = singular(type)

      const url = `obj/${type}/`

      let constraint_type = 'equals'

      let params = { 
        constraints: JSON.stringify(
          slug ?
            [{
              key: 'Slug', value: slug, constraint_type
            }] 
            : Object.entries(query).map(([key, value]) => ({
              key, 
              value: isObject(value) ? value.id : value, 
              constraint_type
            }))
        ),
        ...options
      }

      let doFetch = () => (
        ( id ) ? 
          axios.get(url + id) : 
          axios.get(url, { params })
      )

      let { data: { response }} = await doFetch()
      
      let { results } = response

      if ( results ) {
        let { remaining } = response
        if ( remaining ) {
          let promises = []
          for ( let cursor = 100; cursor < remaining + 100 ; cursor += 100 ) {
            Object.assign(params, { cursor, limit: 100 })
            promises.push(new Promise(resolve =>
              doFetch().then(
                ( { data: { response: { results: moreResults }}} ) => resolve(moreResults)
              )
            ))
          }
          results = [...results, ...await Promise.all(promises)].flat()
        }
      }
      
      let things = id ? [ response ] : results
      let object = {}
      object[type] = things
      parse(object)

      things = object[type]
      let result
      if ( fetchMany ) {
        if ( options.sortBy )
          things = sortBy(things, options.sortBy)
        result = things
      } else
        result = things[0]
      
      if ( options.includeKey ) {
        let keyedResult = {}
        keyedResult[type] = result
        result = keyedResult
      }
      
      // console.log({result})

      return result

    },

    destroy: (type, thing) =>
      axios.delete(`obj/${type}/${thing.id}`).then(console.log),

    patch: (type, thing, changes) => 
      axios.patch(`obj/${type}/${thing.id}`, changes || unparse(omit(thing, 'slug', 'id'))),

    post: async (type, thing) => {
      try {
        let { data: { id }} = await axios.post(`obj/${type}`, thing)
        return { id }
      } catch(error) {
        // console.log(error.response.data)
        let { statusCode, body } = error
        throw({error, statusCode, ...body})
      }
    },

    // Call any workflow API
    async go( workflow, body ) {
      body = omit(body, v => typeof v === 'undefined') 
      // console.log(this, workflow, body)
      try {
        forEach(body,  ( value, key ) => {
          if ( typeof value == 'object' ) {
            body[key] = JSON.stringify(value)
          }
        })
        let { data: { response } } = await axios.post('/wf/'+workflow, body)
        parse(response)
        // console.log({response})
        return response
      } catch({ response, ...error }) {
        if ( response ) {
          let {data, request: { path }} = response
          throw({...data, path})
        } else
          throw(error)
        // console.log({...data, path})
      }
    }
  
  })

}


// Note: this fyunction creates **another function**, which in turn has the arguments usually required for the asyncData API
Bubble.asyncData = ( type, query, options ) =>  {
  return async ({ $auth, route, $route}) => {
    let { params: { id, slug }} = route || $route
    id = id || slug
    // console.log(options)
    let result = {}
    let bubble = new Bubble($auth && { token: $auth.strategy.token.get() })
    let value = await bubble.get(type, query || id, options)
    result[type] = value
    return {...result, loaded: true}
  }
}

// For calls that don't require authentication
Bubble.anon = new Bubble()

Bubble.reservedProperties = ['Slug', '_id', 'Modified Date', 'Created Date', 'Created By']
Bubble.camelcasedReservedProperties = map(Bubble.reservedProperties, camelCase)

// Convert Bubble fields to js objects
function parse(object) {

  const process = ( thing, type ) => {

    thing = mapValues(thing, value => {
      const isString = typeof value === 'string'
      if (isString && value[0] == '{')
        try {
          return JSON.parse(value)
        } catch {
          return value
        }
      else {
        if (isString && value.match(/^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.\d\d\dZ$/))
          return new Date(value)
        else
          return value
      }
    })

    if ( singular(type) == 'widget' && thing.template ) {
      // debugger
      thing.slate = thing.slate || thing.template
      delete thing.template
    }

    for (let key of Bubble.reservedProperties) {
      thing[camelCase(key)] = thing[key]
      delete thing[key]
    }

    // console.log({thing})

    return thing
  }

  for ( let key of keys(object) ) {
    let value = object[key]
    if ( isArray(value) ) {
      if ( value.length > 0 && isObject(value[0]) )
        object[key] = map(value, value => process(value, key, object))
    }
    else if ( isObject(value) ) {
      object[key] = process(value, key, object)
    }
  }

}

// Convert back
function unparse(object) {

  return mapValues(object, value =>
    isObject(value) && !isArray(value) ?
      JSON.stringify(value) :
      value
  )

}

export default Bubble