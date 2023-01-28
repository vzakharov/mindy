# Mixin to manage authentication via Bubble API
import Bubble from '~/plugins/bubble'

import syncLocal from '~/plugins/mixins/syncLocal'
import tryAction from '~/plugins/mixins/tryAction'

export class BubbleAuthError extends Error

export default

  mixins: [
    syncLocal {
      keys: [
        [ 'auth', exclude: [ 'form' ] ],
        'auth.form.mode'
      ]
      prefix: process.env.APP_SLUG
    }
    tryAction
  ]

  data: ->

    auth:
      token: null
      expiresAt: null
      userId: null
      form:
        email: null
        password: null
        slug: null
        mode: 'signup'
    user: null
    loggedIn: false

  computed:

    bubble: -> new Bubble @auth

  methods:
  
    login: ->

      @try 'authenticating',
        =>
          { token, user_id: userId, expires: expiresIn } = await @bubble.run 'login', @auth.form
          Object.assign @auth, { token, userId, expiresAt: Date.now() + expiresIn * 1000 }
          # Set auth form mode to 'login', so that even if the user logs out, the form will be in 'login' mode
          @auth.form.mode = 'login'
    
  watch:
  
    'auth.userId': ( id ) ->
      @try 'gettingUser',
        =>
          # @user = await @bubble.get 'user', id
          @user = _.mapKeys ( await @bubble.get 'user', id ), ( value, key ) -> _.camelCase key
          @loggedIn = true