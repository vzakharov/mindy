// Various methods to work with Notion API

// axios
import axios from 'axios'

// lodash
import { 
  chain, camelCase, upperFirst, keys
} from 'lodash'

function Notion(token) {

  let api = axios.create({
    baseURL: process.env.NOTION_API_URL,
    headers: {
      ...token ? {
        Authorization: `Bearer ${token}`
      } : {}
    }
  })
  
  Object.assign(this, {

    // Create page
    async createPage({ parent, properties, content }) {

      let {
        data
      } = await api.post('pages', {
        parent,
        ...notionize({ properties, content })
      })

      denotionize(data)

      return data

    },

    // Update page
    async updatePage(id, { properties, content }) {

      let {
        data
      } = await api.patch(`pages/${id}`,
        notionize({ properties, content })
      )

      denotionize(data)

      return data

    },

    // Delete block
    async deleteBlock(id) {

      let { data } = await api.delete(`blocks/${id}`)

      return data

    },

    // Get page
    async getPage(id) {

      let {
        data
      } = await api.get(`pages/${id}`)

      denotionize(data)

      return data

    },

    // Get token owner info
    async getUser() {

      // If no token, throw error
      if ( !token ) {
        throw new Error('No token provided. Please use an instance of Notion with a token.')
      }

      return (
        await api.get('users/me')
      ).data

    },

    // query a database
    async queryDatabase(databaseId, query) {
      return (
        await api.post(`databases/${databaseId}/query`, query)
      ).data.results.map( result => {
        let { properties, ...details } = result
        denotionize(result)
        return {
          ...result.properties,
          details
        }
      })
    },

    // Get page by name
    async getPageBy(databaseId, filter ) {
      let key = keys(filter)[0]
      let value = filter[key]
      return ( 
        await this.queryDatabase(databaseId, {
          filter: {
            property: _.startCase(key),
            title: {
              equals: value
            }
          }
        })
      )?.[0]
    },

    // get a block
    async getBlock(blockId, { recurse = false } = {}) {

      let { data, data: { has_children } } = await api.get(`blocks/${blockId}`)

      if ( has_children ) {
        data.children = await this.getBlockChildren(blockId, { recurse })
      }

      return data

    },

    // get block children
    async getBlockChildren(blockId, { recurse = false } = {}) {

      let { data: { results }} = await api.get(`blocks/${blockId}/children`)

      if ( recurse )
        await Promise.all(
          results.map( async result => {
            let { has_children } = result
            if ( has_children ) {
              result.children = await this.getBlockChildren(result.id, { recurse })
            }
            return result
          })
        )
      
      return results

    }
        

  })

}

function notionize({ properties, content }) {

  let jsonKeys = []

  return {

    properties: chain(properties)
      .mapValues((value, key) => {
        
        if (typeof value === 'number') {
          return {
            number: value
          }
        }

        else {
          let isObject = value && typeof value === 'object'

          if ( isObject ) {
            jsonKeys.push(key)
          }

          return {
            [key === 'name' ? 'title' : 'rich_text']: [{
              text: {
                content: isObject ? JSON.stringify(value) : value
              }
            }]
          }
        }

      })
      .mapKeys((value, key) => {

        if ( jsonKeys.includes(key) ) {
          key += ' JSON'
        }

        // Upper first + space between every lower and upper letter
        key = _.startCase(key)

        return key

      })
      .value(),

    children: content.plain && (
      content = (
        typeof content.plain === 'string' ? content.plain : JSON.stringify(content.plain, null, 2)
      ).split(/\n+/),
      content.map( line => ({
        type: 'paragraph',
        paragraph: {
          rich_text: [{
            type: 'text',
            text: {
              content: line
            }
          }]
        }
      }) )
    )

  }
}

function denotionize(data, key = 'properties') {

  let jsonKeys = []

  data[key] = chain(data[key])
    .mapKeys( ( value, key ) => {
      key = camelCase(key)
      if ( key.endsWith('Json') ) {
        let type = 'object'
        key = key.replace(/Json$/, '')
        jsonKeys.push(key)
      }
      return key
    })
    .mapValues( ( object, key ) => {

      const extract = object =>
        object?.type ?
          extract(object[object.type]) :
          object

      let value = extract(object)
      // console.log({ object, value })

      if ( ['title', 'rich_text'].includes(object.type) ) {
        value = value[0]?.plain_text

        if ( jsonKeys.includes(key) ) {
          value = JSON.parse(value || null)
        }
      }

      return value

    } )
    .value()

}

Notion.anon = new Notion()

export default Notion