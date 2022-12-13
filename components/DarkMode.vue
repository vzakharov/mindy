<template lang="pug">
  //- DarkMode, a funny component that makes all the page black, adds eyes emojis  in the middle of the page, makes them periodically blink, and generates a monologue from the perspective of the chatbot (using GPT-3).

  //- Fluid full-screen container
  b-container.justify-content-center.align-items-center.text-center.d-flex.flex-column(
    fluid
    style="height: 100vh; background-color: black; color: white;"
    @dblclick="$emit('wheres-the-fucking-light-switch')"
  )
    b-row
      b-col
        //- The eyes
        p#eyes
          | ( 👁️ )  ( 👁️ )
        //- The monologue
        div.mt-5
          p#monologue(
            v-for="line, key in lines"
            :key="key"
            v-text="line"
          )

</template>

<script lang="coffee">

  import PolygonClient from '~/plugins/polygonClient'
  import log from '~/plugins/log'
  import syncLocalMixin from '~/plugins/syncLocal'

  export default

    mixins: [
      syncLocalMixin
        keys: [
          'darkmodeEverUsed'
        ]
        prefix: 'mindy'
    ]

    props:
      polygon:
        type: PolygonClient
        required: true
      context:
        default: 'stuff'
      usdSpent:
        type: Number
        required: true
    
    data: ->
      lines: []
      blinkTimeout: null
      getLineTimeout: null
      darkmodeEverUsed: false
    
    mounted: ->
      # Run the first getLine and blink methods in a random amount of time between 1 and 3 seconds
      setTimeout @getLine, Math.random() * 2000 + 1000
      setTimeout @blink, Math.random() * 2000 + 1000
    
    computed:

      topics: ->
        # Get the topics from the context
        @context.split('\n').map ( line ) -> line.trim().replace(/^[-*+]\s*/, '').toLowerCase()

    methods:

      randomTopic: ->
        # Use main (first) topic + a random topic, e.g. "app ideas and chatbots"
        log 'Using topic',
        if @topics.length > 1
          subTopics = @topics.slice(1)
          "#{@topics[0]} and #{subTopics[ Math.floor Math.random() * subTopics.length ]}"
        else
          @topics[0]


      getLine: ->

        continued = !!@lines.length

        slug = if continued then 'darkmode-continued' else 'darkmode'
        # (Depending on whether the monologue has already started or not, we need to use one prompt or another)

        if @darkmodeEverUsed
          slug += '-repeated'

        previousLines = @lines.join('”\nThen: “')

        { choices: [{ text }], approximateCost } = await @polygon.run slug, {
          topic: @randomTopic()
          previousLines
        }, {
          max_tokens: 50
          temperature: 0.7
          n: 1
          stop: [ '”', '"']
        }

        @$emit 'update:usdSpent', @usdSpent + approximateCost
        @darkmodeEverUsed = true

        line = text.replace(/[”"\n].*/, '').trim()

        if line
          @lines = [ ...@lines, line ]

        # Run itself in a random amount of time between 2 and 6 seconds
        @getLineTimeout = setTimeout @getLine, 2000 + Math.random() * 4000
      
      blink: ->
        # Randomly rotate between the following states:
        # open:        ( 👁️ )  ( 👁️ )
        # close:       (    )   (    )
        # look right:  (  👁️)  (  👁️)
        # look left:   (👁️  )  (👁️  )
        element = document.getElementById 'eyes'
        element.innerText = [
          '( 👁️ )  ( 👁️ )'
          '(    )   (    )'
          '(  👁️)  (  👁️)'
          '(👁️  )  (👁️  )'
        ][ Math.floor Math.random() * 4 ]
        # Run itself in a random amount of time between 1 and 2 seconds
        @blinkTimeout = setTimeout @blink, Math.random() * 1000 + 1000

    beforeDestroy: ->
      clearTimeout @blinkTimeout
      clearTimeout @getLineTimeout

</script>

<style scoped>
  #eyes {
    font-size: 32px;
    /* Mono-space font so that the eyes are aligned */
    font-family: monospace;
    /* Preserve whitespace*/
    white-space: pre;
  }
  
  #monologue {
    font-size: 20px;
    /* Some fancy serif font */
    font-family: 'Playfair Display', 'Georgia', 'Times New Roman', 'Times', serif;
  }
  
</style>