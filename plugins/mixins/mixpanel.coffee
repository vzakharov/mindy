# Mixin to track events with Mixpanel
# IMPORTANT: IF YOU FORKED THIS REPO, MAKE SURE TO CHANGE THE MIXPANEL TOKEN OR REMOVE IT COMPLETELY, OR YOU WILL BE TRACKING YOUR USERS' DATA IN MY MIXPANEL ACCOUNT.
# (Not that I really mind.)

import mixpanel from 'mixpanel-browser'

export default
  
  data: ->

    mixpanel.init process.env.MIXPANEL_TOKEN, debug: process.env.MIXPANEL_DEBUG

    # (I really hope it's okay to put this in public. Gotta ask someone who knows more about this stuff.)
    # TODO: Remove debug: true before deploying!!!
    { mixpanel }